function dg -d "Go to development directory"
   if test (count $argv) -eq 0
       set -l dirs (find ~/Developer -maxdepth 1 -type d -name ".*" -prune -o -type d -exec test -d {}/.git \; -print | xargs basename)
       set name (string join \n $dirs | fzf --preview "cat ~/Developer/{}/.git/config || echo 'No git'")
   else
       set name $argv[1]
   end
    cd ~/Developer/$name

    if test -f .pdm-python
        set -l py (cat .pdm-python | string trim)
        set -l act (dirname $py)/activate.fish
        if test -f $act
            source $act
        end
    else if test -d ~/Developer/e/13/bin
        source ~/Developer/e/13/bin/activate.fish
    end
end

complete -c dg -f
for f in ~/Developer/*
    if test -d $f -a -d $f/.git
        set -l url (git --git-dir=$f/.git remote get-url origin 2>/dev/null; or echo "no remote")
        complete -c dg -n __fish_use_subcommand -a (basename $f) -d $url
    end
end
