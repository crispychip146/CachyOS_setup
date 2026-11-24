#!/usr/bin/env python3
"""Select the curated palette for a Noctalia wallpaper-change event."""
import argparse
import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys
import tomllib
from urllib.parse import unquote, urlparse

from folder_icons import apply_for_palette

ROOT = Path(__file__).resolve().parent


def ipc(*args):
    return subprocess.run(['noctalia', 'msg', *args], check=True, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=20).stdout.strip()


def current_wallpaper():
    try:
        return ipc('wallpaper-get')
    except (subprocess.SubprocessError, OSError):
        state_root = Path(os.environ.get('NOCTALIA_STATE_HOME') or os.environ.get('XDG_STATE_HOME')
                          or Path.home() / '.local/state') / 'noctalia'
        try:
            state = tomllib.loads((state_root / 'settings.toml').read_text())
            return state.get('wallpaper', {}).get('default', {}).get('path', '')
        except (OSError, tomllib.TOMLDecodeError):
            return ''


def resolve(manifest, path):
    if path.startswith('file://'):
        path = unquote(urlparse(path).path)
    expanded = Path(os.path.normpath(path)).expanduser()
    for entry in manifest['wallpapers'].values():
        if expanded == Path(entry['path']):
            return entry
    # Relative keys distinguish same-named images in different subfolders.
    if not expanded.is_absolute() and expanded.as_posix() in manifest['wallpapers']:
        return manifest['wallpapers'][expanded.as_posix()]
    # Keep working if the entire wallpaper directory is relocated.
    matches = [(len(Path(key).parts), entry) for key, entry in manifest['wallpapers'].items()
               if len(Path(key).parts) > 1 and expanded.as_posix().endswith('/' + key)]
    if matches:
        longest = max(length for length, entry in matches)
        candidates = [entry for length, entry in matches if length == longest]
        if len(candidates) == 1:
            return candidates[0]
    matches = [entry for key, entry in manifest['wallpapers'].items()
               if Path(key).name == expanded.name]
    return matches[0] if len(matches) == 1 else None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('wallpaper', nargs='?')
    parser.add_argument('--dry-run', action='store_true', help='Print selection without changing settings')
    args = parser.parse_args()
    manifest = json.loads((ROOT / 'manifest.json').read_text())
    path = args.wallpaper or os.environ.get('NOCTALIA_WALLPAPER_PATH') or current_wallpaper()
    selected = resolve(manifest, path) if path else None
    if not selected:
        if args.dry_run:
            print(f'No curated palette for: {path or "(no wallpaper available)"}')
        return 0
    if args.dry_run:
        print(json.dumps({'wallpaper': path, **selected}, indent=2))
        return 0
    # Serialize multi-output hook events. A palette is global in Noctalia;
    # the most recently processed wallpaper event chooses the global palette.
    with (ROOT / '.apply.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        wanted = f'custom {selected["palette"]}'
        if ipc('color-scheme-get') != wanted:
            ipc('color-scheme-set', 'custom', selected['palette'])
        apply_for_palette(ROOT, selected['palette'])
    print(f'{selected["name"]}: {Path(path).name}')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, subprocess.SubprocessError, ValueError) as error:
        print(f'Exotic wallpaper themes: {error}', file=sys.stderr)
        sys.exit(1)
