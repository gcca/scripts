#!/usr/bin/env fish

set kb /dev/input/event4
set tp /dev/input/event7

if pgrep -f "evtest --grab $kb" >/dev/null
    pkill -f "evtest --grab $kb"
    pkill -f "evtest --grab $tp"
    echo "Teclado y touchpad reactivados"
else
    sudo evtest --grab $kb >/dev/null 2>&1 & disown
    sudo evtest --grab $tp >/dev/null 2>&1 & disown
    echo "Teclado y touchpad desactivados (temporal)"
end
