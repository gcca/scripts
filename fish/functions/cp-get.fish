function cp-get -d "Get from Control Plane"
    if test (count $argv) -lt 1
        echo "Usage: cp-get <endpoint> [id]"
        return 1
    end
    if not command -q http
        source ~/Developer/e/13/bin/activate.fish
    end
    if test (count $argv) -eq 1
        set url $CP_URL/api/$argv[1]/
    else
        set url $CP_URL/api/$argv[1]/$argv[2]
    end
    http --verify=no --auth-type=bearer --auth=$CP_TOKEN $url
end

complete -c cp-get -f
complete -c cp-get -n __fish_use_subcommand -a campaigns -d "Campaigns endpoint"
complete -c cp-get -n __fish_use_subcommand -a publishers -d "Publishers endpoint"
complete -c cp-get -n __fish_use_subcommand -a advertisers -d "Advertisers endpoint"
