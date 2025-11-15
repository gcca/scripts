function psg -d "Search processes by name with memory info"
    if test (count $argv) -eq 0
        echo (set_color red)"Usage: psg <pattern>"(set_color normal)
        return 1
    end

    set -l results (ps -axo pid,rss,%mem,comm | ag -i $argv[1])

    if test -z "$results"
        echo (set_color yellow)"No processes found matching '$argv[1]'"(set_color normal)
        return 1
    end

    set_color --bold cyan
    printf "%-8s  %-10s  %-6s  %s\n" "PID" "RSS" "MEM" "COMMAND"
    set_color normal

    for line in $results
        set -l fields (string split -n ' ' -- $line)
        set -l pid $fields[1]
        set -l rss (printf "%.1fMB" (math "$fields[2] / 1024"))
        set -l mem (printf "%s%%" $fields[3])
        set -l comm $fields[4]

        set_color green
        printf "%-8s  " $pid
        set_color yellow
        printf "%-10s  " $rss
        set_color magenta
        printf "%-6s  " $mem
        set_color white
        printf "%s" $comm
        set_color normal
        printf "\n"
    end
end
