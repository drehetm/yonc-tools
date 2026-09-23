#!/usr/bin/env zsh

set -euo pipefail

[[ $# == 2 && "$2" == <-> ]] || {
    print -u2 "Usage: ${0:t} <router|admin|envoy|synthetic> <pipeline ID>"
    exit 2
}
: "${GITLAB_TOKEN:?Set GITLAB_TOKEN to a token with read_api scope}"

readonly gitlab_url="https://gitlab.services.yomobile.in"
readonly project_name="$1"
readonly pipeline_id="$2"

case "$project_name" in
    router) readonly project="yonc/backend/yonc-router" ;;
    admin) readonly project="yonc/backend/yonc-router-admin" ;;
    envoy) readonly project="yonc/backend/yonc-envoy" ;;
    synthetic) readonly project="yonc/backend/yonc-synthetic" ;;
    *) print -u2 "Unknown project: $project_name"; exit 2 ;;
esac

url="$gitlab_url/api/v4/projects/$(jq -nr --arg project "$project" '$project | @uri')/pipelines/$pipeline_id"
print "Watching GitLab $project_name pipeline $pipeline_id..."

while true; do
    pipeline="$(curl -fsS --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$url" | jq -er '[.status, .finished_at // ""] | @tsv')"
    pipeline_status="${pipeline%%$'\t'*}"
    [[ -n "${pipeline#*$'\t'}" ]] && break
    sleep 30
done

print "GitLab $project_name pipeline $pipeline_id: $pipeline_status"
printf '\e]9;GitLab %s pipeline %s: %s\a\n' "$project_name" "$pipeline_id" "$pipeline_status"

