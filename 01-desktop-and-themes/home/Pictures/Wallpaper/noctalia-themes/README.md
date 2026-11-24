# Exotic wallpaper themes

194 individually curated palettes, covering all 187 current wallpapers recursively, including all 107 images in `karina/`. Seven palettes for currently absent wallpapers are retained. Every new wallpaper was visually reviewed. The accents favor saturated scarlet, electric cyan, ultraviolet, acid green, coral, and gold, paired with dark tinted surfaces.

The revised palettes draw their accents from recognizable details in each image. The 80 wallpapers in the main folder include scarlet and warm white for the Spider-Man mask, cyan and fuchsia for the neon city, and gold and blue for the sunlit dunes. The 107 palettes in `karina/` take their cues from stage lighting, clothes, makeup, and scenery. Neutral portraits use warm ivory, silver, and blue steel.

Open [preview.html](preview.html) in a browser to see every wallpaper beside its palette and an illustrative shell preview. Search by wallpaper filename or theme name. Click any swatch to copy its hex code. The preview is self-contained and works offline.

[COLOR-CODES.md](COLOR-CODES.md) lists the final primary, secondary, tertiary, and background hex codes for every image. [palettes/](palettes/) contains the complete Noctalia JSON files, including 16 shell color roles and full normal/bright terminal colors.

## Activate

Run this in a terminal in your normal desktop session:

```bash
python3 /home/crispy146/Pictures/Wallpaper/noctalia-themes/install.py
```

The installer targets your installed Noctalia v5. It copies palettes to `~/.config/noctalia/palettes/`, installs a small selector under `~/.config/noctalia/exotic-themes/`, and adds startup and wallpaper-change hooks in `~/.config/noctalia/zz-exotic-wallpapers.toml`. It reloads Noctalia and applies the palette for the current wallpaper. If IPC is unavailable, the startup hook applies it when Noctalia next starts.

It also creates matching folder icon themes under `~/.local/share/icons/Exotic-Folders-*`. The wallpaper hook switches both the palette and the folder icon theme. If you installed the earlier version of this bundle, run the same installation command once more to add folder icon switching.

Existing startup and wallpaper commands are preserved. If GUI hook overrides would mask the new file, their commands are included and those two overrides are removed. An installation receipt records replaced files and the previous palette selection for undo. Reinstalling does not duplicate the hook.

Your current dark mode, pure-black setting, wallpaper rotation, transparency, and enabled app templates are retained. The palettes provide a dark variant; Noctalia also uses that variant if switched to light mode. Your enabled Niri template carries the selected primary accent into focus rings, borders, and tab indicators. Other enabled app templates use the same palette.

For `karina/09_champagne.png`, **Gilded Obsidian** takes its gold and pearl tones from the gown and its warm shadow from the room.

| Role | Hex |
|---|---|
| Primary / champagne gold | `#FFD079` |
| Secondary / warm pearl | `#FFE2B0` |
| Tertiary / dusty rose | `#EAA190` |
| Tinted background | `#1C140E` |

Your existing pure-black setting can replace the tinted backgrounds with black. The preview includes an OLED toggle; its shell layout is illustrative rather than a screenshot of Noctalia.

## Undo

```bash
python3 /home/crispy146/Pictures/Wallpaper/noctalia-themes/install.py --uninstall
```

This restores recorded files and hook overrides, removes the generated files that have not been edited, and restores the previous palette through Noctalia IPC. It also restores the previous icon theme if the selected theme is one managed by this bundle, and removes or restores the managed icon files. If Noctalia is unavailable, the installer prints the command to restore the palette when it is running. Unrelated settings changed since installation are retained.

## Nautilus folder colors

Your original icon theme is Adwaita. Its regular folder SVGs contain fixed blue fills, so updating GTK app colors does not recolor those images. The installer makes variants of the installed Adwaita folder shapes with each palette's exact primary accent on the front panel and darker accents on the back and emblems. Standard folders, Home, Desktop, Documents, Downloads, Music, Pictures, Videos, Templates, and shared/project folders are covered. Symbolic sidebar icons continue to follow GTK's foreground styling.

