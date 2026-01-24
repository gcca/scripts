function kitty-scolours
    set -l bg "#$argv[2]"
    set -l fg "#$argv[1]"
    printf %s\n \
        "tab_bar_background $bg" \
        "active_tab_background $bg" \
        "inactive_tab_background $bg" \
        "active_tab_foreground $fg" \
        "inactive_tab_foreground $fg" >$HOME/.config/kitty/gcca.conf
end
