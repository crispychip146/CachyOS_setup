#!/usr/bin/env python3
"""Recolor installed Adwaita folder SVGs and select an inherited icon theme."""
import ast
import json
from pathlib import Path
import re
import subprocess

SCHEMA = 'org.gnome.desktop.interface'


def get_icon_theme():
    result = subprocess.run(['gsettings', 'get', SCHEMA, 'icon-theme'],
                            check=True, capture_output=True, text=True, timeout=15)
    value = ast.literal_eval(result.stdout.strip())
    if not isinstance(value, str) or not value or any(c in value for c in ',\n\r'):
        raise ValueError('Invalid current icon theme')
    return value


def set_icon_theme(name):
    if get_icon_theme() == name:
        return
    subprocess.run(['gsettings', 'set', SCHEMA, 'icon-theme', name],
                   check=True, capture_output=True, text=True, timeout=15)
    if get_icon_theme() != name:
        raise ValueError('The icon theme setting did not persist; run setup in your normal desktop session')


def mix(color, target, amount):
    return '#' + ''.join(f'{round(int(color[i:i + 2], 16) * (1 - amount) + target * amount):02x}'
                         for i in (1, 3, 5))


def build_themes(palettes, base_theme='Adwaita', source=Path('/usr/share/icons/Adwaita/scalable/places')):
    """Return installable file bytes and a palette-to-icon-theme mapping."""
    if not base_theme or any(c in base_theme for c in ',\n\r'):
        raise ValueError('Invalid inherited icon theme')
    sources = {p.name: p.read_text() for p in sorted(source.glob('folder*.svg'))
               if not p.name.endswith('-symbolic.svg')}
    for name in ('user-home.svg', 'user-desktop.svg'):
        if (source / name).exists():
            sources[name] = (source / name).read_text()
    if 'folder.svg' not in sources or '#a4caee' not in sources['folder.svg'].lower():
        raise ValueError('Expected Adwaita folder SVG assets are unavailable; icon integration was not installed')
    files, mapping = {}, {}
    for palette_name, palette in palettes.items():
        primary = palette['dark']['mPrimary'].lower()
        if not re.fullmatch(r'#[0-9a-f]{6}', primary):
            raise ValueError(f'Invalid primary color in {palette_name}')
        theme_name = 'Exotic-Folders-' + primary[1:]
        mapping[palette_name] = theme_name
        if f'{theme_name}/index.theme' in files:
            continue
        replacements = {
            '#a4caee': primary,                 # large front panel: exact palette accent
            '#438de6': mix(primary, 0, .35),    # back panel and folder emblems
            '#62a0ea': mix(primary, 0, .13),    # bottom edge
            '#afd4ff': mix(primary, 255, .26),  # glossy edge highlights
            '#c0d5ea': mix(primary, 255, .36),
        }
        for name, svg in sources.items():
            recolored = re.sub(r'#[0-9a-fA-F]{6}\b',
                               lambda match: replacements.get(match[0].lower(), match[0]), svg)
            files[f'{theme_name}/scalable/places/{name}'] = recolored.encode()
        # Common alternate names used by file managers and file chooser dialogs.
        for alias, original in {'inode-directory': 'folder', 'folder-open': 'folder',
                                'folder-downloads': 'folder-download'}.items():
            key = f'{theme_name}/scalable/places/{original}.svg'
            if key in files:
                files[f'{theme_name}/scalable/places/{alias}.svg'] = files[key]
        inherits = ','.join(dict.fromkeys([base_theme, 'Adwaita', 'hicolor']))
        index = f'''[Icon Theme]
Name=Exotic Folders {primary.upper()}
Comment=Adwaita folder shapes recolored to the Noctalia primary accent
Inherits={inherits}
Example=folder
Directories=scalable/places

[scalable/places]
Context=Places
Size=128
MinSize=8
MaxSize=512
Type=Scalable
'''
        files[f'{theme_name}/index.theme'] = index.encode()
        files[f'{theme_name}/CREDITS.txt'] = (
            'Folder SVGs derived from the installed Adwaita icon theme by the GNOME Project.\n'
            'https://gitlab.gnome.org/GNOME/adwaita-icon-theme\n'
            'Upstream license: CC-BY-SA-3.0 OR LGPL-3.0-only.\n'
            'Modified by Exotic wallpaper themes: folder color fills and gradient stops only.\n'
            'https://creativecommons.org/licenses/by-sa/3.0/\n').encode()
    return files, mapping


def apply_for_palette(root, palette_name):
    path = root / 'folder-icon-map.json'
    if path.exists():
        theme = json.loads(path.read_text()).get(palette_name)
        if theme:
            set_icon_theme(theme)
