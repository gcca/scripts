function g-fishfns-sync -d "Sync fish functions from the repository to the config directory"
    set -l real_script (readlink -f (status filename))
    set -l script_dir (dirname $real_script)
    set -l config_functions_dir ~/.config/fish/functions

    mkdir -p $config_functions_dir

    preview_sync $script_dir $config_functions_dir

    read -l -P (set_color yellow)"Proceed with sync? (y/N): "(set_color normal) confirm
    if not string match -qi y $confirm
        echo (set_color red)"Sync cancelled."(set_color normal)
        return 0
    end

    remove_existing_symlinks $script_dir $config_functions_dir
    create_symlinks $script_dir $config_functions_dir

    echo (set_color green)"Sync completed successfully."(set_color normal)
end

function preview_sync
    set -l script_dir $argv[1]
    set -l config $argv[2]
    set -l sources (basename -a $script_dir/*.fish)

    set -l to_delete
    set -l to_create
    set -l to_keep
    set -l skipped

    for link in $config/*.fish
        if test -L $link
            set -l target (readlink $link)
            if string match -q "$script_dir/*" $target
                set -l name (basename $link)
                if not contains $name $sources
                    set to_delete $to_delete $name
                else
                    set to_keep $to_keep $name
                end
            end
        end
    end

    for f in $sources
        set -l tgt "$config/$f"
        if test -e $tgt
            if not test -L $tgt
                set skipped $skipped $f
            end
        else
            set to_create $to_create $f
        end
    end

    echo (set_color --bold magenta)"=== Fish Functions Sync Preview === "(set_color normal)
    echo ""

    if test (count $to_delete) -gt 0
        echo (set_color --bold red)"🗑  Files to be removed:"(set_color normal)
        for f in $to_delete
            echo "   • $f"
        end
        echo ""
    end

    if test (count $to_create) -gt 0
        echo (set_color --bold green)"✨ New files to be created:"(set_color normal)
        for f in $to_create
            echo "   • $f"
        end
        echo ""
    end

    if test (count $skipped) -gt 0
        echo (set_color --bold yellow)"⚠️  Files skipped (regular file exists):"(set_color normal)
        for f in $skipped
            echo "   • $f"
        end
        echo ""
    end

    if test (count $to_keep) -gt 0
        echo (set_color --bold blue)"🔄 Files to be updated/kept:"(set_color normal)
        for f in $to_keep
            echo "   • $f"
        end
        echo ""
    end

    if test (count $to_delete) -eq 0 -a (count $to_create) -eq 0 -a (count $skipped) -eq 0
        echo (set_color cyan)"All symlinks are up to date."(set_color normal)
    end
end

function remove_existing_symlinks
    set -l script_dir $argv[1]
    set -l config_functions_dir $argv[2]

    for link in $config_functions_dir/*.fish
        if test -L $link
            set -l target (readlink $link)
            if string match -q "$script_dir/*" $target
                rm $link
            end
        end
    end
end

function create_symlinks
    set -l script_dir $argv[1]
    set -l config_functions_dir $argv[2]

    for file in $script_dir/*.fish
        set -l basename (basename $file)
        set -l target $config_functions_dir/$basename

        if test -e $target
            if not test -L $target
                continue
            end
        end

        if not test -L $target
            ln -s $file $target
        end
    end
end
