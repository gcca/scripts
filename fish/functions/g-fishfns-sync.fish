function g-fishfns-sync -d "Sync fish functions from the repository to the config directory"
    set -l real_script (readlink -f (status filename))
    set -l script_dir (dirname $real_script)
    set -l config_functions_dir ~/.config/fish/functions

    mkdir -p $config_functions_dir

    remove_existing_symlinks $script_dir $config_functions_dir

    create_symlinks $script_dir $config_functions_dir
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
        if not test -L $config_functions_dir/$basename
            ln -s $file $config_functions_dir/$basename
        end
    end
end
