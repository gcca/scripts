# Preset rows: id, fish theme, Ghostty theme, bat theme, eza yml, delta features tail, emacs theme.
# Emacs "-" means this preset does not change custom.el.
set -g __gcca_theme_rows \
    "tokyonight"\t"tokyonight_night"\t"tokyonight-firefly"\t"TwoDark"\t"tokyonight.yml"\t"dark mantis-shrimp-lite"\t"tokyo-night" \
    "catppuccin"\t"catppuccin-mocha"\t"Catppuccin Mocha"\t"Catppuccin Mocha"\t"catppuccin-mocha.yml"\t"dark gruvmax-fang"\t"catppuccin-mocha" \
    "gruvbox"\t"gruvbox_dark"\t"Gruvbox Dark"\t"gruvbox-dark"\t"gruvbox-dark.yml"\t"dark gruvmax-fang"\t"gruvbox-dark-medium" \
    "rose-pine"\t"rose-pine"\t"rose-pine-dawn"\t"TwoDark"\t"rose-pine.yml"\t"dark mantis-shrimp-lite"\t"-" \
    "dracula"\t"Dracula"\t"Dracula"\t"Dracula"\t"dracula.yml"\t"dark mantis-shrimp-lite"\t"-" \
    "solarized"\t"Builtin Solarized Dark"\t"solarized-terafox"\t"Solarized (dark)"\t"solarized-dark.yml"\t"dark mantis-shrimp-lite"\t"solarized-dark"

function _gcca-theme-ids
    for row in $__gcca_theme_rows
        set -l fields (string split \t -- $row)
        echo $fields[1]
    end
end

function _gcca-theme-row
    set -l id $argv[1]
    for row in $__gcca_theme_rows
        set -l fields (string split \t -- $row)
        if test "$fields[1]" = "$id"
            echo $row
            return 0
        end
    end
    return 1
end

function _gcca-theme-err
    echo "gcca-theme: $argv" >&2
end

function _gcca-theme-usage
    echo "Usage: gcca-theme list | show [id] | choose <id>" >&2
    return 1
end

function _gcca-theme-file
    switch $argv[1]
        case fish
            if set -q __gcca_theme_file_fish
                echo $__gcca_theme_file_fish
            else
                echo $HOME/.config/fish/config.fish
            end
        case ghostty
            if set -q __gcca_theme_file_ghostty
                echo $__gcca_theme_file_ghostty
            else
                echo $HOME/.config/ghostty/config
            end
        case ghostty-toml
            if set -q __gcca_theme_file_ghostty_toml
                echo $__gcca_theme_file_ghostty_toml
            else
                echo $__gcca_theme_repo/ghostty-themes.toml
            end
        case eza-link
            if set -q __gcca_theme_file_eza
                echo $__gcca_theme_file_eza
            else
                echo $HOME/.config/eza/theme.yml
            end
        case eza-dir
            if set -q __gcca_theme_dir_eza
                echo $__gcca_theme_dir_eza
            else
                echo $HOME/.config/eza/eza-themes/themes
            end
        case delta
            if set -q __gcca_theme_file_delta
                echo $__gcca_theme_file_delta
            else
                echo $HOME/.gitconfig
            end
        case delta-themes
            if set -q __gcca_theme_file_delta_themes
                echo $__gcca_theme_file_delta_themes
            else
                echo $HOME/.config/delta/themes.gitconfig
            end
        case fish-themes
            if set -q __gcca_theme_dir_fish
                echo $__gcca_theme_dir_fish
            else
                echo $HOME/.config/fish/themes
            end
        case emacs
            if set -q __gcca_theme_file_emacs
                echo $__gcca_theme_file_emacs
            else
                echo $HOME/.emacs.d/custom.el
            end
    end
end

function _gcca-theme-lines
    string split \n -- (command cat -- $argv[1])
end

function _gcca-theme-write-lines
    set -l file $argv[1]
    set -e argv[1]
    printf '%s\n' $argv >$file
end

function _gcca-theme-quote
    set -l value (string join ' ' -- $argv)
    set -l escaped (string replace -a "'" "'\\''" -- $value)
    echo "'$escaped'"
end

function _gcca-theme-paint
    set -l label $argv[1]
    set -l color $argv[2]
    set -l value $argv[3]
    set -l value_color $argv[4]
    if isatty stdout
        printf '%s%s%s%s%s\n' \
            (set_color $color) "$label" \
            (set_color $value_color) "$value" \
            (set_color --reset)
    else
        echo "$label$value"
    end
