function squash_all_commits
    set -l root (git rev-list --max-parents=0 HEAD 2>/dev/null)
    if test $status -ne 0
        echo "Error: Unable to find root commit. Is this a git repository with commits?"
        return 1
    end
    set -l msg (git log --format=%s -1 $root 2>/dev/null)
    if test $status -ne 0
        echo "Error: Unable to get commit message."
        return 1
    end
    git reset --soft $root 2>/dev/null
    if test $status -ne 0
        echo "Error: Failed to reset to root commit."
        return 1
    end
    git commit -m "$msg" 2>/dev/null
    if test $status -ne 0
        echo "Error: Failed to commit."
        return 1
    end
end

function squash_last_n_commits
    set -l n $argv[1]
    if not string match -qr '^[0-9]+$' $n
        echo "Error: Argument must be a positive integer."
        return 1
    end
    if test $n -le 0
        echo "Error: Number of commits must be greater than 0."
        return 1
    end
    set -l target HEAD~$n
    set -l msg (git log --format=%s -1 $target 2>/dev/null)
    if test $status -ne 0
        echo "Error: Unable to get commit message or not enough commits."
        return 1
    end
    git reset --soft $target 2>/dev/null
    if test $status -ne 0
        echo "Error: Failed to reset."
        return 1
    end
    git commit -m "$msg" 2>/dev/null
    if test $status -ne 0
        echo "Error: Failed to commit."
        return 1
    end
end

function git-rb1st
    set -l n $argv[1]
    if test -z "$n"
        squash_all_commits
    else
        squash_last_n_commits $n
    end
end
