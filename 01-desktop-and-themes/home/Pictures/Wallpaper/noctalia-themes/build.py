#!/usr/bin/env python3
"""Build Noctalia v5 palettes from the manually curated wallpaper accents."""
import argparse
import base64
import colorsys
import csv
import html
import io
import json
import re
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent
IMAGE_SUFFIXES = {'.png', '.jpg', '.jpeg', '.webp'}


def wallpaper_files():
    """Discover relative paths recursively, excluding bundle assets and hidden folders."""
    files = {}
    for directory, folders, names in os.walk(ROOT.parent):
        folders[:] = sorted(name for name in folders
                            if not name.startswith('.') and Path(directory) / name != ROOT)
        for name in sorted(names):
            path = Path(directory) / name
            if path.suffix.lower() in IMAGE_SUFFIXES and path.is_file():
                files[path.relative_to(ROOT.parent).as_posix()] = path
    return files


def write_if_changed(path, text):
    if not path.exists() or path.read_text() != text:
        path.write_text(text)


def list_new():
    manifest_path = ROOT / 'manifest.json'
    known = json.loads(manifest_path.read_text())['wallpapers'] if manifest_path.exists() else {}
    return sorted(set(wallpaper_files()) - set(known))


def locate_rows(rows, files):
    """Keep legacy curated rows when their uniquely named image moves to a subfolder."""
    located = []
    for row in rows:
        key = row['wallpaper']
        if key not in files and '/' not in key:
            matches = [name for name in files if Path(name).name == key]
            if len(matches) > 1:
                raise ValueError(f'Ambiguous moved wallpaper {key}; use explicit relative paths in the curated table')
            if matches:
                key = matches[0]
        located.append({**row, 'wallpaper': key})
    missing = set(files) - {row['wallpaper'] for row in located}
    if missing:
        raise ValueError('Wallpapers need curated entries: ' + ', '.join(sorted(missing)))
    return located


def rgb(color):
    return tuple(int(color[i:i + 2], 16) / 255 for i in (1, 3, 5))


def hex_rgb(channels):
    return '#' + ''.join(f'{round(max(0, min(1, c)) * 255):02X}' for c in channels)


def mix(first, second, amount):
    return hex_rgb([a * (1 - amount) + b * amount for a, b in zip(rgb(first), rgb(second))])


def luminance(color):
    channels = [c / 12.92 if c <= .04045 else ((c + .055) / 1.055) ** 2.4 for c in rgb(color)]
    return sum(c * weight for c, weight in zip(channels, (.2126, .7152, .0722)))


def contrast(first, second):
    a, b = sorted((luminance(first), luminance(second)))
    return (b + .05) / (a + .05)


def ink(background):
    return max(('#080A10', '#FFFFFF'), key=lambda c: contrast(c, background))


def readable(color, background, minimum=4.5):
    for _ in range(80):
        if contrast(color, background) >= minimum:
            return color
        color = mix(color, '#FFFFFF', .04)
    raise ValueError(f'Cannot achieve contrast for {color} on {background}')


def make_palette(row):
    surface = row['surface']
    variant = mix(surface, row['primary'], .11)
    primary, secondary, tertiary = [readable(row[key], variant) for key in ('primary', 'secondary', 'tertiary')]
    text = mix('#FFFFFF', primary, .07)
    muted = readable(mix(text, surface, .25), variant)
    outline = readable(mix(primary, surface, .48), variant, 3)
    error = readable('#FF5C78', variant)
    hover = mix(surface, tertiary, .23)
    palette = {
        'mPrimary': primary, 'mOnPrimary': ink(primary),
        'mSecondary': secondary, 'mOnSecondary': ink(secondary),
        'mTertiary': tertiary, 'mOnTertiary': ink(tertiary),
        'mError': error, 'mOnError': ink(error),
        'mSurface': surface, 'mOnSurface': text,
        'mSurfaceVariant': variant, 'mOnSurfaceVariant': muted,
        'mOutline': outline, 'mShadow': '#000000',
        'mHover': hover, 'mOnHover': readable(text, hover),
    }
    # Keep ANSI color meanings recognizable while borrowing nearby curated hues.
    bases = {'red': '#FF5C78', 'green': '#7EE85B', 'yellow': '#FFD15C',
             'blue': '#69A5FF', 'magenta': '#D879FF', 'cyan': '#43E2D2'}
    normal = {'black': variant}
    for name, default in bases.items():
        hue = colorsys.rgb_to_hsv(*rgb(default))[0]
        candidates = [c for c in (primary, secondary, tertiary)
                      if min(abs(colorsys.rgb_to_hsv(*rgb(c))[0] - hue),
                             1 - abs(colorsys.rgb_to_hsv(*rgb(c))[0] - hue)) < .065]
        normal[name] = readable(candidates[0] if candidates else default, surface)
    normal['white'] = muted
    bright = {name: mix(color, '#FFFFFF', .16) for name, color in normal.items()}
    bright['black'] = outline
    bright['white'] = text
    palette['terminal'] = {
        'background': surface, 'foreground': text, 'cursor': primary,
        'cursorText': ink(primary), 'selectionBg': secondary,
        'selectionFg': ink(secondary), 'normal': normal, 'bright': bright,
    }
    return {'dark': palette}


