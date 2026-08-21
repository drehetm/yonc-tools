#!/usr/bin/env zsh

set -euo pipefail

# A migration name is required and must be the script's only argument.
if (( $# != 1 )); then
    print -u2 "Usage: ${0:t} <migration-name>"
    exit 2
fi

migration_name="$1"

# Reject an empty or whitespace-only name before invoking Atlas.
if [[ -z "${migration_name//[[:space:]]/}" ]]; then
    print -u2 "Migration name must not be empty."
    exit 2
fi

# Create the empty migration in the storage directory.
(
    cd storage
    atlas migrate new "$migration_name"
)

# Pause here so the generated SQL file can be edited before its hash is updated.
while true; do
    read "run_hash?Run 'atlas migrate hash' after editing the migration? [y/n] "

    case "${run_hash:l}" in
        y)
            # Recalculate atlas.sum only after the migration has been edited.
            (
                cd storage
                atlas migrate hash
            )
            break
            ;;
        n)
            print "Skipped 'atlas migrate hash'."
            break
            ;;
        *)
            print "Please answer y or n."
            ;;
    esac
done
