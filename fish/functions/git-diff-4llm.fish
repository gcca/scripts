function git-diff-4llm
    for file in (git diff --name-only --cached)
        echo "=== $file (old) ==="
        git show HEAD:"$file"
        echo "=== $file (new) ==="
        cat "$file"
        echo ---
    end
end
