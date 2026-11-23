MY SETUP
CachyOS workstation settings captured on 23 November 2026

This folder records the software added after CachyOS was installed and keeps
copies of readable configuration and customizations. It also includes changes
to tools that came with the machine, such as Niri, Noctalia, and UFW.

START HERE

  01-desktop-and-themes    Desktop, keybindings, appearance, audio routing
  02-shell-and-terminal    Shell startup, prompts, terminals, and CLI tools
  03-editors-and-development
                           Neovim, developer tooling, and coding assistants
  04-apps-and-browsers     Native app preferences and local launchers
  05-flatpak-apps          Sandboxed app preferences and Flatpak sources
  06-system               System-wide settings and package configuration
  07-existing-backups     Older configs and existing setup references
  08-inventory            Package lists, original paths, and coverage details

Every backed-up file is visible in a file manager with hidden files off.
Leading dots were removed from names inside this folder. For example,
01-desktop-and-themes/home/config/niri/config.kdl comes from the original
~/.config/niri/config.kdl and 02-shell-and-terminal/home/zshrc comes
from ~/.zshrc. The explanations below use the original names. For the
exact original path of any file, see the Original path column in
08-inventory/files.tsv. Some entries are exports, as described below.

01  DESKTOP AND THEMES

Niri loads config.kdl and the fragments in .config/niri/cfg/. The fragments
define monitor layout, input, gestures and animations, window rules, keyboard
shortcuts, layouts, and startup commands. The touchpad-toggle script in
.local/bin/ works with the saved Niri input configuration.

Noctalia takes shell-level settings and custom theme definitions from
.config/noctalia/. Its active panel, widget, palette, and wallpaper settings
are in .local/state/noctalia/settings.toml and related TOML/JSON files.
Restore those home paths together for the same layout. The template scripts
generate app themes, including GTK/Qt colors, terminal palettes, and Zen CSS.
The folder icon themes live under .local/share/icons. Their index.theme files
tell desktop apps how to find and inherit the icons. The working copies of
Noctalia plugins and their settings are in .local/state/noctalia/plugins/.
The setup also keeps generated colors for Labwc, Sway, Scroll, Mango,
Hyprland, Umbriel, btop, and CAVA where they were present on disk.

Noctalia refers to images in ~/Pictures/Wallpaper. The media library is
outside this config backup. See 08-inventory/wallpaper-dependencies.tsv for
the paths the recorded themes and wallpaper settings depend on.

The dconf-desktop-settings.ini export contains the selected GNOME/GTK and
Nautilus settings. After reviewing it, load the whole export with
dconf load / < dconf-desktop-settings.ini from inside this category.
The MIME association list maps file types to launchers. WirePlumber route
and stream files hold audio device routes and per-stream preferences.

02  SHELL AND TERMINAL

Bash reads .bash_profile on login and .bashrc for interactive behavior. Zsh
reads .zshrc for PATH, prompt setup, completions, and tool integrations.
.p10k.zsh contains Powerlevel10k prompt options. Fish reads config.fish and
its conf.d snippets. fish_variables stores persistent Fish variables.

Starship and Atuin load their TOML settings for prompt and search behavior.
The terminal folders hold Ghostty, Kitty, Foot, Alacritty, and WezTerm
settings or theme pieces. Fastfetch's JSONC sets system-info presentation.
Yazi uses its TOML files and flavors for file manager colors and behavior,
and fzf theme snippets define fuzzy-finder colors. The flatpak-update
script runs updates. The .npmrc is npm's user-level options file.

03  EDITORS AND DEVELOPMENT

Neovim starts with init.lua and loads the Lua modules under .config/nvim/lua.
lazy-lock.json records the plugin revisions and lazyvim.json records enabled
LazyVim extras. The bundled scripts and formatter settings follow the main
Neovim configuration. Helix theme files, Micro settings and bindings, and
Lazygit preferences each live under their own .config directories.

.gitconfig holds Git's global settings. Rustup's settings select the toolchain
and installed Cargo binaries are listed in the inventory when available.
GnuPG's common.conf controls shared GnuPG behavior.

Codex, Claude Code, OpenCode, Antigravity, and CodexBar have separate files
for their model and UI preferences, integrations, plugin declarations,
themes, and any user-installed commands or skills found during the capture.
Codex and OpenCode may refer to installed packages, configured services, or
absolute paths. Reinstall the tools and review those references on a new
machine. The Claude plugin records identify sources and installed versions.
OpenCode's package manifests record its install-time dependencies.

04  NATIVE APPS AND BROWSERS

LM Studio settings cover its UI, local model behavior, and MCP server
definitions. The home pointer locates its data folder and model files are
stored separately by LM Studio. LocalSend uses a JSON preferences file
for the display alias, colors, and window placement. Its security identity
will need to be generated or configured by the app.

