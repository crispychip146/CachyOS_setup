#!/usr/bin/env python3
"""Install or remove the curated palettes and Noctalia v5 wallpaper hook."""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import tomllib

from folder_icons import build_themes, get_icon_theme, set_icon_theme

ROOT = Path(__file__).resolve().parent


def atomic_write(path, data):
    if path.exists() and path.read_bytes() == data:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as temporary:
        temporary.write(data)
        temp_path = Path(temporary.name)
    temp_path.replace(path)


def read_toml(path):
    return tomllib.loads(path.read_text()) if path.exists() else {}


def merge(first, second):
    for key, value in second.items():
        if isinstance(value, dict) and isinstance(first.get(key), dict):
            merge(first[key], value)
        else:
            first[key] = value
    return first


def patch_hooks(text, updates):
    """Edit only direct [hooks] keys, preserving unrelated TOML text."""
    lines = text.splitlines(keepends=True)
    start = next((i for i, line in enumerate(lines) if re.match(r'^\s*\[hooks\]\s*(?:#.*)?$', line)), None)
    if start is None:
        additions = ''.join(f'{key} = {json.dumps(value)}\n' for key, value in updates.items() if value is not None)
        return text.rstrip() + ('\n\n[hooks]\n' + additions if additions else '\n')
    end = next((i for i in range(start + 1, len(lines)) if re.match(r'^\s*\[', lines[i])), len(lines))
    section = lines[start + 1:end]
    original = tomllib.loads(text).get('hooks', {})
    for key, value in updates.items():
        at = next((i for i, line in enumerate(section) if re.match(r'^\s*' + re.escape(key) + r'\s*=', line)), None)
        replacement = [] if value is None else [f'{key} = {json.dumps(value)}\n']
        if at is None:
            section.extend(replacement)
            continue
        # TOML hooks may use multiline arrays or strings: find the smallest
        # complete assignment matching the parsed value before replacing it.
        for stop in range(at + 1, len(section) + 1):
            try:
                parsed = tomllib.loads(''.join(section[at:stop]))
            except tomllib.TOMLDecodeError:
                continue
            if parsed.get(key) == original.get(key):
                section[at:stop] = replacement
                break
        else:
            raise ValueError(f'Cannot locate complete hook assignment: {key}')
    result = ''.join(lines[:start + 1] + section + lines[end:])
    tomllib.loads(result)
    return result


def selection(config):
    theme = config.get('theme', {})
    source = theme.get('source', 'builtin')
    key, fallback = {'builtin': ('builtin', 'Noctalia'), 'custom': ('custom_palette', ''),
                     'community': ('community_palette', 'Noctalia'),
                     'wallpaper': ('wallpaper_scheme', 'm3-content')}[source]
    return [source, theme.get(key, fallback)]


