if status is-interactive
    #: {{{ gcca
    if test (uname) = Darwin
        #: {{{ Darwin
        eval (/opt/homebrew/bin/brew shellenv)

        bind ¬ clear-screen

        alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale

        set -x NODE_OPTIONS "--localstorage-file=$HOME/.coc-localstorage.db"
        #: }}} Darwin
    else
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    end

    #: {{{ Paths
    # fish_add_path \
    #     $HOME/.opencode/bin \
    #     $HOME/.nimble/bin \
    #     $HOME/.local/bin
    #: }}} Paths

    # set -gx VIRTUAL_ENV_DISABLE_PROMPT 1

    # if test (date +%H%M) -ge 620 -a (date +%H%M) -le 1835
    #     fish_config theme choose AtomOneLight
    # else
    #     fish_config theme choose tokyonight_night
    # end

    if command -q starship
        source (starship init fish --print-full-init | psub)
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
    #: }}} Env&Vars

    #: {{{ Eza
    if command -q eza
        alias ls='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first'
        alias ll='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -l --git -h'
        alias la='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a'
        alias lla='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a -l --git -h'
    end
    #: }}} Eza

    #: {{{ Bat
    if command -q bat
        # set -x BAT_THEME OneHalfLight
        set -x BAT_STYLE 'numbers,changes,header'
        alias cat='bat'
    end
    #: }}} Bat

    #: {{{ fzf
    if command -q fzf
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude dist --exclude .cache'
        set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

        set -gx FZF_DEFAULT_OPTS '--height 50% --reverse --border --margin=1,2'
        set -gx FZF_CTRL_T_OPTS '--preview "bat --color=always --line-range :20 {}" --preview-window right:50%'
        set -gx FZF_CTRL_R_OPTS '--preview "echo {}" --preview-window hidden'
        set -gx FZF_ALT_C_OPTS '--preview "eza --color=always --tree --level=2 {}"'

        set -gx FZF_TMUX 1
        set -gx FZF_TMUX_HEIGHT 50%

        fzf --fish | source
        bind ç fzf-cd-widget

        if test -f ~/.config/fzf/fzf-git/fzf-git.fish
            source ~/.config/fzf/fzf-git/fzf-git.fish
        end
    end
    #: }}} fzf

    #: {{{ git aliases
    alias gcm='git ci -m'
    alias gcdp='git ci -m (date +%Y%m%d%H%M%S);and git push'
    alias gcr='gcm (git log -1 --pretty=%B | tr -d \\n)'
    alias gcuk='git config user.name gcca;git config user.email git@gcca.dev;git config user.signingkey 4A4593D607AB097D'
    alias giex='echo -e "cred\n.claudeignore\n.kilo\n__pycache__\nbin/\n*--output\n*--input\n.cache\ncompile_commands.json\n.ninja_*\nbuild/\ndata\nCTX.md" >.git/info/exclude'
    #: }}} git aliases
end
# vim: set fdm=marker ft=fish sw=4 ts=4 sts=4 et:
