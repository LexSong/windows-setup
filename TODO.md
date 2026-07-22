# TODO

## Repo refactoring

- [ ] Create the fish repo from `~/.config/fish`, then enable its clone line in
      bootstrap.cmd.
- [ ] Retire the bare dotfiles repo once fish has its own repo: run
      `dotfiles\link.cmd` here, delete `~/.dotfiles`, and rename the GitHub repo
      to dotfiles-old.
- [ ] Remove `link-settings.cmd` from the windows-terminal-settings repo —
      superseded by `dotfiles\link.cmd` linking its `settings.json` directly.
- [ ] Remove the old `~/windows-terminal-settings` clone once the new location
      (`windows-setup/dotfiles/windows-terminal-settings`) is linked and working.
- [ ] Better mechanism for `pyproject.toml.template`. Pain points: `name` must be
      hand-edited per project; the pyright venv block differs between uv and pixi
      projects; the pytorch `cu132` index is machine-specific and goes stale.
      Candidates: a `just new-project` recipe that runs `uv init` and patches the
      result; a copier/cookiecutter template repo; or shrink the template by moving
      ruff/pyright defaults into global config where possible.
