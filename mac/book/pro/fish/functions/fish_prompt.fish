function fish_prompt
    echo -n (set_color -d brmagenta)(prompt_pwd)(set_color normal)' '

    set_color -o
    echo -n (set_color red)'❯'(set_color yellow)'❯'(set_color green)'❯ '
    set_color normal
end

# vim: set sw=4 ts=4 sts=4 et ft=fish fdm=marker:
