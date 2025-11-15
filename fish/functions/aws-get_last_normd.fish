function aws-get_last_normd -d 'get last normalized job feed'
    set -l dt (python3 -c "
from datetime import datetime, timedelta
future = datetime.now() + timedelta(hours=5)
print(future.strftime('%Y|%m|%d|%H'))
")
    set -l parts (string split '|' $dt)
    set -l year $parts[1]
    set -l month $parts[2]
    set -l day $parts[3]
    set -l hour $parts[4]

    set -l source "$JL_DATALAKE_S/$JL_PATH_JOB_FEEDS/year=$year/month=$month/day=$day/hour=$hour/"
    set -l dest "test_input/$JL_PATH_JOB_FEEDS/year=$year/month=$month/day=$day/hour=$hour/"

    mkdir -p $dest
    aws s3 cp $source $dest --recursive --exclude "*" --include "normalized_jobs_*.parquet" $AWS_PROFILE
end
