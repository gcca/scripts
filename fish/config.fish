if status is-interactive
    #: {{{ gcca
    if test (uname) = Darwin
        if test -d ~/.hb
            eval (~/.hb/bin/brew shellenv)
        else
            eval (/opt/homebrew/bin/brew shellenv)
        end
    else
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    end

    bind ¬ clear-screen
    set K /Volumes/KINGSTON_gcca
    set -gx VIRTUAL_ENV_DISABLE_PROMPT 1

    fish_add_path $HOME/.local/bin
    fish_add_path /Users/gcca/.opencode/bin

    #fish_config theme choose tokyonight

    if set -q HOMEBREW_PREFIX; and test -x $HOMEBREW_PREFIX/bin/starship
        source ($HOMEBREW_PREFIX/bin/starship init fish --print-full-init | psub)
    end

    set -l setxs_path (dirname (status filename))/setxs.fish
    if test -f $setxs_path
        source $setxs_path
    end
    #: }}} gcca

    #: {{{ Env&Vars
    set -x LANG en_US.UTF-8
    set -x LC_ALL en_US.UTF-8
    set -x LC_CTYPE en_US.UTF-8

    set -x NODE_OPTIONS "--localstorage-file=$HOME/.coc-localstorage.db"

    set -x BUN_INSTALL "$HOME/.bun"

    fish_add_path $HOME/.local/bin
    fish_add_path $BUN_INSTALL/bin
    #: }}} Env&Vars

    #: {{{ Eza
    alias ls='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first'
    alias ll='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -l --git -h'
    alias la='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a'
    alias lla='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a -l --git -h'
    #: }}} Eza

    #: {{{ Bat
    set -x BAT_THEME gruvbox-dark
    set -x BAT_STYLE 'numbers,changes,header'
    alias cat='bat'
    #: }}} Bat

    #: {{{ fzf
    set -gx FZF_DEFAULT_OPTS '--height 50% --reverse --border --margin=1,2'
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'

    set -gx FZF_CTRL_T_OPTS '--preview "bat --color=always --line-range :20 {}" --preview-window right:50%'
    set -gx FZF_CTRL_R_OPTS '--preview "echo {}" --preview-window hidden'
    set -gx FZF_ALT_C_OPTS '--preview "eza --color=always --tree --level=2 {}"'

    set -gx FZF_TMUX 1
    set -gx FZF_TMUX_HEIGHT 50%

    fzf --fish | source
    bind ç fzf-cd-widget
    #: }}} fzf

    #: {{{ fzf-git
    set -l fzf_git_path ~/.config/fzf/fzf-git/fzf-git.fish
    if test -f $fzf_git_path
        source $fzf_git_path
    end
    #: }}} fzf-git
end
# vim: set fdm=marker ft=fish sw=4 ts=4 sts=4 et:

# opencode