def build():
    from PIL import Image, ImageOps
    rows = list(csv.DictReader((ROOT / 'curated-palettes.tsv').open(), delimiter='\t'))
    files = wallpaper_files()
    rows = locate_rows(rows, files)
    assert len(rows) == len({row['wallpaper'] for row in rows}), 'Duplicate wallpaper rows'
    names = ['Exotic-' + re.sub(r'[^A-Za-z0-9]+', '-', row['name']).strip('-') for row in rows]
    assert len(names) == len(set(names)), 'Theme names must produce unique palette filenames'
    output = ROOT / 'palettes'
    output.mkdir(exist_ok=True)
    manifest = {'format': 1, 'wallpaper_root': str(ROOT.parent), 'wallpapers': {}}
    # Retain previews and palettes for removed images, so restoring them later works.
    previous_preview = (ROOT / 'preview.html').read_text() if (ROOT / 'preview.html').exists() else ''
    previous_thumbnails = {html.unescape(alt): data for data, alt in re.findall(
        r'<img loading="lazy" src="data:image/jpeg;base64,([^"]+)" alt="([^"]*)">', previous_preview)}
    cards, table = [], ['| Wallpaper | Theme | Primary | Secondary | Tertiary | Background |',
                        '|---|---|---|---|---|---|']
    for row in rows:
        name = 'Exotic-' + re.sub(r'[^A-Za-z0-9]+', '-', row['name']).strip('-')
        palette = make_palette(row)
        write_if_changed(output / f'{name}.json', json.dumps(palette, indent=2) + '\n')
        p = palette['dark']
        manifest['wallpapers'][row['wallpaper']] = {
            'palette': name, 'name': row['name'], 'path': str(ROOT.parent / row['wallpaper'])}
        if row['wallpaper'] in files:
            with Image.open(files[row['wallpaper']]) as im:
                im = ImageOps.exif_transpose(im).convert('RGB')
                im.thumbnail((500, 280))
                buf = io.BytesIO()
                im.save(buf, 'JPEG', quality=78)
            thumbnail = base64.b64encode(buf.getvalue()).decode()
        else:
            thumbnail = previous_thumbnails.get(row['wallpaper'], '')
        variables = ';'.join(f'--{key}:{p[value]}' for key, value in {
            'bg': 'mSurface', 'card': 'mSurfaceVariant', 'fg': 'mOnSurface', 'muted': 'mOnSurfaceVariant',
            'p': 'mPrimary', 's': 'mSecondary', 't': 'mTertiary', 'ink': 'mOnPrimary'}.items())
        swatches = ''.join(f'<button class="swatch" data-color="{p[key]}" style="--swatch:{p[key]}">'
                           f'<i></i><span>{label}<br><b>{p[key]}</b></span></button>'
                           for label, key in [('Primary', 'mPrimary'), ('Secondary', 'mSecondary'),
                                              ('Tertiary', 'mTertiary'), ('Background', 'mSurface')])
        cards.append(f'''<article style="{variables}" data-search="{html.escape(row['name'] + ' ' + row['wallpaper'], quote=True)}">
<img loading="lazy" src="data:image/jpeg;base64,{thumbnail}" alt="{html.escape(row['wallpaper'], quote=True)}">
<div class="body"><h2>{html.escape(row['name'])}</h2><p class="filename">{html.escape(row['wallpaper'])}{' (image currently absent)' if row['wallpaper'] not in files else ''}</p>
<div class="shell"><span class="active">●</span><span>◈ &nbsp; 1 &nbsp; 2 &nbsp; 3</span><strong>20:26</strong><span class="secondary">♫ &nbsp; ▰</span></div>
<div class="window"><div class="tabs"><b>Terminal</b><span>Files</span><span>Settings</span></div><p><span class="primary">❯</span> colors with attitude<span class="cursor"> ▌</span></p><small>Readable text · vivid focus · deep surfaces</small></div>
<div class="swatches">{swatches}</div><p class="palette-id">{html.escape(name)}</p></div></article>''')
        table.append('| ' + ' | '.join([f'`{row["wallpaper"]}`', row['name'],
                                      *[f'`{p[k]}`' for k in ('mPrimary', 'mSecondary', 'mTertiary', 'mSurface')]]) + ' |')
    write_if_changed(ROOT / 'manifest.json', json.dumps(manifest, indent=2) + '\n')
    write_if_changed(ROOT / 'COLOR-CODES.md', f'# Bold wallpaper palettes\n\n{len(rows)} visually curated dark palettes for Noctalia v5. '
        'These are the final exported hex values. Each JSON also contains all 16 shell roles and a full ANSI terminal palette.\n\n'
        + '\n'.join(table) + '\n')
    page = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Exotic — PALETTE_COUNT wallpaper palettes</title><style>