def run_ipc(*args):
    return subprocess.run(['noctalia', 'msg', *args], capture_output=True, text=True, timeout=30)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--uninstall', action='store_true')
    parser.add_argument('--offline', action='store_true', help='Write files without contacting the running shell')
    parser.add_argument('--config-dir', type=Path, help='Explicit Noctalia config directory')
    parser.add_argument('--state-dir', type=Path, help='Explicit Noctalia state directory')
    parser.add_argument('--icons-dir', type=Path, help='Explicit icon directory for an offline test installation')
    parser.add_argument('--base-icon-theme', help='Icon theme inherited for icons other than folders')
    args = parser.parse_args()
    if (args.config_dir or args.state_dir or args.icons_dir) and not args.offline:
        parser.error('Use --offline with explicit test directories')
    config_dir = args.config_dir or Path(os.environ.get('NOCTALIA_CONFIG_HOME') or os.environ.get('XDG_CONFIG_HOME')
                                         or Path.home() / '.config') / 'noctalia'
    state_dir = args.state_dir or Path(os.environ.get('NOCTALIA_STATE_HOME') or os.environ.get('XDG_STATE_HOME')
                                      or Path.home() / '.local/state') / 'noctalia'
    config_dir, state_dir = config_dir.resolve(), state_dir.resolve()
    # Explicit offline config/state directories are tests: keep their icons in
    # that same sandbox unless an explicit icon directory is supplied.
    icons_dir = args.icons_dir or (
        config_dir.parent / 'icons' if args.config_dir or args.state_dir else
        Path(os.environ.get('XDG_DATA_HOME') or Path.home() / '.local/share') / 'icons')
    icons_dir = icons_dir.resolve()
    bundle = config_dir / 'exotic-themes'
    receipt_path = bundle / 'install-receipt.json'
    state_path = state_dir / 'settings.toml'
    if args.uninstall:
        if not receipt_path.exists():
            print('No Exotic theme installation found.')
            return
        receipt = json.loads(receipt_path.read_text())
        if str(state_path) != receipt['state_path']:
            raise ValueError('State directory differs from the recorded installation')
        if receipt.get('icons_dir') and str(icons_dir) != receipt['icons_dir']:
            raise ValueError('Icon directory differs from the recorded installation')
        if not args.offline and receipt.get('previous_icon_theme'):
            owned = set(receipt.get('icon_mapping', {}).values())
            if get_icon_theme() in owned:
                set_icon_theme(receipt['previous_icon_theme'])
        # Restore GUI hook overrides only if nobody has changed those keys.
        if state_path.exists() and receipt['state_hooks']:
            state_text = state_path.read_text()
            active_hooks = tomllib.loads(state_text).get('hooks', {})
            restore = {key: value for key, value in receipt['state_hooks'].items() if key not in active_hooks}
            if restore:
                atomic_write(state_path, patch_hooks(state_text, restore).encode())
        for relative, record in reversed(list(receipt['files'].items())):
            path = config_dir / relative
            if not path.exists():
                continue
            if hashlib.sha256(path.read_bytes()).hexdigest() != record['installed_sha256']:
                print(f'Kept modified file: {path}')
                continue
            if record['before'] is None:
                path.unlink()
            else:
                atomic_write(path, base64.b64decode(record['before']))
        for relative, record in receipt.get('icon_files', {}).items():
            path = icons_dir / relative
            if not path.exists():
                continue
            if hashlib.sha256(path.read_bytes()).hexdigest() != record['installed_sha256']:
                print(f'Kept modified icon file: {path}')
                continue
            if record['before'] is None:
                path.unlink()
            else:
                atomic_write(path, base64.b64decode(record['before']))
        for theme in set(receipt.get('icon_mapping', {}).values()):
            directory = icons_dir / theme
            if directory.is_dir():
                for child in sorted(directory.rglob('*'), key=lambda p: len(p.parts), reverse=True):
                    if child.is_dir() and not any(child.iterdir()):
                        child.rmdir()
                if not any(directory.iterdir()):
                    directory.rmdir()
        if not args.offline:
            run_ipc('config-reload')
            result = run_ipc('color-scheme-set', *receipt['previous_selection'])
            if result.returncode:
                print('Restore your previous palette when Noctalia is running: noctalia msg color-scheme-set '
                      + shlex.join(receipt['previous_selection']))
        receipt_path.unlink()
        print('Removed Exotic themes and restored the previous hook configuration.')
        return

    if not shutil.which('noctalia'):
        raise ValueError('Noctalia v5 must be installed first')
    version = subprocess.run(['noctalia', '--version'], capture_output=True, text=True, check=True).stdout
    if not re.search(r'\bv5\.', version):
        raise ValueError('This installer targets Noctalia v5')
    effective = {}
    if config_dir.exists():
        for path in sorted(config_dir.glob('*.toml')):
            merge(effective, read_toml(path))
    state = read_toml(state_path)
    merge(effective, state)
    receipt = json.loads(receipt_path.read_text()) if receipt_path.exists() else {
        'files': {}, 'state_hooks': {}, 'state_path': str(state_path), 'previous_selection': selection(effective)}
    if str(state_path) != receipt['state_path']:
        raise ValueError('State directory differs from the recorded installation')
    if receipt.get('icons_dir') and str(icons_dir) != receipt['icons_dir']:
        raise ValueError('Icon directory differs from the recorded installation')
    if 'previous_icon_theme' not in receipt:
        receipt['previous_icon_theme'] = args.base_icon_theme or get_icon_theme()
    receipt['icons_dir'] = str(icons_dir)
    command = shlex.join([sys.executable, str(bundle / 'apply.py')])
    hooks = {}
    for event in ('started', 'wallpaper_changed'):
        old = effective.get('hooks', {}).get(event, [])
        existing = [old] if isinstance(old, str) else list(old)
        hooks[event] = [item for item in existing if item != command] + [command]
    hook_text = '# Curated wallpaper palettes. Managed by noctalia-themes/install.py.\n[hooks]\n'
    hook_text += ''.join(f'{event} = {json.dumps(commands)}\n' for event, commands in hooks.items())
    # Validate the generated integration before writing the installation.
    with tempfile.TemporaryDirectory(prefix='exotic-theme-check-') as check_dir:
        check = Path(check_dir) / 'hooks.toml'
        check.write_text(hook_text)
        result = subprocess.run(['noctalia', 'config', 'validate', str(check)], capture_output=True, text=True)
        if result.returncode:
            raise ValueError(result.stdout + result.stderr)
    manifest = json.loads((ROOT / 'manifest.json').read_text())
    payload = {
        'exotic-themes/apply.py': (ROOT / 'apply.py').read_bytes(),
        'exotic-themes/folder_icons.py': (ROOT / 'folder_icons.py').read_bytes(),
        'exotic-themes/manifest.json': (ROOT / 'manifest.json').read_bytes(),
        'zz-exotic-wallpapers.toml': hook_text.encode(),
    }
    palettes = {}
    for entry in manifest['wallpapers'].values():
        name = entry['palette'] + '.json'
        payload['palettes/' + name] = (ROOT / 'palettes' / name).read_bytes()
        palettes[entry['palette']] = json.loads(payload['palettes/' + name])
    icon_files, icon_mapping = build_themes(palettes, receipt['previous_icon_theme'])
    payload['exotic-themes/folder-icon-map.json'] = (json.dumps(icon_mapping, indent=2) + '\n').encode()
    receipt['icon_mapping'] = icon_mapping
    # A GUI hook key takes precedence over hand-written config. Preserve its
    # effective command above, then remove just that override to enable the file.
    state_hooks = state.get('hooks', {})
    remove = {}
    for event in hooks:
        if event in state_hooks:
            receipt['state_hooks'].setdefault(event, state_hooks[event])
            remove[event] = None
    for relative, data in payload.items():
        path = config_dir / relative
        previous = receipt['files'].get(relative)
        before = previous['before'] if previous else (
            base64.b64encode(path.read_bytes()).decode() if path.exists() else None)
        atomic_write(path, data)
        receipt['files'][relative] = {'before': before, 'installed_sha256': hashlib.sha256(data).hexdigest()}
    receipt.setdefault('icon_files', {})
    for relative, data in icon_files.items():
        path = icons_dir / relative
        previous = receipt['icon_files'].get(relative)
        before = previous['before'] if previous else (
            base64.b64encode(path.read_bytes()).decode() if path.exists() else None)
        atomic_write(path, data)
        receipt['icon_files'][relative] = {'before': before, 'installed_sha256': hashlib.sha256(data).hexdigest()}
    # Save the receipt before changing state so a later uninstall can restore it.
    atomic_write(receipt_path, (json.dumps(receipt, indent=2) + '\n').encode())
    if remove:
        atomic_write(state_path, patch_hooks(state_path.read_text(), remove).encode())
    print(f'Installed {len(manifest["wallpapers"])} palettes and wallpaper hooks in {config_dir}')
    print(f'Installed {len(set(icon_mapping.values()))} matching folder icon themes in {icons_dir}')
    if args.offline:
        print('The matching palette will activate at the next Noctalia startup or wallpaper change.')
        return
    result = run_ipc('config-reload')
    if result.returncode:
        print('Noctalia IPC is unavailable here. Hooks will activate at the next Noctalia startup.')
        return
    applied = subprocess.run([sys.executable, str(bundle / 'apply.py')], text=True)
    if applied.returncode:
        raise ValueError('Files installed; immediate application failed. Try again from your desktop terminal.')
    print('Automatic palette switching is active. Existing app templates use the selected palette.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError, KeyError) as error:
        sys.exit(f'Exotic theme setup: {error}')
