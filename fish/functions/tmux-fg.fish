function tmux-fg -d "Set tmux status bar foreground color"
    argparse 'b/bold-only' -- $argv
    or return 1

    set -l color $argv[1]

    if not string match -qr '^[0-9a-fA-F]{6}$' $color
        echo "Usage: tmux-fg [-b/--bold-only] <hex_color> (e.g. tmux-fg 5C6773)"
        return 1
    end

    if set -q _flag_bold_only
        set fg_current "#$color"
    else
        set -l r (math "0x"(string sub -s 1 -l 2 $color))
        set -l g (math "0x"(string sub -s 3 -l 2 $color))
        set -l b (math "0x"(string sub -s 5 -l 2 $color))
        set -l brightness (math "($r + $g + $b) / 3")

        if test $brightness -gt 120
            set -l lr (math "min(255, $r + 40)")
            set -l lg (math "min(255, $g + 40)")
            set -l lb (math "min(255, $b + 40)")
            set fg_current (printf "#%02x%02x%02x" $lr $lg $lb)
        else
            set -l dr (math "max(0, $r - 40)")
            set -l dg (math "max(0, $g - 40)")
            set -l db (math "max(0, $b - 40)")
            set fg_current (printf "#%02x%02x%02x" $dr $dg $db)
        end
    end

    tmux set -g status-style fg=#$color

    tmux set -g window-status-current-style fg=$fg_current,bold
end

complete -c tmux-fg -f
complete -c tmux-fg -s b -l bold-only -d "Solo bold, sin ajuste de color"