end

function _gcca-theme-show-row
    set -l fields (string split \t -- $argv[1])
    if isatty stdout
        printf '%s%s%s\n' (set_color --bold cyan) $fields[1] (set_color --reset)
    else
        echo $fields[1]
    end
    _gcca-theme-paint "  fish     " blue $fields[2] normal
    set -l ghostty_value (_gcca-theme-ghostty-entry $fields[3])
    set -l ghostty_status $status
    _gcca-theme-paint "  ghostty  " magenta $fields[3] normal
    if test $ghostty_status -eq 0
        _gcca-theme-paint "  theme    " cyan $ghostty_value cyan
    end
    _gcca-theme-paint "  bat      " yellow $fields[4] normal
    _gcca-theme-paint "  eza      " green $fields[5] normal
    _gcca-theme-paint "  delta    " brcyan $fields[6] normal
    _gcca-theme-paint "  emacs    " white $fields[7] normal
end

function _gcca-theme-require-file
    set -l file $argv[1]
    if not test -f $file
        _gcca-theme-err "missing file $file"
        return 1
    end
    if not test -w $file
        _gcca-theme-err "not writable $file"
        return 1
    end
end

function _gcca-theme-one-line
    set -l file $argv[1]
    set -l pattern $argv[2]
    set -l label $argv[3]
    set -l hits (string match -r -- $pattern (_gcca-theme-lines $file))
    set -l n (count $hits)
    if test $n -ne 1
        _gcca-theme-err "$label matched $n lines in $file (want 1)"
        return 1
    end
    echo $hits[1]
end

function _gcca-theme-check-fish
    set -l theme $argv[1]
    set -l file (_gcca-theme-file fish)
    _gcca-theme-require-file $file; or return 1
    set -l theme_file (_gcca-theme-file fish-themes)"/$theme.theme"
    if not test -f "$theme_file"
        _gcca-theme-err "missing fish theme $theme_file"
        return 1
    end
    _gcca-theme-one-line $file '^\s*#: \{\{\{ Theme$' 'theme start' >/dev/null; or return 1
    _gcca-theme-one-line $file '^\s*#: \}\}\} Theme$' 'theme end' >/dev/null; or return 1
end

function _gcca-theme-check-bat
    set -l file (_gcca-theme-file fish)
    _gcca-theme-require-file $file; or return 1
    _gcca-theme-one-line $file '^\s*set -x BAT_THEME ' 'BAT_THEME' >/dev/null
end

function _gcca-theme-ghostty-entry
    set -l id $argv[1]
    set -l toml (_gcca-theme-file ghostty-toml)
    if not test -f $toml
        return 1
    end
    set -l found
    for line in (_gcca-theme-lines $toml)
        set -l match (string match -r -- '^([A-Za-z0-9_-]+) = "(.*)"$' $line)
        if test (count $match) -ge 3; and test "$match[2]" = "$id"
            set found $found $match[3]
        end
    end
    if test (count $found) -gt 1
        _gcca-theme-err "ghostty id $id matched "(count $found)" keys in $toml"
        return 2
    end
    if test (count $found) -eq 1
        echo $found[1]
        return 0
    end
    return 1
end

function _gcca-theme-check-ghostty
    set -l id $argv[1]
    set -l file (_gcca-theme-file ghostty)
    _gcca-theme-require-file $file; or return 1
    _gcca-theme-one-line $file '^theme = ' 'ghostty theme' >/dev/null; or return 1
    _gcca-theme-ghostty-entry $id >/dev/null
    set -l entry_status $status
    if test $entry_status -eq 2
        return 1
    end
    if test $entry_status -eq 0
        set -l toml (_gcca-theme-file ghostty-toml)
        _gcca-theme-require-file $toml; or return 1
        _gcca-theme-one-line $toml '^active = ' 'ghostty active' >/dev/null; or return 1
    end
end

function _gcca-theme-check-eza
    set -l yml $argv[1]
    set -l link (_gcca-theme-file eza-link)
    set -l dest (_gcca-theme-file eza-dir)/$yml
    if not test -L $link
        _gcca-theme-err "eza theme is not a symlink: $link"
        return 1
    end
    if not test -w (dirname $link)
        _gcca-theme-err "not writable "(dirname $link)
        return 1
    end
    if not test -f $dest
        _gcca-theme-err "missing eza theme $dest"
        return 1
    end
end

