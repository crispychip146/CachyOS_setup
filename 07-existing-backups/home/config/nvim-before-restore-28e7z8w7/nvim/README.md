# Your Neovim guide

Open this guide with `:NvimGuide` or **Space ?**.
Configuration lives in `~/.config/nvim`. Only Neovim's configuration and its own
data/cache/state are involved. Shell, terminal and system settings are unchanged.

## Start here

```sh
cd /path/to/your/project
nvim .
```

Use `nvim` for a minimal “nvim” screen with the file explorer open in your current
directory. `nvim .` opens the same layout; `nvim path/to/file` edits a specific file.
**Space** is the leader key: press and release it, then press the remaining keys.
For example, **Space f f** finds files. Pause after Space to see the command menu.
Uppercase letters mean Shift plus that letter. Most shortcuts use Normal mode.

### Required language tools

The required languages are C, C++, Python, Rust, Java, JavaScript, CSS and HTML.
Each has an explicit formatter. Installed clang-format, Ruff, rustfmt and Prettier
cover all eight now; Java uses clang-format until Google Java Format is installed.
Python and web language servers have also been installed since the initial setup.
Rust's server and Java's server/runtime still require downloads in this session.

1. Run `:NvimToolsInstall` when you have internet access. It installs missing
   servers, Google Java Format and the required syntax parsers, and downloads a
   private Java JDK if no suitable Java is available.
2. Open `:Mason` (**Space c m**) to watch installations finish.
3. Restart Neovim, then run `:NvimTools` (**Space c T**) to check availability.
4. Open a source file. **Space c l** inspects its language server;
   `:ConformInfo` inspects its formatter.

Tool downloads are explicit so opening a file stays quiet offline. Mason tools stay
under `~/.local/share/nvim/mason`; the private JDK stays under
`~/.local/share/nvim/java/jdk`. Downloads use checksum verification for the JDK.
No system Java, shell PATH or global npm/pip installation is changed.
A project may still need its own dependencies or Python environment.
Use `:MasonLog` if a download fails.

## AI chat with your existing accounts

The workspace opens with the file explorer on the left, your code in the middle,
and CodeCompanion chat on the right. The explorer uses 30 columns and chat uses
30% of the terminal width. Startup keeps focus in the code window. The plugin is
pinned to v20.0.1 so its configuration stays consistent.

Run the installer once from your terminal, then restart Neovim:

```sh
bash ~/.config/nvim/scripts/install-chat-tools.sh
```

It installs CodeCompanion and the `codex-acp` and `claude-agent-acp` bridges.
Bridge executables live in `~/.local/bin`; plugins live in Neovim's data directory.
The installer requires network access to GitHub and npm. It does not sign in or
submit a prompt. If a download fails, rerun it when the network is available.

The default chat provider is Codex, configured to use ChatGPT sign-in. To sign in
if needed, run `codex login` in your terminal and choose your ChatGPT account.
For Claude, run `claude auth login` and sign in with your Claude subscription.
Your plan must include access to the corresponding coding agent; its usage limits
still apply. The chat panel uses these agents and their available models.

| Shortcut / command | Action |
| ------------------ | ------ |
| **Space a a** | Show or hide chat; reopening keeps the conversation |
| **Space a c** | Start a new Codex chat using your ChatGPT account |
| **Space a l** | Start a new Claude Code chat using your Claude account |
| **Space a p** | Open AI actions |
| **Space a v** in Visual mode | Add selected code to chat |
| **ga** in chat Normal mode | Choose a provider and model |
| **Space e** | Toggle the file explorer |
| **Ctrl-h / Ctrl-l** in Normal mode | Move between explorer, code, and chat |
| **i** in chat | Type a message |
| **Ctrl-s** in chat Insert mode / **Enter** in chat Normal mode | Send the message |
| **Ctrl-c** in chat | Hide the chat |
| **q** in chat Normal mode | Stop the current response |
| **?** in chat Normal mode | Show available chat shortcuts |
| `:CodeCompanionChat adapter=codex` | Open a new Codex chat |
| `:CodeCompanionChat adapter=claude_code` | Open a new Claude chat |
| `:checkhealth codecompanion` | Check the chat plugin and dependencies |

