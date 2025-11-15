function git-ci-ts -d "Commit with timestamp YYYYMMDDHHMMSS as message"
    git ci -m (date +%Y%m%d%H%M%S)
end