function _gcca-theme-check-delta
    set -l tail $argv[1]
    set -l file (_gcca-theme-file delta)
    set -l themes (_gcca-theme-file delta-themes)
    _gcca-theme-require-file $file; or return 1
    _gcca-theme-require-file $themes; or return 1
    _gcca-theme-one-line $file '^  features = ' 'delta features' >/dev/null; or return 1
    set -l parts (string split ' ' -- $tail)
    set -l token $parts[-1]
    set -l section "[delta \"$token\"]"
    if not contains -- $section (_gcca-theme-lines $themes)
        _gcca-theme-err "missing delta theme $section in $themes"
        return 1
    end
end

function _gcca-theme-write-fish-file
    set -l fish_theme $argv[1]
    set -l bat_theme $argv[2]
    set -l file (_gcca-theme-file fish)
    set -l lines (_gcca-theme-lines $file)
    set -l start 0
    set -l finish 0
    set -l bat_i 0
    set -l i 0
    for line in $lines
        set i (math $i + 1)
        if string match -qr -- '^\s*#: \{\{\{ Theme$' $line
            set start $i
        else if string match -qr -- '^\s*#: \}\}\} Theme$' $line
            set finish $i
        else if string match -qr -- '^\s*set -x BAT_THEME ' $line
            set bat_i $i
        end
    end
    set -l indent (string match -r -- '^\s*' $lines[$start])
    set -l quoted (_gcca-theme-quote $fish_theme)
    set -l new_region
    set new_region[1] (string join '' -- $indent '#: {{{ Theme')
    set new_region[2] (string join '' -- $indent 'set -l theme ' $quoted)
    set new_region[3] (string join '' -- $indent 'if not set -q __gcca_fish_theme; or test "$__gcca_fish_theme" != "$theme"')
    set new_region[4] (string join '' -- $indent '    if fish_config theme choose $theme')
    set new_region[5] (string join '' -- $indent '        set -g __gcca_fish_theme $theme')
    set new_region[6] (string join '' -- $indent '    end')
    set new_region[7] (string join '' -- $indent 'end')
    set new_region[8] (string join '' -- $indent '#: }}} Theme')
    set -l bat_indent (string match -r -- '^\s*' $lines[$bat_i])
    set -l bat_line (string join '' -- $bat_indent 'set -x BAT_THEME ' (_gcca-theme-quote $bat_theme))
    set -l out
    set i 0
    for line in $lines
        set i (math $i + 1)
        if test $i -eq $start
            set out $out $new_region
        else if test $i -gt $start -a $i -le $finish
            continue
        else if test $i -eq $bat_i
            set out $out $bat_line
        else
            set out $out $line
        end
    end
    _gcca-theme-write-lines $file $out
end

function _gcca-theme-write-ghostty
    set -l id $argv[1]
    set -l theme $id
    set -l active_id
    set -l resolved (_gcca-theme-ghostty-entry $id)
    if test $status -eq 0
        set theme $resolved
        set active_id $id
    end
    set -l file (_gcca-theme-file ghostty)
    set -l lines (_gcca-theme-lines $file)
    set -l out
    for line in $lines
        if string match -qr -- '^theme = ' $line
            set out $out "theme = $theme"
        else
            set out $out $line
        end
    end
    _gcca-theme-write-lines $file $out
    if test -n "$active_id"
        set -l toml (_gcca-theme-file ghostty-toml)
        set -l tlines (_gcca-theme-lines $toml)
        set out
        for line in $tlines
            if string match -qr -- '^active = ' $line
                set out $out "active = \"$active_id\""
            else
                set out $out $line
            end
        end
        _gcca-theme-write-lines $toml $out
        echo $toml
    end
end

function _gcca-theme-check-emacs
    set -l symbol $argv[1]
    if test "$symbol" = "-"
        return 0
    end
    set -l file (_gcca-theme-file emacs)
    _gcca-theme-require-file $file; or return 1
    _gcca-theme-one-line $file '^\\s*\'\\(custom-enabled-themes \'\\([^)]+\\)\\)' 'emacs theme' >/dev/null
end

function _gcca-theme-write-emacs
    set -l symbol $argv[1]
    if test "$symbol" = "-"
        return 0
    end
    set -l file (_gcca-theme-file emacs)
    set -l lines (_gcca-theme-lines $file)
    set -l out
    for line in $lines
        if string match -qr -- '^\\s*\'\\(custom-enabled-themes \'\\([^)]+\\)\\)' $line
            set -l indent (string match -r -- '^\\s*' $line)
            set out $out (string join '' -- $indent "'(custom-enabled-themes '(" $symbol "))")
        else
            set out $out $line
        end
    end
    _gcca-theme-write-lines $file $out
