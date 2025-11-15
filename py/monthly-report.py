#!/usr/bin/env python3
"""
Monthly report generator script using GitHub CLI and xAI.
"""
# pylint: disable=invalid-name

import sys
import datetime
import subprocess
import argparse

from xai_sdk import Client
from xai_sdk.chat import system, user


def calculate_dates(n):
    """
    Calculate start and end dates for the report based on number of months back.

    Args:
        n (int): Number of months back from current month.

    Returns:
        tuple: (start_date_str, end_date_str) in ISO format.
    """
    now = datetime.datetime.now()
    start_year = now.year
    start_month = now.month - n
    if start_month <= 0:
        start_year -= 1
        start_month += 12
    start_date = datetime.date(start_year, start_month, 1)
    end_year = now.year
    end_month = now.month + 1
    if end_month > 12:
        end_year += 1
        end_month = 1
    end_date = datetime.date(end_year, end_month, 1)
    return start_date.isoformat(), end_date.isoformat()


def run_gh_search(start_date, end_date):
    """
    Run GitHub CLI search for pull requests created between start and end dates.

    Args:
        start_date (str): Start date in ISO format.
        end_date (str): End date in ISO format.

    Returns:
        str: JSON output from gh search command.
    """
    search_str = f"created:{start_date}..{end_date}"
    cmd = [
        "gh",
        "search",
        "prs",
        "author:@me",
        search_str,
        "--json",
        "number,title,createdAt,repository,body",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        print("Error running gh command:", result.stderr)
        sys.exit(1)
    return result.stdout


def main():
    """
    Main function to parse arguments and output PR JSON data.
    """
    parser = argparse.ArgumentParser(
        description="Generate monthly PR JSON output"
    )
    parser.add_argument(
        "--months",
        "-n",
        type=int,
        default=1,
        help="Number of months back (default: 1)",
    )
    parser.add_argument(
        "--output",
        "-o",
        type=str,
        default=None,
        help="Output file for JSON (default: stdout)",
    )
    parser.add_argument(
        "--message", "-m", required=True, help="System prompt message for xAI"
    )
    args = parser.parse_args()
    client = Client()
    n = args.months
    start_date, end_date = calculate_dates(n)
    json_output = run_gh_search(start_date, end_date)
    messages = [system(args.message), user(json_output)]
    chat = client.chat.create(model="grok-4-1-fast-reasoning", messages=messages)
    response = chat.sample()
    result = response
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(result)
    else:
        print(result)


if __name__ == "__main__":
    main()
