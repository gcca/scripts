function gsh-tun -d "gsh tunnel"
    if test (count $argv) -eq 0
        echo (set_color red)"Usage: gsh-tun <port>"(set_color normal)
        return 1
    end
    set -l port $argv[1]
    ssh -L $port:localhost:$port macstudio
end
