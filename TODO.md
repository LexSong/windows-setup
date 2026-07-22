# TODO

## Repo refactoring

- [ ] Rename the GitHub dotfiles repo to dotfiles-old (local `~/.dotfiles` is
      already retired).
- [ ] Remove `link-settings.cmd` from the windows-terminal-settings repo —
      superseded by `dotfiles\link.cmd` linking its `settings.json` directly.
- [ ] Better mechanism for `pyproject.toml.template`. Pain points: `name` must be
      hand-edited per project; the pyright venv block differs between uv and pixi
      projects; the pytorch `cu132` index is machine-specific and goes stale.
      Candidates: a `just new-project` recipe that runs `uv init` and patches the
      result; a copier/cookiecutter template repo; or shrink the template by moving
      ruff/pyright defaults into global config where possible.