*{box-sizing:border-box}body{margin:0;background:#080910;color:#f4f0ff;font:15px system-ui,sans-serif}header{max-width:1600px;margin:auto;padding:48px 28px 24px}h1{font-size:clamp(32px,5vw,62px);letter-spacing:-.05em;margin:0 0 12px}header p{color:#bab6cf;max-width:760px;line-height:1.6}input{background:#171925;border:1px solid #53516a;border-radius:10px;color:white;padding:14px;width:min(100%,540px);font:inherit}label{display:inline-flex;align-items:center;gap:8px;margin-left:16px}label input{width:auto}main{max-width:1600px;margin:auto;padding:12px 28px 48px;display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,350px),1fr));gap:24px}article{background:var(--bg);color:var(--fg);border:1px solid var(--card);border-radius:16px;overflow:hidden}article[hidden]{display:none}article img{width:100%;height:230px;object-fit:contain;background:#050609}.body{padding:20px}h2{font-size:22px;letter-spacing:-.02em;margin:0 0 7px}.filename{color:var(--muted);font:11px ui-monospace,monospace;overflow-wrap:anywhere;min-height:30px}.shell{display:flex;align-items:center;justify-content:space-between;background:var(--card);padding:12px;border-radius:30px;font-size:13px;margin:18px 0}.active{color:var(--p)}.secondary{color:var(--s)}.window{border:2px solid var(--p);border-radius:10px;padding:12px;background:var(--bg);font:12px ui-monospace,monospace}.tabs{display:flex;gap:20px;color:var(--muted);padding:0 0 10px}.tabs b{color:var(--p)}.primary,.cursor{color:var(--p)}.window small{color:var(--muted);font-size:10px}.swatches{display:grid;grid-template-columns:repeat(2,1fr);gap:10px;margin-top:16px}.swatch{display:flex;gap:9px;align-items:center;background:var(--card);color:var(--fg);border:0;border-radius:8px;padding:10px;cursor:pointer;text-align:left;font:11px system-ui}.swatch i{display:block;flex-shrink:0;width:30px;height:34px;border-radius:6px;background:var(--swatch);border:1px solid #ffffff30}.swatch b{font:12px ui-monospace,monospace}.palette-id{color:var(--muted);font:10px ui-monospace,monospace;margin-bottom:0}#status{min-height:24px;color:#c5ff56}.oled article{--bg:#000!important}.oled .window{background:#000}.oled .shell{background:#0c0c0c}a{color:#b9a2ff}</style>
<header><h1>EXOTIC / PALETTE_COUNT</h1><p>Hand-picked, saturated accents for every wallpaper. Scarlet, ultraviolet, acid green, liquid cyan, and molten gold on deep surfaces. These are illustrative UI previews. Click a swatch to copy its hex code.</p><input id="search" aria-label="Search wallpapers or themes" placeholder="Search filename or theme…"><label><input type="checkbox" id="oled" checked>OLED background preview</label><p>Your Noctalia configuration uses pure black. Turn off the preview toggle to see each palette’s tinted background. App templates and transparency can render differently.</p><div id="status" role="status">PALETTE_COUNT palettes</div></header><main>'''
    script = '''</main><script>
const cards=[...document.querySelectorAll('article')], status=document.querySelector('#status');
document.querySelector('#search').addEventListener('input',e=>{let count=0;for(const c of cards){c.hidden=!c.dataset.search.toLowerCase().includes(e.target.value.toLowerCase());if(!c.hidden)count++}status.textContent=count+' palettes'});
document.querySelector('#oled').addEventListener('change',e=>document.body.classList.toggle('oled',e.target.checked));document.body.classList.add('oled');
document.querySelectorAll('[data-color]').forEach(b=>b.addEventListener('click',async()=>{try{await navigator.clipboard.writeText(b.dataset.color);status.textContent='Copied '+b.dataset.color}catch{status.textContent='Hex code: '+b.dataset.color}}));
</script></html>'''
    write_if_changed(ROOT / 'preview.html', page.replace('PALETTE_COUNT', str(len(rows))) + ''.join(cards) + script)
    print(f'Built {len(rows)} palettes, manifest, color-code table, and offline preview.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--list-new', action='store_true', help='Recursively list wallpaper paths missing from the manifest; do not write files')
    args = parser.parse_args()
    if args.list_new:
        for filename in list_new():
            print(filename)
    else:
        build()