VLC, Gwenview, Shelly, Soloist, SpoTUI, Prism Launcher, and CliXaD have
preferences where a readable file was found. LibreOffice uses its user
registry for application preferences. Leaf's local script and desktop
entry connect Markdown files to the viewer. The Helium browser and Codex
desktop preference copies contain selected settings. Merge those into a
fresh profile or apply them in the app. Wine's .reg files hold the saved
registry settings for the default Wine prefix.

Steam libraryfolders.vdf records drive and library paths. The Steam export
is a reference for global compatibility and controller preferences. Apply
them in Steam's settings and verify library paths on the destination.

05  FLATPAK APPS

The copies under home/var/app come from each Flatpak app's ~/.var/app sandbox.
Zen's profile settings include its keybindings, browser containers, themes,
and custom CSS. Review profiles.ini and map settings into the active profile
on the destination. Tor Browser Launcher and the Tor Browser profile have
separate settings. Telegram has custom shortcut definitions and uses the
Noctalia Telegram theme in 04-apps-and-browsers. Spotify's global prefs
and Obsidian's application preferences are included.

Obsidian's separate vault tree retains its .obsidian settings and installed
plugin files. Put it at the root of the existing vault. The GeForce NOW
copies contain selected window and streaming settings. The Twintail JSON
export records the launcher's settings and selected runner, prefix, and
game options. Use it to re-enter options in Twintail.

Flatpak reads remotes from its system and user repositories. Use
08-inventory/flatpak-remotes.txt and flatpak-apps.txt to add the correct
remotes, then reinstall the apps with the recorded scope.

06  SYSTEM CONFIGURATION

pacman.conf and pacman.d/ set pacman repositories and mirrors, including
the ChatGPT repository. Paru's own options are in paru.conf. ChatGPT's
AppArmor profile and /etc/default options configure its packaged launcher.

greetd uses /etc/greetd/config.toml to select the graphical greeter or
session. Its PAM file controls the login authentication policy. UFW's
user.rules, user6.rules, and ufw.conf record host firewall behavior.
create_ap.conf controls the hotspot and vnstat.conf sets traffic monitoring.
systemd-links.tsv records the system and user unit links found on disk.
Recreate required links with systemctl enable after the services are installed.

GRUB, mkinitcpio, Plymouth, and the locale files depend on system layout or
hardware. Use these as a reference and compare them against the destination
before making changes. System files need root ownership and each package's
expected permissions. The modes inside this backup keep the backup private.

07  EXISTING BACKUPS

This section holds the pre-existing Neovim copies, old shell and touchpad
settings, Noctalia Wi-Fi plugin backup, pacman .pacnew and mirror backups,
greetd PAM history, and the existing install-arch.sh. Compare these with the
active copies if you need to recover an older setting. The installer script
is a record of the earlier setup procedure.

08  INVENTORY AND COVERAGE

pacman-post-install.tsv lists 328 currently installed packages first seen
after the CachyOS installer finished, including dependencies. Use the
Install reason column to identify explicitly installed packages. The full
list in pacman-installed.tsv includes installer packages and version,
source, and installation reason. pacman-removed.tsv lists packages removed
since setup that are absent now. The baseline is the set of packages
installed before the first interactive pacman command on 30 September 2026
at 22:01:11 local time. For system config selection, package backup hashes
were compared against readable /etc files. Package ownership, the installer
log, and filesystem timestamps provided other evidence.

flatpak-apps.txt lists the seven installed Flatpak apps. local-tools.tsv
covers local scripts, binaries, and directories outside the native/Flatpak
package lists. files.tsv maps each of the 7,480 copied files and exports to
its original path and records its purpose, size, and SHA-256 checksum.
Most of those files are individual Noctalia folder icons and related
theme assets.

This backup omits credentials, keys, browser sign-in/session data, caches,
application history, and bulk data such as games, downloads, and the
wallpaper media library. redactions.tsv lists changed fields or preference
exports. Lines marked REENTER_ON_RESTORE require the original value to use
that setting. skipped-and-limits.tsv records specific paths omitted or
inaccessible, including some system folders and the installer snapshot.
The per-user baseline is best-effort and uses /etc/skel comparisons where
possible. A full installation snapshot was unavailable for verification.

RESTORE ORDER

1. Read the package inventories and install the software you want.
2. Close each app before restoring its preferences. Back up its current
   settings and look up each copy in 08-inventory/files.tsv. The Backup
   path column shows where to find the copy. Restore it to the exact
   Original path, including any dots on file and folder names.
3. Merge selected preference exports into a fresh profile, or re-enter the
   settings in the relevant app. Set credentials through that app as needed.
4. Compare system configuration with the destination's defaults. Apply
   changes individually and check paths, permissions, hardware names, and
   enabled services. Log out and back in after desktop or shell changes.
