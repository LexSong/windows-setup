#!/usr/bin/env sh
# Report project config I keep forgetting to add. Wired to SessionStart in
# ~/.claude/settings.json so Claude is told once per session; also runnable by
# hand through the `checkup` fish function.
#
# Prints nothing when there is nothing to say. Only speaks about my own repos --
# a foreign clone's conventions are its own business. Silence one repo with a
# .claude/no-checkup marker.

root=$(cd "${1:-$PWD}" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0

if [ -e .claude/no-checkup ]; then
    exit 0
fi

case "$(git remote get-url origin 2>/dev/null)" in
    "" | *github.com/LexSong/* | *github.com:LexSong/*) ;;
    *) exit 0 ;;
esac

findings=""
add() {
    findings="$findings  - $1
"
}

if [ -f AGENTS.md ] && [ ! -f CLAUDE.md ]; then
    add "AGENTS.md but no CLAUDE.md -- the notes are not auto-loaded (fix: a CLAUDE.md containing @AGENTS.md)"
fi

if [ -f pyproject.toml ]; then
    if ! grep -q force-single-line pyproject.toml; then
        add "pyproject.toml has no force-single-line -- ruff's isort will recombine split imports"
    fi
    if [ ! -f .pre-commit-config.yaml ]; then
        add "no .pre-commit-config.yaml -- nothing formats Python on the way into a commit (cp -rn ~/windows-setup/scripts/pyproject-template/. .)"
    elif [ ! -f .git/hooks/pre-commit ]; then
        add ".pre-commit-config.yaml is present but was never installed -- the hooks do not run (fix: pre-commit install)"
    fi
    # The template used to ship this hook; pre-commit replaced it.
    if grep -q PostToolUse .claude/settings.json 2>/dev/null &&
        grep -q ruff .claude/settings.json 2>/dev/null; then
        add "a PostToolUse ruff hook in .claude/settings.json still reformats every edit (fix: drop the hook, or the whole file if that is all it holds)"
    fi
fi

if [ -d .venv/Lib/site-packages ]; then
    # Same volume is the whole precondition -- uv can only hardlink within one, and
    # a venv that sits away from the cache has no fix worth reporting.
    cache=$(readlink -f "$(cygpath -u "$(uv cache dir)")")
    if [ "$(printf %s "$cache" | cut -d/ -f2)" = "$(printf %s "$(readlink -f .venv)" | cut -d/ -f2)" ] &&
        [ -z "$(find .venv/Lib/site-packages -maxdepth 3 -type f -links +1 -print -quit)" ]; then
        add "nothing in .venv is hardlinked though the uv cache shares its volume -- every wheel is stored twice (fix: uv sync --reinstall)"
    fi
fi

if [ -z "$findings" ]; then
    exit 0
fi

printf 'project-checkup (%s) -- mention these once; do not fix them unasked:\n%s' "${root##*/}" "$findings"
