function py-venv -d "Create to a python version" -a envname
    python3.13 -mvenv ~/Developer/e/$envname
end

complete -c py-env -f
for f in ~/Developer/e/*
    if test -d $f
        set -l envver (grep '^version =' $f/pyvenv.cfg | cut -d= -f2 | string trim)
        complete -c py-env -n __fish_use_subcommand -a (basename $f) -d $envver
    end
end
