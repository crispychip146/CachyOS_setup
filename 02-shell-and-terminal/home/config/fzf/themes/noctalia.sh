fzf_theme_opts="\
--color=bg+:#1d1e1f
--color=bg:#000000
--color=spinner:#ffe09b
--color=hl:#ff5c78
--color=fg:#fffdf8
--color=header:#ff5c78
--color=info:#ffe09b
--color=pointer:#ffe09b
--color=marker:#c2c2c1
--color=fg+:#fffdf8
--color=prompt:#ffe09b
--color=hl+:#ff5c78
--color=selected-bg:#272829
--color=border:#f3e5ca
--color=label:#fffdf8"

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS
}$fzf_theme_opts"
