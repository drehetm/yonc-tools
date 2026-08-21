#!/usr/bin/env zsh

set -euo pipefail

base_ref="${1:-origin/develop}"
repo_root="$(git rev-parse --show-toplevel)"

cd "$repo_root"

git rev-parse --verify "${base_ref}^{commit}" >/dev/null

typeset -a changed_files=()

while IFS= read -r -d '' file; do
    changed_files+=("$file")
done < <(
    git diff \
        --name-only \
        --diff-filter=ACMR \
        -z \
        "${base_ref}...HEAD" \
        -- '*.py'
)

if (( ${#changed_files[@]} == 0 )); then
    print "No changed Python files found relative to ${base_ref}."
    exit 0
fi

print "Running ruff-format for:"
printf '  %s\n' "${changed_files[@]}"

pre-commit run ruff-format --files "${changed_files[@]}"

