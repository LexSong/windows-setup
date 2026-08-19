#!/usr/bin/env sh
# Scaffold a new Python project from pyproject-template/ next to this script.
# Runnable by hand through the `pyproject` fish function.
#
# Refuses to touch a project that already has a pyproject.toml -- to top up an
# existing one, project-checkup.sh suggests the bare `cp -rn` instead.

if [ -e pyproject.toml ]; then
    echo 'pyproject.toml already exists' >&2
    exit 1
fi

# `/.` copies the template's dotfiles too (.pre-commit-config.yaml); -n never
# clobbers.
cp -rn "$(dirname "$0")/pyproject-template/." .

# A config file alone does nothing -- pre-commit only runs once it has written
# .git/hooks/pre-commit, and it can only do that inside a repo. Scaffolding a
# project before `git init` is fine, so this is the one step that may be
# skipped; project-checkup.sh reports it if it was.
if git rev-parse --git-dir >/dev/null 2>&1; then
    pre-commit install
fi
