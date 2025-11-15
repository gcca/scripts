#!/usr/bin/env fish
git clone git@github.com:mattmc3/themepak.fish.git
git clone https://github.com/kovidgoyal/kitty-themes.git

mkdir -p ~/.config/delta
curl -L -o ~/.config/delta/themes.gitconfig https://raw.githubusercontent.com/dandavison/delta/main/themes.gitconfig
