function gsh-tun -d """gsh tunnel"""
    set -l port $argv[1]
    ssh -L $port:localhost:$port macstudio
end
