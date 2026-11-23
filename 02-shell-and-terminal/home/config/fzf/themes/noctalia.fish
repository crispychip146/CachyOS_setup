set -l fzf_theme_opts "\
--color=bg+:#210e32
--color=bg:#000000
--color=spinner:#d87cff
--color=hl:#ff5c78
--color=fg:#fcf6ff
--color=header:#ff5c78
--color=info:#d87cff
--color=pointer:#d87cff
--color=marker:#c4bcca
--color=fg+:#fcf6ff
--color=prompt:#d87cff
--color=hl+:#ff5c78
--color=selected-bg:#2f1c41
--color=border:#ffe5ae
--color=label:#fcf6ff"

if set -q FZF_DEFAULT_OPTS[1]; and test -n "$FZF_DEFAULT_OPTS"
    set -Ux FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS
$fzf_theme_opts"
else
    set -Ux FZF_DEFAULT_OPTS "$fzf_theme_opts"
end
