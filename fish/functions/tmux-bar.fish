function tmux-bar -d "Set tmux status bar color theme" -a theme
    switch $theme
        case ayu-light
            set -l bg "#FAFAFA"
            set -l fg "#5C6773"
            tmux set -g status-style bg=$bg,fg=$fg
            tmux set -g window-status-current-style fg=$fg
        case ayu-mirage
            set -l bg "#212733"
            set -l fg "#D9D7CE"
            tmux set -g status-style bg=$bg,fg=$fg
            tmux set -g window-status-current-style fg=$fg
        case ayu
            set -l bg "#0F1419"
            set -l fg "#E6E1CF"
            tmux set -g status-style bg=$bg,fg=$fg
            tmux set -g window-status-current-style fg=$fg
        case tokyonight-night
            set -l bg "#1a1b26"
            set -l fg "#c0caf5"
            tmux set -g status-style bg=$bg,fg=$fg
            tmux set -g window-status-current-style fg=$fg
        case tokyonight-storm
            set -l bg "#24283b"
            set -l fg "#c0caf5"
            tmux set -g status-style bg=$bg,fg=$fg
            tmux set -g window-status-current-style fg=$fg
        case tokyonight-moon
            set -l bg "#222436"
            set -l fg "#c8d3f5"
            tmux set -g status-style bg=$bg,fg=$fg
            tmux set -g window-status-current-style fg=$fg
        case tokyonight-day
            set -l bg "#e1e2e7"
            set -l fg "#3760bf"
            tmux set -g status-style bg=$bg,fg=$fg
            tmux set -g window-status-current-style fg=$fg
        case '*'
            echo "Unknown theme: $theme"
            echo "Available: ayu-light, ayu-mirage, ayu, tokyonight-night, tokyonight-storm, tokyonight-moon, tokyonight-day"
            return 1
    end
end

complete -c tmux-bar -f
complete -c tmux-bar -n __fish_use_subcommand -a ayu-light      -d "Ayu Light (bg=#FAFAFA)"
complete -c tmux-bar -n __fish_use_subcommand -a ayu-mirage     -d "Ayu Mirage (bg=#212733)"
complete -c tmux-bar -n __fish_use_subcommand -a ayu            -d "Ayu Dark (bg=#0F1419)"
complete -c tmux-bar -n __fish_use_subcommand -a tokyonight-night -d "TokyoNight Night (bg=#1a1b26)"
complete -c tmux-bar -n __fish_use_subcommand -a tokyonight-storm -d "TokyoNight Storm (bg=#24283b)"
complete -c tmux-bar -n __fish_use_subcommand -a tokyonight-moon  -d "TokyoNight Moon (bg=#222436)"
complete -c tmux-bar -n __fish_use_subcommand -a tokyonight-day   -d "TokyoNight Day (bg=#e1e2e7)"
