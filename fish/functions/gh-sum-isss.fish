function gh-sum-isss -d 'List GitHub issues between two dates'
    # Check dependencies silently
    command -q gh && gh auth status >/dev/null 2>&1 && command -q jq; or return 1

    set -l start_date $argv[1]
    set -l end_date $argv[2]

    # Build date filter
    set -l date_filter
    if test -n "$start_date" -a -n "$end_date"
        set date_filter --created "$start_date..$end_date"
    else if test -n "$start_date"
        set date_filter --created ">$start_date"
    else
        set date_filter --created ">"(date -v-1m +%Y-%m-%d)
    end

    # Fetch issues and process with jq
    gh search issues --assignee=@me $date_filter \
        --json url,title,body,state,repository,labels,commentsCount,updatedAt,createdAt \
        --limit 1000 2>/dev/null | jq -c '.[]' | while read -l issue
        set -l url (echo $issue | jq -r '.url')
        # Convert GitHub web URL to API path
        set -l api_path (echo $url | sed 's|https://github.com/|repos/|' | sed 's|$|/comments|')
        set -l comments_json (gh api "$api_path" --paginate 2>/dev/null)
        set -l comments "[]"
        if test $status -eq 0
            set comments (echo $comments_json | jq -c 'map({body, created_at, id, user: (.user | {id, login, type})})' 2>/dev/null)
            if test $status -ne 0
                set comments "[]"
            end
        end
        echo "{\"issue\": $issue, \"comments\": $comments}"
    end | jq -s 'map(.issue + {comments: .comments})'
end
