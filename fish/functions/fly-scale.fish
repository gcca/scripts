function fly-scale -d "Show Fly app VM CPU and RAM from scale show"
    if not command -q fly
        echo (set_color red)"fly is not installed"(set_color normal)
        return 1
    end
    if not command -q jq
        echo (set_color red)"jq is not installed"(set_color normal)
        return 1
    end

    set -l list_err (mktemp)
    set -l apps (fly apps list --json 2>$list_err | jq -r '.[].Name')
    set -l fly_status $pipestatus[1]
    set -l jq_status $pipestatus[2]
    if test $fly_status -ne 0
        set_color red
        if test -s $list_err
            cat $list_err
        else
            echo "fly apps list failed"
        end
        set_color normal
        rm -f $list_err
        return $fly_status
    end
    if test $jq_status -ne 0
        echo (set_color red)"Could not read app names from fly apps list"(set_color normal)
        rm -f $list_err
        return $jq_status
    end
    rm -f $list_err

    if test (count $apps) -eq 0
        echo (set_color yellow)"No Fly apps"(set_color normal)
        return 0
    end

    set -l tmp (mktemp -d)
    for app in $apps
        fly scale show -a $app --json >$tmp/$app.json 2>$tmp/$app.err &
    end
    wait 2>/dev/null

    set -l col_app
    set -l col_proc
    set -l col_count
    set -l col_cpu
    set -l col_cpus
    set -l col_mem
    set -l col_mem_n
    set -l col_err

    for app in $apps
        if not test -s $tmp/$app.json
            set -l err (string join " " (string collect <$tmp/$app.err | string trim))
            if test -z "$err"
                set err "scale show returned no data"
            end
            set col_app $col_app $app
            set col_proc $col_proc -
            set col_count $col_count -
            set col_cpu $col_cpu -
            set col_cpus $col_cpus 0
            set col_mem $col_mem -
            set col_mem_n $col_mem_n 0
            set col_err $col_err $err
            continue
        end

        set -l jq_err (mktemp)
        set -l parsed (jq -r '
            if length == 0 then
                "-\t-\t-\t0\t0"
            else
                .[] | [
                    (.Process // "-"),
                    ((.Count // "-") | tostring),
                    (.CPUKind // "-"),
                    ((.CPUs // 0) | tostring),
                    ((.Memory // 0) | tostring)
                ] | @tsv
            end
        ' $tmp/$app.json 2>$jq_err)
        set -l parse_status $status
        if test $parse_status -ne 0
            set -l err (string join " " (string collect <$jq_err | string trim))
            rm -f $jq_err
            if test -z "$err"
                set err (string join " " (string collect <$tmp/$app.err | string trim))
            end
            if test -z "$err"
                set err "could not parse scale show"
            end
            set col_app $col_app $app
            set col_proc $col_proc -
            set col_count $col_count -
            set col_cpu $col_cpu -
            set col_cpus $col_cpus 0
            set col_mem $col_mem -
            set col_mem_n $col_mem_n 0
            set col_err $col_err $err
            continue
        end
        rm -f $jq_err

        if test (count $parsed) -eq 0
            set col_app $col_app $app
            set col_proc $col_proc -
            set col_count $col_count -
            set col_cpu $col_cpu -
            set col_cpus $col_cpus 0
            set col_mem $col_mem -
            set col_mem_n $col_mem_n 0
            set col_err $col_err "scale show returned no groups"
            continue
        end

        for line in $parsed
            set -l f (string split \t -- $line)
            set -l kind $f[3]
            set -l cpus $f[4]
            set -l mem_n $f[5]
            set -l cpu_s "$kind $cpus vCPU"
            if test "$cpus" != 1
                set cpu_s "$kind $cpus vCPUs"
            end
            set -l mem_s "$mem_n MB"
            if test "$mem_n" = 0 -a "$f[2]" = -
                set cpu_s -
                set mem_s -
            end

            set col_app $col_app $app
            set col_proc $col_proc $f[1]
            set col_count $col_count $f[2]
            set col_cpu $col_cpu $cpu_s
            set col_cpus $col_cpus $cpus
            set col_mem $col_mem $mem_s
            set col_mem_n $col_mem_n $mem_n
            set col_err $col_err ""
        end
    end

    rm -rf $tmp

    set -l w_app (string length App)
    set -l w_proc (string length Process)
    set -l w_count (string length Count)
    set -l w_cpu (string length CPU)
    for i in (seq (count $col_app))
        set -l n (string length -- $col_app[$i])
        if test $n -gt $w_app
            set w_app $n
        end
        set n (string length -- $col_proc[$i])
        if test $n -gt $w_proc
            set w_proc $n
        end
        set n (string length -- $col_count[$i])
        if test $n -gt $w_count
            set w_count $n
        end
        set n (string length -- $col_cpu[$i])
        if test $n -gt $w_cpu
            set w_cpu $n
        end
    end

    set_color --bold cyan
    printf "%-*s  %-*s  %-*s  %-*s  %s\n" $w_app App $w_proc Process $w_count Count $w_cpu CPU RAM
    set_color normal

    for i in (seq (count $col_app))
        if test -n "$col_err[$i]"
            set_color red
            printf "%-*s  %s\n" $w_app $col_app[$i] $col_err[$i]
            set_color normal
            continue
        end

        set_color green
        printf "%-*s  " $w_app $col_app[$i]
        set_color cyan
        printf "%-*s  " $w_proc $col_proc[$i]
        set_color normal
        printf "%-*s  " $w_count $col_count[$i]

        if test $col_cpus[$i] -gt 1
            set_color --bold magenta
        else
            set_color normal
        end
        printf "%-*s  " $w_cpu $col_cpu[$i]

        if test $col_mem_n[$i] -ge 4096
            set_color --bold red
        else if test $col_mem_n[$i] -gt 256
            set_color yellow
        else
            set_color green
        end
        printf "%s\n" $col_mem[$i]
        set_color normal
    end
end
