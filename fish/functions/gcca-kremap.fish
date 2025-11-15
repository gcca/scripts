function gcca-kremap
    set -l option $argv[1]
    switch $option
        case 'ctrlcmd'
            _gcca-kremap-keymap 0x7000000E0 0x7000000E7
        case 'cmdctrl'
            _gcca-kremap-unmap 0x7000000E7
        case 'ctrlopt'
            _gcca-kremap-keymap 0x7000000E0 0x7000000E6
        case 'ctrldel'
            _gcca-kremap-keymap 0x7000000E0 0x70000004C
        case 'tildel'
            _gcca-kremap-keymap 0x700000035 0x70000004C
        case 'reset'
            _gcca-kremap-reset
    end
    _gcca-kremap-refresh
end

# Mapping
# 0x700000035  grave_accent_and_tilde
# 0x70000004C  nuphy - delete
# 0x7000000E0  left_control
# 0x7000000E1  left_shift
# 0x7000000E2  left_option
# 0x7000000E6  right_option
# 0x7000000E7  right_command

set -g __gcca_kremap_src
set -g __gcca_kremap_dst

function _gcca-kremap-refresh
    if not test -z "$__gcca_kremap_src"
        set -l mappings
        for i in (seq (count $__gcca_kremap_src))
            set -l SRC $__gcca_kremap_src[$i]
            set -l DST $__gcca_kremap_dst[$i]
            set -a mappings "{\"HIDKeyboardModifierMappingSrc\":$SRC,\"HIDKeyboardModifierMappingDst\":$DST}"
        end
        hidutil property --set "{\"UserKeyMapping\":[$(string join ',' $mappings)]}"
    else
        hidutil property --set '{"UserKeyMapping":[]}'
    end
end

function _gcca-kremap-unmap
    if not test -z "$__gcca_kremap_src"
        set -l i 0
        for j in (seq (count $__gcca_kremap_src))
            if test $argv[1] = $__gcca_kremap_src[$j]
                set i $j
                break
            end
        end
        if test $i -ne 0
            set -e __gcca_kremap_src[$i]
            set -e __gcca_kremap_dst[$i]
        end
    end
end

function _gcca-kremap-keymap
    if _gcca-is-in-src $argv[2]
        return
    end
    set -a __gcca_kremap_src $argv[2]
    set -a __gcca_kremap_dst $argv[1]
end

function _gcca-is-in-src
    if not test -z "$__gcca_kremap_src"
        for i in (seq (count $__gcca_kremap_src))
            if test $argv[1] = $__gcca_kremap_src[$i]
                return 0
            end
        end
    end
    return 1
end

function _gcca-kremap-reset
    set __gcca_kremap_src
    set __gcca_kremap_dst
end

# vim: set ts=4 sw=4 sts=4 et:
