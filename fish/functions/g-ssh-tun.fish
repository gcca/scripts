function g-ssh-tun -d 'ssh tunnel'
  if test (count $argv) -eq 0
      echo (set_color red)"Usage: g-ssh-tun <port>"(set_color normal)
      return 1
  end
  set -l port $argv[1]
  ssh -L $port:localhost:$port macstudio
end
