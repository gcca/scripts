function g-pull-themes -d "Download themes for fish and kitty and …"
  git clone --depth=1 --single-branch -b main git@github.com:mattmc3/themepak.fish.git ~/.config/fish/themepath.fish.git
  ln -s ~/.config/fish/themepak.fish/themes ~/.config/fish/themes`
end
