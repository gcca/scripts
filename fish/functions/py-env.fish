function py-env -d "Switch to a python version" -a envname
    set -l enapath ~/Developer/e/$envname/bin/activate.fish
    if test -f $enapath
        source $enapath
    else
        echo "No such environment: $envname"
    end
end

complete -c py-env -f
for f in ~/Developer/e/*
    if test -d $f
        set -l envver (grep '^version =' $f/pyvenv.cfg | cut -d= -f2 | string trim)
        complete -c py-env -n __fish_use_subcommand -a (basename $f) -d $envver
    end
end
