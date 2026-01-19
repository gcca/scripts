function g-tmux -d "Starts tmux with 4 windows for a project and its Python environment"
    if test (count $argv) -ne 2
        echo "Usage: g-tmux <project_name> <python_environment>"
        return 1
    end

    set -l project $argv[1]
    set -l env $argv[2]
    set -l SESSION "$project"

    if tmux has-session -t $SESSION 2>/dev/null
        if test -z "$TMUX"
            tmux attach-session -t $SESSION
        else
            tmux switch-client -t $SESSION
        end
        return
    end

    tmux new-session -d -s $SESSION -n ed

    tmux send-keys -t $SESSION:0 "dev-go $project" C-m
    tmux send-keys -t $SESSION:0 "py-env $env" C-m
    tmux send-keys -t $SESSION:0 clear C-m

    tmux new-window -t $SESSION -n sv
    tmux send-keys -t $SESSION:1 "dev-go $project" C-m
    tmux send-keys -t $SESSION:1 "py-env $env" C-m

    tmux new-window -t $SESSION -n ag
    tmux send-keys -t $SESSION:2 "dev-go $project" C-m
    tmux send-keys -t $SESSION:2 "py-env $env" C-m
    tmux send-keys -t $SESSION:2 clear C-m

    tmux new-window -t $SESSION -n sh
    tmux send-keys -t $SESSION:3 "dev-go $project" C-m
    tmux send-keys -t $SESSION:3 "py-env $env" C-m
    tmux send-keys -t $SESSION:3 clear C-m

    if test -z "$TMUX"
        tmux attach-session -t $SESSION
    else
        tmux switch-client -t $SESSION
    end
end

complete -c g-tmux -f

for f in ~/Developer/*
    if test -d $f -a -d $f/.git
        set -l url (git --git-dir=$f/.git remote get-url origin 2>/dev/null; or echo "no remote")
        complete -c g-tmux -n "test (count (commandline -opc)) -eq 1" -a (basename $f) -d "$url"
    end
end

for f in ~/Developer/e/*
    if test -d $f
        set -l envver (grep '^version =' $f/pyvenv.cfg 2>/dev/null | cut -d= -f2 | string trim; or echo "unknown")
        complete -c g-tmux -n "test (count (commandline -opc)) -eq 2" -a (basename $f) -d "Python $envver"
    end
end
