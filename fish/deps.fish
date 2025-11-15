#!/usr/bin/env fish

set -l fish_themes ~/.config/fish/themepath.fish.git
if not test -d $fish_themes/.git
    git clone --depth=1 git@github.com:mattmc3/themepak.fish.git $fish_themes
end

ln -sfn themepath.fish.git/themes ~/.config/fish/themes

mkdir -p ~/.config/kitty
set -l kitty_themes ~/.config/kitty/kitty-themes
if not test -d $kitty_themes/.git
    git clone --depth=1 https://github.com/kovidgoyal/kitty-themes.git $kitty_themes
end

mkdir -p ~/.config/delta
curl -L -o ~/.config/delta/themes.gitconfig https://raw.githubusercontent.com/dandavison/delta/main/themes.gitconfig