Type your message on a line **below** the `## Me` heading, leaving that heading
unchanged. Press **Ctrl-s**, or **Esc** followed by **Enter**, to send it. If you
see "No messages to submit", start a fresh chat with **Space a c** and type below
its heading. The chat shortcut places the cursor at the end of the input area,
and the window header shows the send shortcut.

Include `#{buffer}` in your message to share the current source buffer, or use
`/file` to attach a file. CodeCompanion also supports HTTP providers such as
OpenAI, Anthropic, Gemini, OpenRouter, and local Ollama. Those connections use
their own credentials or local servers; this configuration defaults to account
sign-in through the agents. Use **ga** to choose among the available connections.

Sign-in credentials stay in the agents' own storage, outside this configuration
repository. Do not copy account credential files into the GitHub backup.

References: [CodeCompanion adapters](https://codecompanion.olimorris.dev/configuration/adapters-acp),
[Codex sign-in](https://learn.chatgpt.com/docs/auth?surface=cli),
[Claude Code sign-in](https://code.claude.com/docs/en/authentication).

## First ten minutes

1. **Space Space**: type part of a filename, select with arrows, press Enter.
2. **i**: enter Insert mode and type. **Esc** returns to Normal mode.
3. **Ctrl-s**: save; available formatters run on save.
4. **Space /**: search text across the project.
5. **Space e**: open the file explorer.
6. **K**: documentation under cursor. **gd**: definition once its server is
   installed. **Ctrl-o**: return to where you were.
7. **Space ?**: return here.

## Vim basics

| Key / command               | Action                                                                   |
| --------------------------- | ------------------------------------------------------------------------ |
| `i`, `a`, `o`               | Insert before cursor, after cursor, or on a new line below               |
| `Esc`                       | Return to Normal mode; clear search highlighting                         |
| `h j k l`                   | Left, down, up, right; arrows and mouse also work                        |
| `w`, `b`, `0`, `$`          | Next word, previous word, line start, line end                           |
| `gg`, `G`                   | File start / end                                                         |
| `5j`, `3w`                  | Repeat movement; relative line numbers help count                        |
| `Ctrl-d`, `Ctrl-u`          | Half page down / up and center cursor                                    |
| `v`, `V`, `Ctrl-v`          | Select characters, lines, or a rectangular block                         |
| `y`, `yy`, `p`              | Copy selection, copy line, paste                                         |
| `d`, `dd`, `ciw`            | Delete selection, delete line, change word under cursor                  |
| `u`, `Ctrl-r`               | Undo / redo; undo persists across restarts                               |
| `/text`, `n`, `N`           | Search this file, next / previous match                                  |
| `gcc`, `gc` in a selection  | Toggle line / selection comments                                         |
| `>` / `<` in a selection    | Indent / unindent and keep selection                                     |
| `Alt-j`, `Alt-k`            | Move line or selection down / up                                         |
| `Ctrl-s`, `Space f s`, `:w` | Save current file                                                        |
| `:q`, `:wq`, `:qa`          | Close window, save and close, quit all windows                           |
| `:q!`                       | Close this window discarding unsaved changes if no other window shows it |
| `:Tutor`                    | Built-in interactive Vim tutorial                                        |

Copy/paste uses the system clipboard in a normal desktop session. Pasting over a
Visual selection preserves copied text for repeated pastes. Over SSH, clipboard
integration depends on your terminal's OSC 52 support.

## Find files and navigate

| Shortcut                             | Action                                       |
| ------------------------------------ | -------------------------------------------- |
| `Space Space`, `Space f f`, `Ctrl-p` | Find project file                            |
| `Space /`, `Space s g`               | Search project text live                     |
| `Space s w`                          | Search word under cursor or selected text    |
| `Space s b`                          | Search lines in current buffer               |
| `Space f r`, `Space f p`             | Recent files / projects from recent files    |
| `Space s z`                          | Directory history from your installed zoxide |
| `Space f c`                          | Find Neovim config files                     |
| `Space e`, `Space E`                 | Explorer at project root / working directory |
| `Space ,`                            | Pick open buffer                             |
| `Shift-h`, `Shift-l`                 | Previous / next buffer                       |
| `Space b d`                          | Close buffer, preserving split layout        |
| `Space s R`                          | Resume last picker                           |
| `Space s k`                          | Search key bindings                          |

Pickers show dotfiles and respect Git ignore rules. Type to filter, use
**Ctrl-n / Ctrl-p** or arrows to select, and **Enter** to open. **Esc** leaves
Insert mode; **q** closes. **Alt-h** toggles hidden files; **Alt-i** toggles ignored
files. **Ctrl-v / Ctrl-s** open a vertical / horizontal split. **Alt-c** switches
between project root and working directory.

Explorer: **Enter** opens/expands, **a** adds, **r** renames, **d** deletes,
**H** toggles hidden files, and **I** toggles ignored files. **?** shows help.
File actions operate on the selected path.

Project roots generally follow the language server or `.git`. `:pwd` shows the
working directory; `:cd /path` changes it. **Space f F** and **Space s G** search
the working directory instead of the detected project root.

## Completion and coding

Blink completion combines language servers, paths, snippets and open buffers.
It does not require an AI account. In Insert mode:

| Key                        | Action                                                    |
| -------------------------- | --------------------------------------------------------- |
| `Ctrl-space`               | Request completion / show documentation                   |
| `Ctrl-n`, `Ctrl-p`, arrows | Select next / previous suggestion                         |
| `Enter`                    | Accept selected suggestion; otherwise insert newline      |
| `Ctrl-y`                   | Accept suggestion, choosing first if none is selected     |
| `Ctrl-e`                   | Cancel completion                                         |
| `Tab`, `Shift-Tab`         | Next / previous snippet placeholder; otherwise normal Tab |

With a language server attached, in Normal mode:

| Shortcut                 | Action                                                  |
| ------------------------ | ------------------------------------------------------- |
| `gd`, `gr`, `gI`, `gy`   | Definition, references, implementation, type definition |
| `K`, `gK`                | Documentation / signature help                          |
| `Space c r`              | Rename symbol across project                            |
| `Space c a`, `Space c o` | Code actions / organize imports when supported          |
| `Space c d`              | Show line diagnostics                                   |
| `]d`, `[d`               | Next / previous diagnostic                              |
| `Space x x`, `Space x X` | Workspace / buffer diagnostic panel                     |
| `Space s s`, `Space s S` | File / workspace symbols                                |
| `Space u h`              | Toggle supported inlay hints                            |
| `Space c l`              | Inspect server configuration and attachment             |

Diagnostics wait while you type. Inlay hints start off. Path, snippet and buffer
completion work before language servers install.

### Configured languages

| Language                            | Server                                               | Formatter                                      |
| ----------------------------------- | ---------------------------------------------------- | ---------------------------------------------- |
| Lua / Neovim config                 | LuaLS + LazyDev API knowledge                        | StyLua                                         |
| Python                              | BasedPyright for types; Ruff for lint/import actions | Ruff                                           |
| Rust                                | rust-analyzer; Clippy checks                         | rustfmt                                        |
| Java                                | Eclipse JDTLS                                        | Google Java Format, with clang-format fallback |
| JavaScript / TypeScript / JSX / TSX | TypeScript language server                           | Prettier                                       |
| HTML / CSS / SCSS / Less            | VS Code HTML / CSS servers                           | Prettier                                       |
| JSON / JSONC                        | JSON language server                                 | Prettier                                       |
| YAML                                | YAML language server with schema discovery           | Prettier                                       |
| TOML                                | Taplo                                                | Taplo LSP fallback                             |
| Markdown                            | Marksman for links/navigation                        | Prettier                                       |
| Bash / shell                        | Bash language server + ShellCheck                    | shfmt                                          |
| C                                   | Existing system clangd                               | clang-format                                   |
| C++                                 | Existing system clangd                               | clang-format                                   |

Formatting is configured for all required languages. Missing Rust/Java servers
activate after installation and a restart. `:NvimToolsInstall` also installs
missing C++, Rust, Java and CSS syntax parsers. Regular syntax highlighting works
while those parsers are unavailable. Use `:NvimTools` for actual tool readiness.
For Python, activate your project's virtual environment **before** launching
Neovim, or configure its interpreter in your project's BasedPyright settings.
For C/C++, use your project's `compile_commands.json` for accurate navigation.
For Rust, launch from a Cargo project; the existing rustfmt toolchain is reused.
For Java, launch from a Maven/Gradle project for dependency-aware completion.
Each Java project gets its own JDTLS workspace under Neovim's data directory.
The managed JDK is Temurin 25; JDTLS requires at least Java 21. This runtime is
used only by Neovim's Java server. Your project's configured Java target remains
its own choice. Java's formatter fallback works even before a JDK is installed.

### Formatting

**Ctrl-s** saves and formats. **Space c f** formats manually, including selected
ranges when supported. **Space u f** toggles current-buffer formatting;
**Space u F** toggles the global default and clears this buffer's override.
Other buffer overrides still take precedence. `:ConformInfo` shows tools and logs.

LazyVim runs Conform once, with LSP fallback. Existing `.editorconfig`,
`.prettierrc`, `pyproject.toml` and similar project settings supply style rules.
Without those settings, tools use their defaults. Python indentation defaults to
four spaces; other files default to two unless overridden. Saving is explicit;
there is no focus-loss autosave or blanket whitespace-stripping hook.

Prettier uses Conform's temporary-file mode because stdin formatting returned
empty output with this machine's Neovim/Node combination. Conform removes the
temporary file afterward. Project configuration and selected-range formatting
have both been verified with this mode.

## PDF and Markdown reading

The document plugins are `pdfreader.nvim` and `render-markdown.nvim`. After their
first installation, restart Neovim. If downloading was blocked during setup, run
`:Lazy install` in your normal internet-connected terminal and wait for the
plugins and Telescope dependency to finish installing. Telescope is used by the
PDF reader's bookmark/history pickers; your normal file searches still use Snacks.
Missing plugins are installed explicitly, so an offline download cannot block the
startup screen. Restart after installation to activate document file handlers.

### PDFs

Open a PDF from the explorer, with `:edit /path/to/book.pdf`, or by launching
`nvim /path/to/book.pdf` in Ghostty. The reader displays pages inside Neovim.

| Key / command | Action |
| --- | --- |
| `n`, `p`; `PageDown`, `PageUp`; `]p`, `[p` | Next / previous PDF page |
| `z`, `q`, `e` | Zoom in / zoom out / reset zoom |
| `:PDFReader setPage 12` | Jump to page 12 |
| `:PDFReader setViewMode dark` | Dark PDF rendering |
| `:PDFReader setViewMode text` | Text view, useful for selecting and searching text |
| `:PDFReader setViewMode standard` | Original page appearance |
| `:PDFReader addBookmark 12` | Bookmark page 12 |
| `:PDFReader showBookmarks` | Choose a bookmark |
| `:PDFReader showToc` | Table of contents when available in the PDF |

In a PDF, `q` zooms out; use **Space b d** to close the buffer. Reading positions
and bookmarks are stored inside Neovim's data directory. This is a reader; PDF
annotations and document editing need a separate PDF application. Text mode uses
the PDF's embedded text, so scanned documents need OCR before text can be selected.
The status bar displays `PDF current/total`. Page turns replace the old image and
reuse converted pages, so previous pages do not cover the newly selected page.

The conversion dependencies are already installed: ImageMagick, Ghostscript and
Poppler. Page images require Ghostty or Kitty graphics support; other terminals
can use text mode. Check `:checkhealth snacks` if images are missing.

### Markdown

Open a `.md` file normally. The renderer styles headings, code blocks, tables,
links and checkboxes in the editing buffer, with source revealed while editing.
**Space u m** toggles rendering. **Space c p** opens a rendered preview split.
The same actions are available through `:RenderMarkdown toggle` and
`:RenderMarkdown preview`. Inline images use Snacks image support in Ghostty.
Math rendering is disabled because it requires additional tools.

PDF navigation was checked with a three-page sample: next/previous and Page Up/Down,
page-image replacement, cached conversions, zoom, dark/text modes, and independent
page state. Terminal image placement was instrumented during the headless checks;
on-screen graphics still depend on Ghostty/Kitty. Compatibility fixes are kept in
`lua/config/pdfreader.lua`, leaving the installed plugin source unchanged.
References: [PDF reader](https://github.com/r-pletnev/pdfreader.nvim),
[Markdown renderer](https://github.com/MeanderingProgrammer/render-markdown.nvim),
and [Snacks image support](https://github.com/folke/snacks.nvim/blob/main/docs/image.md).

## Edit faster

- **s**: Flash jump. Type target characters, then the displayed label.
- **S**: select a syntax node with Flash Treesitter.
- **ci"**, **di(**, **yi{**: change/delete/copy inside quotes/brackets.
- **vif**, **vaf**: select function contents / whole function.
- **]f / [f**, **]a / [a**: move between functions / parameters.
- **Space s r**: project search-and-replace; review matches before replacing.
- `:%s/old/new/g`: preview replacement before Enter; append `c` to confirm matches.
- **Space s u** or **Space u u**: browse undo history with previews.

## Windows, terminal and focus

| Shortcut                 | Action                                        |
| ------------------------ | --------------------------------------------- |
| `Space \|`, `Space -`    | Vertical / horizontal split                   |
| `Ctrl-h/j/k/l`           | Move between windows                          |
| `Ctrl` + arrows          | Resize windows                                |
| `Space w d`              | Close window                                  |
| `Ctrl-/`, `Space f t`    | Toggle project terminal                       |
| `Esc Esc` in terminal    | Leave terminal input mode; `i` resumes typing |
| `Space u z`, `Space u Z` | Zen mode / zoom current window                |
| `Space .`, `Space S`     | Scratch buffer / choose saved scratch buffer  |
| `Space u w`, `Space u s` | Toggle wrapping / spelling                    |
| `Space u L`              | Toggle relative line numbers                  |

Some terminals send **Ctrl-_** for **Ctrl-/**; both work. Scratch buffers are useful
for notes; Lua scratch buffers also have an execution action.

## Git and sessions

Git signs mark changed lines in tracked files. **]h / [h** navigate hunks;
**Space g h p** previews, **Space g h s** stages, **Space g h r** resets, and
**Space g h b** shows blame. Reset discards that hunk's working changes.

**Space g g** opens your existing LazyGit; **Space g s** shows Git status and
**Space g d** shows the diff picker. Opening them does not commit or push.

Sessions track open files and layouts after you open a normal file.
**Space q s** restores this project's session; **Space q S** chooses a session;
**Space q l** restores the last one. **Space q d** stops saving this session.
Sessions restore layouts; save file contents with `:w`. Persistent undo is separate.

## Maintain and customize

| File / command                                   | Purpose                                              |
| ------------------------------------------------ | ---------------------------------------------------- |
| `lua/config/options.lua`                         | Editor preferences                                   |
| `lua/config/keymaps.lua`                         | Personal shortcuts                                   |
| `lua/config/autocmds.lua`                        | Prose and Python buffer behavior                     |
| `lua/plugins/languages.lua`                      | LSP, formatters and linting                          |
| `lua/plugins/editor.lua`                         | Dashboard, picker and completion                     |
| `lua/plugins/base16.lua`                         | Load existing wallpaper palette through LazyVim      |
| `lua/matugen.lua`                                | Existing generated palette and live update handler   |
| `lua/config/tools.lua`                           | Tool manifest and installation retry                 |
| `lua/config/java.lua`, `scripts/install-java.py` | Private Java runtime and separate project workspaces |
| `lazy-lock.json`                                 | Exact plugin revisions                               |
| `:Lazy`                                          | Plugins; `U` updates, `R` restores locked revisions  |
| `:LazyExtras`                                    | Optional languages, debugging and test integrations  |
| `:NvimTools`, `:checkhealth`                     | Tool check / full environment check                  |
| `:messages`, `Space n`                           | Messages / notification history                      |
| `:TSUpdate`, `:TSInstall language`               | Update / install syntax parsers                      |

Restart after config changes. Plugins are not silently updated. Before updating
with `:Lazy`, save your lockfile. `:Lazy restore` uses the **current** lockfile;
restore your saved lockfile first to return to pre-update revisions.

For Go, debuggers or test runners, select the corresponding language / DAP /
test extra in `:LazyExtras`. Those need more downloads and typically the language's
runtime/compiler. There are no paid AI integrations or account requirements.

The original config is archived in
`backups/before-setup-20261026-224531.tar.gz` in this directory. To roll back, close
Neovim, move this config aside, and extract the archive into an empty
`~/.config/nvim`. It contains original config files, not plugin data.
The configuration before the required-language additions is separately backed up
as `backups/before-required-languages-20261026-230552.tar.gz`.

## Why this improves your starting point

The original was mostly the LazyVim starter, with an inactive example and a custom
palette. Its foundation was already modern; the improvement is a usable,
documented configuration around it.

- **Current architecture:** LazyVim 16.0.1, native `vim.lsp.config`, Mason v2,
  Blink and Snacks. Avoids obsolete LSP setup, nvim-cmp and null-ls recipes.
- **Useful language settings:** common coding/config languages have explicit
  server and formatter settings, a health report and one installation-retry command.
- **Predictable editing:** Enter does not accept an unselected suggestion,
  saving is explicit, and selection pastes preserve the clipboard.
- **Readable UI:** restrained diagnostics, inlay hints off initially, scrolling
  animations disabled, and styled Markdown with source revealed while editing.
- **Fits your desktop:** preserves the generated palette and live wallpaper
  updates, without altering the terminal or theme generator.
- **Maintainable:** small files, existing plugins reused, project style respected,
  exact plugin revisions retained, and a backup.
- **Discoverable:** Space command menu, searchable bindings and this local guide.

Most features come from LazyVim and its maintainers. These overrides make them
coherent for your machine. A built-in-only setup would have fewer dependencies;
this one supplies complete everyday workflows using your installed ecosystem.

## Verification on this machine

Checked on 26 October 2026 with your installed Neovim 0.12.6 and LazyVim 16.0.1.
The initial fourteen integration checks passed: startup/commands, wallpaper palette, completion
configuration, actual Lua format-on-save, Lua server process launch, Lua parsing,
Python settings, readable guide, dotfile discovery, tool health report,
EditorConfig precedence, shell formatting without a missing-linter error,
terminal execution, and full clangd LSP initialization. Local Lua files also pass
StyLua's formatting check. The original plugin lockfile is unchanged.

After adding your required languages, actual saves successfully formatted C, C++,
Python, Rust, Java, JavaScript, CSS and HTML. Java used the installed clang-format
fallback. Prettier project-style settings and selected-range formatting also
passed. The private JDK installer passed checks for archive layout, checksum
rejection and clean handling of an offline download. Rust's incomplete system
analyzer shim is correctly reported as missing instead of being enabled.

Downloads failed in the restricted setup session. Rust/Java server downloads and
their live features remain unverified until installation. The existing Lua server
launches but did not complete its initialization handshake here, including when
tested separately from this configuration. Full Lua completion/diagnostics still
need checking in your normal terminal using **Space c l**. If LuaLS remains stuck,
inspect `:MasonLog` / `:checkhealth vim.lsp` and reinstall `lua-language-server`
through Mason. These limits do not affect the verified editing and formatting.

Official references: [LazyVim release](https://github.com/LazyVim/LazyVim/releases/tag/v16.0.1),
[configuration](https://www.lazyvim.org/configuration/plugins),
[keymaps](https://www.lazyvim.org/keymaps),
[Blink key bindings](https://cmp.saghen.dev/configuration/keymap),
and `:help` / `:help lsp` inside Neovim.

Java/Rust references: [JDTLS runtime requirement](https://github.com/eclipse-jdtls/eclipse.jdt.ls/blob/main/README.md),
[Temurin releases](https://api.adoptium.net/v3/info/available_releases),
[Google Java Format](https://github.com/google/google-java-format),
and [rust-analyzer installation](https://rust-analyzer.github.io/book/installation.html).
