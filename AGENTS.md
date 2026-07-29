# Notes for coding agents

Context for anyone (human or agent) editing this repo. This is a personal,
single-user Windows 11 Home setup — not a general-purpose framework. Optimize
for *this* machine, not for portability.

## Golden rules

- **Never commit or push without explicit approval.** Make the edit, show the
  diff, then wait. Avoid `git commit -a` / `-am`: the user often has concurrent
  edits in the working tree that it would sweep in.
- **`bootstrap.cmd` and `dotfiles/link.cmd` must stay CRLF.** They travel via
  `curl` and git to a bare machine and run under cmd.exe. `.gitattributes` pins
  `*.cmd -text`. After a multi-line edit, verify line endings didn't get
  normalized to LF.
- **Linear, crash-on-failure.** Every meaningful line in `bootstrap.cmd` ends
  with `|| exit /b` so the script stops at the first failure (batch otherwise
  continues on error). Don't add cleverness, retries, or error recovery. Lines
  *without* the guard are deliberately allowed to fail so a re-run is safe.
- **`call` before every `.cmd` shim** (`scoop`, `npm`) — without `call`, batch
  jumps into the shim and never returns.

## Architecture

- **`bootstrap.cmd`** — the one deliverable. Runs on a fresh, non-admin cmd
  prompt. Order matters and is load-bearing (see below).
- **`dotfiles/`** — loose files tracked here and **symlinked** into home by
  `link.cmd` (the "link wheel": `:link <repo file> <target under %USERPROFILE%>`).
  Symlinks point home→repo so in-place edits show up as git diffs. Needs
  Developer Mode for `mklink` without admin.
- **`dotfiles/windows-terminal-settings/`** — a *separate* repo cloned in here
  (gitignored), linked via `link.cmd`. Its `settings.json` is the real target.
- **`pyproject.toml.template`** — lives at repo root, **not** linked. Copied on
  demand by the `pyproject` fish function.
- Fish, Neovim, and Windows Terminal settings each stay in **their own repos**
  on purpose — each is its own ecosystem and shouldn't have changes mixed in.
  `bootstrap.cmd` clones them into place; their changes are tracked in those
  repos, not this one.

## Ordering gotchas in bootstrap.cmd (don't "tidy" these)

- `setx` writes the **permanent** user environment (registry); it does **not**
  affect the current session. So anything the script itself needs later
  (`UV_*`, nodejs on PATH, uv tool shims) is *also* set with `set` in-session.
- `scoop install git` runs **before** `scoop bucket add extras` — scoop uses git
  to clone buckets. `vcredist2022` lives in the extras bucket.
- `pacman -Syu` runs **twice** — the first pass may only upgrade the core
  (runtime, pacman) and stop.
- `npm install -g npm` runs before other npm globals so the global npm lands in
  the persist dir and survives nodejs updates.

## Environment facts

- User's daily shell is MSYS2 fish. MSYS2 honors the Windows `HOME`, so
  `setx HOME %USERPROFILE%` is the only glue — path handling is otherwise
  transparent; don't add fixups.
- No global Python. Use `uv run` / `uv tool`; never call `python`/`pip`.
- CapsLock→Ctrl is done in hardware now; the `.reg` is kept only for machines
  without that keyboard.

## When unsure

Ask. The user knows this machine and prefers simple, explicit wording over
hand-holding. Don't explain command-line basics in README or comments.