end

function _gcca-theme-load-emacs
    set -l symbol $argv[1]
    if test "$symbol" = "-"
        return 0
    end
    if not command -q emacsclient
        return 0
    end
    if not emacsclient -e nil >/dev/null 2>&1
        return 0
    end
    if not emacsclient -e "(load-theme '$symbol t)" >/dev/null
        _gcca-theme-err "emacsclient load-theme failed after writing "(_gcca-theme-file emacs)
        return 1
    end
end

function _gcca-theme-write-eza
    set -l yml $argv[1]
    set -l link (_gcca-theme-file eza-link)
    set -l dest (_gcca-theme-file eza-dir)/$yml
    ln -sfn $dest $link
end

function _gcca-theme-write-delta
    set -l tail $argv[1]
    set -l file (_gcca-theme-file delta)
    set -l lines (_gcca-theme-lines $file)
    set -l out
    for line in $lines
        if string match -qr -- '^  features = ' $line
            set out $out "  features = side-by-side navigate decorations line-numbers $tail"
        else
            set out $out $line
        end
    end
    _gcca-theme-write-lines $file $out
end

function _gcca-theme-choose
    set -l id $argv[1]
    set -l row (_gcca-theme-row $id)
    if test -z "$row"
        _gcca-theme-err "unknown preset $id"
        _gcca-theme-ids >&2
        return 1
    end
    set -l fields (string split \t -- $row)
    _gcca-theme-check-fish $fields[2]; or return 1
    _gcca-theme-check-bat; or return 1
    _gcca-theme-check-ghostty $fields[3]; or return 1
    _gcca-theme-check-eza $fields[5]; or return 1
    _gcca-theme-check-delta $fields[6]; or return 1
    _gcca-theme-check-emacs $fields[7]; or return 1

    set -l fish_file (_gcca-theme-file fish)
    set -l ghostty_file (_gcca-theme-file ghostty)
    set -l eza_link (_gcca-theme-file eza-link)
    set -l delta_file (_gcca-theme-file delta)

    _gcca-theme-write-fish-file $fields[2] $fields[4]
    or begin
        _gcca-theme-err "stopped before other files; fish config was not confirmed"
        return 1
    end
    echo $fish_file

    set -l toml_written (_gcca-theme-write-ghostty $fields[3])
    echo $ghostty_file
    if test -n "$toml_written"
        echo $toml_written
    end

    _gcca-theme-write-eza $fields[5]
    echo $eza_link

    _gcca-theme-write-delta $fields[6]
    echo $delta_file

    if test "$fields[7]" != "-"
        _gcca-theme-write-emacs $fields[7]
        echo (_gcca-theme-file emacs)
    end

    if not fish_config theme choose $fields[2]
        _gcca-theme-err "fish_config theme choose failed after writing $fish_file $ghostty_file $eza_link $delta_file"
        return 1
    end
    _gcca-theme-load-emacs $fields[7]
end

function gcca-theme -d "Apply a named theme preset to fish, bat, Ghostty, eza, delta, and Emacs"
    set -l cmd $argv[1]
    switch $cmd
        case list
            if test (count $argv) -ne 1
                _gcca-theme-usage
                return 1
            end
            _gcca-theme-ids
        case show
            if test (count $argv) -eq 1
                set -l first 1
                for row in $__gcca_theme_rows
                    if test $first -eq 0
                        echo
                    end
                    set first 0
                    _gcca-theme-show-row $row
                end
            else if test (count $argv) -eq 2
                set -l row (_gcca-theme-row $argv[2])
                if test -z "$row"
                    _gcca-theme-err "unknown preset $argv[2]"
                    _gcca-theme-ids >&2
                    return 1
                end
                _gcca-theme-show-row $row
            else
                _gcca-theme-usage
                return 1
            end
        case choose
            if test (count $argv) -ne 2
                _gcca-theme-err "choose needs one preset id"
                _gcca-theme-ids >&2
                return 1
            end
            _gcca-theme-choose $argv[2]
        case '*'
            _gcca-theme-usage
            return 1
    end
end

set -g __gcca_theme_repo (dirname (dirname (dirname (readlink -f (status filename)))))

complete -c gcca-theme -f -n '__fish_use_subcommand' -a 'list show choose'
complete -c gcca-theme -f -n '__fish_seen_subcommand_from show choose' -a 'tokyonight catppuccin gruvbox rose-pine dracula solarized'
