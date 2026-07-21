# TODO

## bootstrap.cmd

- [ ] `yt-sub-txt`: personal uv tool with an unknown install source (PyPI? git URL?
      local path?) — add it to the uv tools section once decided.
- [ ] Test the whole script on a fresh machine or VM.

## Repo refactoring

- [ ] Move fish settings (`.config/fish/`) out of dotfiles into a separate repo.
- [ ] Better mechanism for `pyproject.toml.template`. Pain points: `name` must be
      hand-edited per project; the pyright venv block differs between uv and pixi
      projects; the pytorch `cu132` index is machine-specific and goes stale.
      Candidates: a `just new-project` recipe that runs `uv init` and patches the
      result; a copier/cookiecutter template repo; or shrink the template by moving
      ruff/pyright defaults into global config where possible.

## Open questions

- [ ] Anything else scoop-installed but machine-specific (llama-swap, adb/scrcpy,
      mitmproxy...) that should move to an optional group rather than the default
      install?
