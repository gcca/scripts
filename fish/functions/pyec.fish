function pyec -d "Create Python virtual environment" -a envname
    if test (count $argv) -eq 0
        echo (set_color red)"Usage: pyec &lt;envname&gt;"(set_color normal)
        return 1
    end

    set -l envdir ~/Developer/e/$envname
    if test -d $envdir
        echo (set_color yellow)"Environment already exists: $envname"(set_color normal)
        return 1
    end

    if not command -q python3.13
        echo (set_color red)"python3.13 not found"(set_color normal)
        return 1
    end

    python3.13 -m venv $envdir
end
