function gh-sum-isss -d 'List GitHub issues from the last N months (default 1), where N is the number of months back from current month'
    # Check if gh CLI is available and authenticated
    if not command -q gh
        echo "Error: GitHub CLI (gh) is not installed or not in PATH" >&2
        return 1
    end

    if not gh auth status >/dev/null 2>&1
        echo "Error: Not authenticated with GitHub CLI. Run 'gh auth login' first" >&2
        return 1
    end

    # Check if jq is available
    if not command -q jq
        echo "Error: jq is not installed or not in PATH" >&2
        return 1
    end

    set -l inicio $argv[1]
    set -l fin $argv[2]

    # Validate date format if provided
    if test -n "$inicio"
        # Basic validation - dates should be in YYYY-MM-DD format or relative like "2024-01-01"
        if not string match -qr '^\d{4}-\d{2}-\d{2}$' "$inicio" 2>/dev/null
            echo "Warning: Start date '$inicio' may not be in expected format (YYYY-MM-DD)" >&2
        end
    end

    if test -n "$fin"
        if not string match -qr '^\d{4}-\d{2}-\d{2}$' "$fin" 2>/dev/null
            echo "Warning: End date '$fin' may not be in expected format (YYYY-MM-DD)" >&2
        end
    end

    set -l fecha_filter ""
    if test -n "$inicio"
        if test -n "$fin"
            set -l fecha_filter --updated "$inicio..$fin"
        else
            set -l fecha_filter --updated ">$inicio"
        end
    end

    echo "Fetching issues with filters: $fecha_filter" >&2

    # Fetch issues with error handling
    set -l issues_output
    if not set issues_output (gh search issues --assignee=@me --state=open $fecha_filter \
        --json url,title,body,state,repository,labels,commentsCount,updatedAt,createdAt \
        --limit 1000 2>&1)
        echo "Error: Failed to search issues: $issues_output" >&2
        return 1
    end

    # Parse issues JSON with error handling
    set -l issues
    if not set issues (echo $issues_output | jq -c '.[]' 2>/dev/null)
        echo "Error: Failed to parse issues JSON response" >&2
        echo "Raw response: $issues_output" >&2
        return 1
    end

    if test (count $issues) -eq 0
        echo "No issues found matching the criteria" >&2
        echo "[]" | jq .
        return 0
    end

    echo "Found "(count $issues)" issues. Fetching comments..." >&2

    set -l resultado []
    set -l processed_count 0

    for issue in $issues
        # Parse issue JSON safely
        set -l issue_json
        if not set issue_json (echo $issue | jq -c '.' 2>/dev/null)
            echo "Warning: Failed to parse issue JSON, skipping: $issue" >&2
            continue
        end

        # Extract issue URL safely
        set -l issue_url
        if not set issue_url (echo $issue_json | jq -r '.url' 2>/dev/null)
            echo "Warning: Failed to extract issue URL, skipping" >&2
            continue
        end

        # Fetch comments with better error handling and pagination
        set -l comments "[]"
        set -l comments_output (gh api "$issue_url/comments" --paginate --limit 1000 2>/dev/null)
        if test $status -eq 0
            # Parse comments JSON safely
            set comments (echo $comments_output | jq -c '. // []' 2>/dev/null)
            if test $status -ne 0
                echo "Warning: Failed to parse comments JSON for issue $issue_url, using empty array" >&2
                set comments "[]"
            end
        else
            echo "Warning: Failed to fetch comments for issue $issue_url, using empty array" >&2
        end

        # Combine issue with comments
        set -l issue_full
        if set issue_full (echo $issue_json | jq --argjson c "$comments" '. + {comments: $c}' 2>/dev/null)
            set resultado $resultado $issue_full
        else
            echo "Warning: Failed to combine issue with comments for $issue_url" >&2
        end

        set processed_count (math $processed_count + 1)
        if test (math $processed_count % 10) -eq 0
            echo "Processed $processed_count/"(count $issues)" issues..." >&2
        end
    end

    echo "Completed processing "(count $resultado)" issues with comments" >&2

    # Output final JSON with error handling
    if not echo $resultado | jq . 2>/dev/null
        echo "Error: Failed to format final JSON output" >&2
        return 1
    end
end
