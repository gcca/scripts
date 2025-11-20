function cp-signin -d "Sign in to Control Plane"
  argparse 's/staging' 'p/prod' -- $argv
  if not command -q http
    source ~/Developer/e/13/bin/activate.fish
  end
  if set -q _flag_s
    set -g CP_URL $CP_BASE_URL_PROD
  else
    set -g CP_URL $CP_BASE_URL_STAGING
  end
  set -g CP_TOKEN (http --verify=no --form $CP_URL/api/auth/token username=$CP_USERNAME password=$CP_PASSWORD | python -c "import json,sys;print(json.load(sys.stdin)['access_token'])")
end
