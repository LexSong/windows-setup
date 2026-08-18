# Notes for coding agents

Context for anyone (human or agent) editing this repo. This is the
version-controlled layer of one personal Windows 11 Home machine — `$HOME`
itself isn't a repo, so anything on this machine worth tracking lands here.
`bootstrap.cmd` is the largest deliverable, not the scope. It's a single-user
setup, not a general-purpose framework: optimize for *this* machine, not for
portability.

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

**Where things go.** Every directory here has an entry criterion about
*presence*, so nothing is a residual junk drawer:

- **`dotfiles/`** — the *linkage* layer: a file belongs here only if `link.cmd`
  symlinks it into home. Membership **means** "this is linked", so a file that
  stops being linked moves out.
- **`scripts/`** — the *payload* layer: everything run from the clone, whether
  something outside this repo reaches it by path (fish functions, a hook in
  `~/.claude/settings.json`) or I run it by hand. A script's own data
  (`pyproject-template/`) sits next to it.
- **root** — `bootstrap.cmd`, the only file fetched before the clone exists,
  plus repo metadata. Nothing else: once the repo is on disk everything is
  reachable by path, so nothing else earns a raw URL.

The fish repo is the *interface* layer on top of `scripts/` — thin wrappers, no
logic. Because callers reach in by path, **moving anything in `scripts/` means
editing its caller in the fish repo or `~/.claude/settings.json`**, both outside
this repo (and the latter isn't version-controlled at all).

- **`bootstrap.cmd`** — the one deliverable. Runs on a fresh, non-admin cmd
  prompt. Order matters and is load-bearing (see below).
- **`dotfiles/`** — loose files tracked here and **symlinked** into home by
  `link.cmd` (the "link wheel": `:link <repo file> <target under %USERPROFILE%>`).
  Symlinks point home→repo so in-place edits show up as git diffs. Needs
  Developer Mode for `mklink` without admin.
- **`dotfiles/windows-terminal-settings/`** — a *separate* repo cloned in here
  (gitignored), linked via `link.cmd`. Its `settings.json` is the real target.
- **`scripts/pyproject.sh`** — run by `pyproject`. Copies
  `scripts/pyproject-template/` wholesale into a new project (`cp -rn …/. .`),
  so the folder mirrors what lands: `pyproject.toml`, plus a
  `.claude/settings.json` whose PostToolUse hook runs ruff on Python files
  Claude edits. Grow the folder rather than teaching the script about individual
  files. It refuses to run where a `pyproject.toml` already exists; topping up
  an existing project is the bare `cp -rn` that `project-checkup.sh` suggests.
- **`scripts/yt-sub-txt.py`** — run by `yt-sub-txt` via `uv run --script`.
- **`scripts/project-checkup.sh`** — run by `checkup`, and by a `SessionStart`
  hook in `~/.claude/settings.json`. Names my own repos that are missing a
  `CLAUDE.md`, `force-single-line`, or the per-project format hook; silent
  otherwise, and silent about repos that aren't mine.
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
- Ruff handles Python imports too — `reorder-python-imports` was dropped, and with
  it the `--ignore=I001` workaround it forced. `force-single-line` in a project's
  `pyproject.toml` is what keeps one-import-per-line; don't reintroduce a second
  import tool.
- CapsLock→Ctrl is done in hardware now; `scripts/capslock-to-ctrl.ps1` is
  kept only for machines without that keyboard.
- Repo `.ps1` files run under **`pwsh`** with no execution-policy flag: pwsh
  ships a `powershell.config.json` setting LocalMachine to `RemoteSigned`, and a
  git clone carries no mark-of-the-web. Windows PowerShell 5.1 has no such
  default — this machine's `RemoteSigned` sits in HKCU and a fresh one wouldn't
  have it — so invoke them with `pwsh`, not `powershell`. The
  `-ExecutionPolicy Bypass` in `bootstrap.cmd` is per-invocation for the scoop
  installer's piped `iex`; it persists nothing.

## When unsure

Ask. The user knows this machine and prefers simple, explicit wording over
hand-holding. Don't explain command-line basics in README or comments.
