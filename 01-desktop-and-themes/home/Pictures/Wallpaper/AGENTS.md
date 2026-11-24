# Wallpaper themes

This folder contains the user's wallpapers and `noctalia-themes/`, a collection of visually curated Noctalia v5 palettes. The user's preference is **bold, exotic, saturated accents** with readable text and dark surfaces. Preserve the existing palettes when adding themes for new wallpapers.

## Find new wallpapers

Run from this folder:

```bash
python3 noctalia-themes/build.py --list-new
```

This read-only command recursively compares supported image paths in this folder and its subdirectories with `noctalia-themes/manifest.json`. Hidden directories and `noctalia-themes/` are excluded. Empty output means every current relative path is mapped. Detection uses paths, not modification times. An image replaced under an existing path needs explicit review; it is not detected as new. A moved image may be listed until the next build; the builder preserves a legacy top-level curated row when its filename has one unambiguous match in a subfolder.

## Theme only the new wallpapers

1. Read `noctalia-themes/README.md`. Visually inspect every new image using an image-viewing tool. Choose a distinctive name and three saturated accents related to that image, plus a deep background color. Do not simply reuse an automatic wallpaper extraction.
2. Append one row per new image to `noctalia-themes/curated-palettes.tsv`. Preserve existing rows. Its tab-separated columns are `wallpaper`, `name`, `primary`, `secondary`, `tertiary`, and `surface`; colors use `#RRGGBB`. Use relative paths such as `karina/photo.jpg` for subfolder images. Names must produce unique palette filenames. Resolve ambiguous moved filenames with explicit relative paths; never assign a palette by ambiguous basename alone. Keep palettes for temporarily absent wallpapers; the builder retains their prior preview thumbnails when available.
3. Run `python3 noctalia-themes/build.py`. It generates the new palettes and refreshes the shared manifest, hex-code table, and searchable preview. Identical existing palette files are not rewritten. Do not change the shared palette-generation algorithm to add a wallpaper. Verify existing palette files retain their content and modification times.
4. Validate only the new palettes with the installed Noctalia CLI, for example `noctalia theme --theme-json noctalia-themes/palettes/Exotic-NEW-NAME.json --dark`. Check all seven shell text/background pairs are at least 4.5:1 using the existing `contrast` helper. Render the new palette through the shipped Niri template if it is available. Keep test outputs and isolated Noctalia config/state/cache under `/tmp`.
5. Run `--list-new` again to confirm there are no unmapped new images. Keep validation claims accurate: the original `validation-report.json` covers the original 138 palettes. Record validation of additions separately or update the report only for checks actually performed. Update count-specific README wording as needed.
6. Deploy the updated manifest and new palette files using `python3 noctalia-themes/install.py` if the session can write the user's Noctalia configuration. Reinstalling preserves hooks without duplicating them and skips identical installed files. If config writes or live IPC are unavailable, finish all local work and give the user that installation command. Do not claim activation without confirming it.

The runtime wallpaper hook selects existing curated palettes; it does not generate new ones. Once an added palette and updated manifest are installed, switching to that wallpaper selects its palette automatically. Noctalia uses a global palette, so the most recently processed monitor wallpaper event selects the palette.

The installer also generates inherited Adwaita folder icon themes from the palette primary colors. `apply.py` calls `folder_icons.py` to select the matching icon theme through GSettings after selecting the Noctalia palette. Preserve this integration when adding wallpapers. Run the installer after building additions so the new folder icon variant and mapping are installed too. Existing icon files are skipped when identical, and the previous icon theme is recorded for uninstall.

Do not modify the wallpaper images or the user's Niri layout, transparency, dark-mode preference, or app-template settings as part of adding a theme. Do not regenerate or redesign existing themes unless the user requests it.
