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

# `/.` copies the template's dotfiles too (.claude/); -n never clobbers.
cp -rn "$(dirname "$0")/pyproject-template/." .
