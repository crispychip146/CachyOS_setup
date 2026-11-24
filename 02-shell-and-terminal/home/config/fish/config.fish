# Fish configuration — migrated from Zsh
# Managed manually; Fish includes syntax highlighting, suggestions and completions.

# Environment and CLI tools
fish_add_path -p $HOME/.local/bin
fish_add_path -p $HOME/.opencode/bin
fish_add_path -a $HOME/.lmstudio/bin

# Private environment is loaded automatically from conf.d/90-private-env.fish.

# Commands and aliases
alias ls 'eza --icons=auto'
alias ll 'eza -lah --icons=auto --git'
alias cat bat
alias v nvim
alias agy-auto 'agy --dangerously-skip-permissions'

# Yazi: change directory to the last visited location on exit.
function f --description 'Open Yazi and follow its final directory'
    set -l tmp (mktemp -t yazi-cwd.XXXXXX)
    or return 1
    command yazi $argv --cwd-file="$tmp"
    set -l result $status
    if test -f "$tmp"
        set -l cwd (command cat -- "$tmp")
        if test -n "$cwd"; and test "$cwd" != "$PWD"; and test -d "$cwd"
            builtin cd -- "$cwd"
        end
    end
    command rm -f -- "$tmp"
    return $result
end

if status is-interactive
    if command -q zoxide
        zoxide init fish | source
    end
    if command -q atuin
        atuin init fish | source
    end
    if command -q starship
        starship init fish | source
    end
    #if command -q fastfetch
    #    fastfetch
    #end
end
