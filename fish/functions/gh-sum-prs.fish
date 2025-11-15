function gh-sum-prs -d 'List GitHub pull requests from the last N months (default 1), where N is the number of months back from current month'
    set -l N 1
    if set -q argv[1]
        set -l N $argv[1]
    end

    set -l start_date (date -v-$N'm' +'%Y-%m-01')
    set -l end_date (date -v+1'm' +'%Y-%m-01')
    set -l search_str "created:$start_date..$end_date"
    gh search prs author:@me $search_str --json number,title,createdAt,repository,body
end
