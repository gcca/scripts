function dev-go -d "Go to development directory"
    if test (count $argv) -eq 0
        set -l dirs (find ~/Developer -maxdepth 1 -type d -name ".*" -prune -o -type d -exec test -d {}/.git \; -print | xargs basename)
        set name (string join \n $dirs | fzf --preview "cat ~/Developer/{}/.git/config || echo 'No git'")
    else
        set name $argv[1]
    end
    cd ~/Developer/$name
end

complete -c dev-go -f
for f in ~/Developer/*
    if test -d $f -a -d $f/.git
        set -l url (git --git-dir=$f/.git remote get-url origin 2>/dev/null; or echo "no remote")
        complete -c dev-go -n __fish_use_subcommand -a (basename $f) -d $url
    end
end
