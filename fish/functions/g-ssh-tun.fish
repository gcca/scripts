function g-ssh-tun -d 'ssh tunnel'
  set -l port $argv[1]
  ssh -L $port:localhost:$port macstudio
end
