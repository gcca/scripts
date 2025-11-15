function pye -d "Activate Python virtual environment" -a envname
    if test (count $argv) -eq 0
        echo (set_color red)"Usage: pye &lt;envname&gt;"(set_color normal)
        return 1
    end

    set -l enapath ~/Developer/e/$envname/bin/activate.fish
    if test -f $enapath
        source $enapath
    else
        echo (set_color red)"No such environment: $envname"(set_color normal)
        return 1
    end
end

complete -c pye -f
for f in ~/Developer/e/*
    if test -d $f
        set -l envver (grep '^version =' $f/pyvenv.cfg | cut -d= -f2 | string trim)
        complete -c pye -n __fish_use_subcommand -a (basename $f) -d $envver
    end
end