Each generated theme inherits your original icon theme for other icons. Switching uses `org.gnome.desktop.interface icon-theme`, allowing GTK applications to refresh without closing Nautilus. Per-folder custom icons and third-party applications that do not follow the GTK icon setting can behave differently. See the [GTK icon-theme documentation](https://docs.gtk.org/gtk4/class.IconTheme.html) and [icon-theme inheritance specification](https://specifications.freedesktop.org/icon-theme/).

This integration uses the Adwaita SVG assets already installed on your system; it does not require Papirus or administrator access. Source SVGs are credited to the [GNOME Adwaita icon theme](https://gitlab.gnome.org/GNOME/adwaita-icon-theme), licensed under CC-BY-SA-3.0 OR LGPL-3.0-only. The generated theme folders include attribution. SVG colors are changed; geometry is preserved.

[folder-icons-validation.json](folder-icons-validation.json) records native GTK lookup checks for the original 138 palettes at five sizes, inherited file-type icons, and mocked wallpaper/setting changes. [validation-additions-2026-10-27.json](validation-additions-2026-10-27.json) separately records XML, primary-color, inheritance, and isolated installation checks for the 45 additions; native GTK lookup checks were not repeated for these additions. Actual Nautilus refresh could not be observed in this restricted session; activation must be performed in your desktop terminal.

## Palette selection

The selector uses `NOCTALIA_WALLPAPER_PATH` from the wallpaper hook. At startup it queries `noctalia msg wallpaper-get`. Absolute paths, relative subfolder paths, filenames, and local `file://` paths are supported. Exact paths take priority. Relative subfolder paths also allow relocating the wallpaper folder. A bare filename is matched only when it is unique, preventing same-named wallpapers in different folders from selecting the wrong palette.

All 187 current wallpapers have curated entries. A new or renamed wallpaper without a mapping keeps the last selected palette. Noctalia has a global palette; with different wallpapers on several monitors, the most recently processed wallpaper event selects it.

`karina/02_backstage_stripes.jpg` maps to **Backstage Electrum**, with warm gold `#FFE09B`, ivory `#F3E5CA`, and steel blue `#8BA9E4` on a navy-black surface `#0C111B`.

Inspect a selection without changing settings:

```bash
python3 /home/crispy146/Pictures/Wallpaper/noctalia-themes/apply.py 09_champagne.png --dry-run
```

## Customize

To find wallpapers that do not yet have a palette, run:

```bash
python3 /home/crispy146/Pictures/Wallpaper/noctalia-themes/build.py --list-new
```

This recursively compares relative image paths with the manifest, excluding hidden directories and the theme bundle itself. A replacement image using an existing path is not detected. Future agents should follow [the workspace instructions](../AGENTS.md), inspect only the new images, and append their palette rows using paths such as `karina/photo.jpg`. Existing top-level curated rows continue to work after moving their images into a subfolder when the filename is unique. Ambiguous moves require explicit paths in the table. Palettes and cached previews for absent images are retained. Building skips identical existing palette files; reinstalling likewise skips identical installed files. The shared manifest, preview, and color-code table are refreshed to include the additions. New themes require this update once; the wallpaper hook then selects them automatically.

Edit `curated-palettes.tsv`, then run:

```bash
python3 /home/crispy146/Pictures/Wallpaper/noctalia-themes/build.py
python3 /home/crispy146/Pictures/Wallpaper/noctalia-themes/install.py
```

Building requires Python 3.11+ and Pillow; installing and switching use Python's standard library and Noctalia. The builder adjusts an accent only when needed for readable contrast, derives supporting shell colors, and creates recognizable ANSI terminal colors. The exported JSON and color-code table contain the final values.

## Validation

[validation-main-refresh-2026-11-21.json](validation-main-refresh-2026-11-21.json) covers the 80 revised main folder palettes. All loaded in Noctalia 5.6.0 and rendered through Niri's shipped template. The lowest of 560 shell text/background contrast ratios was 5.44:1. An isolated install verified wallpaper selection and matching folder icon colors for all 80 images.

[validation-karina-refresh-2026-11-21.json](validation-karina-refresh-2026-11-21.json) covers the current 107 revised `karina/` palettes. All loaded in Noctalia 5.6.0 and rendered through its Niri template. The lowest of 749 shell text/background contrast ratios was 5.50:1. An isolated install verified wallpaper selection and the matching folder icon accent for all 107 images. The remaining reports cover earlier versions of the collection.

See [validation-report.json](validation-report.json) for the original 138 palettes. All 138 were loaded through the installed Noctalia 5.3 CLI, and all 138 rendered through its shipped Niri template with the expected accent and error colors. All seven shell text/background role pairs exceed 4.5:1 contrast; the lowest measured ratio in that batch is 5.44:1 on opaque colors. Transparency can affect the displayed contrast.

The 45 additions are covered separately by [validation-additions-2026-10-27.json](validation-additions-2026-10-27.json). All 45 loaded through Noctalia 5.4.0 and rendered through its shipped Niri template with the expected accent and error colors. Their 315 shell text/background pairs exceed 4.5:1; the lowest ratio is 5.40:1 on opaque colors. The original 138 palette files retained their contents and modification times. An isolated installation under `/tmp` included all 183 mappings and matching folder icon themes; a repeated installation preserved file contents, modification times, and existing hooks without duplication. The additions have not been installed or activated in the live desktop configuration; run the installation command above to deploy them.

The 11 new subfolder palettes and recursive integration are covered by [validation-subfolders-2026-11-21.json](validation-subfolders-2026-11-21.json). Validation includes native palette loading and Niri rendering, all 77 shell text/background pairs, preservation of the existing 183 palette files and their modification times, folder icon XML and primary colors, recursive discovery and ambiguous-name regression checks, and an isolated repeated installation. The installed selector is checked for every current image using absolute paths, relative paths, and file URIs. These checks use temporary configuration, state, cache, and icon directories under `/tmp`. Deployment to the live desktop configuration remains pending.

Installation, repeated installation, preservation of existing multiline hooks, preservation of unrelated settings, and uninstall were exercised in temporary directories. The actual selector was tested with a mocked IPC transport, including skipping redundant palette changes. Live desktop switching was not exercised because Noctalia IPC is unavailable in this session.

Format and integration references: [Noctalia custom palettes](https://docs.noctalia.dev/noctalia/theming/palette/), [wallpaper hooks](https://docs.noctalia.dev/noctalia/automation/hooks/), and [palette IPC](https://docs.noctalia.dev/noctalia/ipc/media-and-ui/).
