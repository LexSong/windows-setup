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

The fish repo is the *interface* layer: every function there wraps a command,
and what it wraps decides where the work lives. `topgrade` and `gpu-limit` wrap
`topgrade` and `nvidia-smi` — arrangements of commands that already exist, so
fish holds all of them however long they get. `yt-sub-txt`, `pyproject`, and
`checkup` wrap a payload that had to be written, and payloads don't belong in
shell config, so fish keeps only the invocation. Two cases are forced: a
function that shadows the binary it calls (`restic`, `topgrade`) can only be a
function, and anything a non-fish caller needs — the `SessionStart` hook runs
`sh` — can only be a script.

Because callers reach in by path, **moving anything in `scripts/` means editing
its caller** — a function in the fish repo, or the `SessionStart` hook in
`dotfiles/.claude/settings.json`. The fish repo is a separate clone, so that
edit is tracked elsewhere; the Claude settings are linked into home from here,
so that one lands as a diff in this repo.

- **`bootstrap.cmd`** — the one deliverable. Runs on a fresh, non-admin cmd
  prompt. Order matters and is load-bearing (see below).
- **`dotfiles/`** — loose files tracked here and **symlinked** into home by
  `link.cmd` (the "link wheel": `:link <repo file> <target under %USERPROFILE%>`).
  Symlinks point home→repo so in-place edits show up as git diffs. Needs
  Developer Mode for `mklink` without admin.
- **`dotfiles/.claude/settings.json`** — Claude Code's user settings, holding the
  `SessionStart` hook that runs `scripts/project-checkup.sh`. Only this file is
  linked; `~/.claude/.credentials.json` and the rest of that directory stay out
  of the repo. The path is mirrored here because it's shallow —
  `yt-dlp.config` stays flat since `AppData\Roaming\yt-dlp\` isn't worth
  reproducing.
- **`dotfiles/windows-terminal-settings/`** — a *separate* repo cloned in here
  (gitignored), linked via `link.cmd`. Its `settings.json` is the real target.
- **`scripts/pyproject.sh`** — run by `pyproject`. Copies
  `scripts/pyproject-template/` wholesale into a new project (`cp -rn …/. .`),
  so the folder mirrors what lands: `pyproject.toml`, plus a
  `.pre-commit-config.yaml` running ruff at commit time. Grow the folder rather
  than teaching the script about individual files. The one exception is the
  `pre-commit install` it runs afterward: a config file does nothing until
  pre-commit writes `.git/hooks/pre-commit`, and that is a command, not a file.
  It refuses to run where a `pyproject.toml` already exists; topping up an
  existing project is the bare `cp -rn` that `project-checkup.sh` suggests —
  which is why that path leaves the hooks uninstalled and checkup reports it.
  Don't reintroduce editor- or agent-time formatting; a `PostToolUse` hook was
  tried and removed.
- **`scripts/yt-sub-txt.py`** — run by `yt-sub-txt` via `uv run --script`.
- **`scripts/project-checkup.sh`** — run by `checkup`, and by a `SessionStart`
  hook in `~/.claude/settings.json`. Names my own repos that are missing a
  `CLAUDE.md`, `force-single-line`, or pre-commit (config absent, or present
  but never installed), and venvs holding copies where uv could hardlink;
  silent otherwise, and silent about repos that aren't mine.
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
- **Portable by default.** Scoop installs apps stateless/portable, which is the
  preference, so `bootstrap.cmd` covers what scoop, uv, and npm can manage that
  way. The exceptions go to winget and stay out of the script: apps where
  portability causes more trouble than it saves (Chrome, wanted as a real
  stateful install so it can be the default browser; Steam), and anything
  needing admin plus a reboot (WSL, and Docker Sandboxes on top of it). Don't
  fold these in — bootstrap runs non-admin, linear, in one pass.
- Ruff handles Python imports too; don't add a second import tool.
  `force-single-line` in a project's `pyproject.toml` keeps one per line.
- CapsLock→Ctrl is done in hardware now; `scripts/capslock-to-ctrl.ps1` is
  kept only for machines without that keyboard.
- Repo `.ps1` files run under **`pwsh`** with no execution-policy flag: pwsh
  ships a `powershell.config.json` setting LocalMachine to `RemoteSigned`, and a
  git clone carries no mark-of-the-web. Windows PowerShell 5.1 has no such
  default — this machine's `RemoteSigned` sits in HKCU and a fresh one wouldn't
  have it — so invoke them with `pwsh`, not `powershell`. The
  `-ExecutionPolicy Bypass` in `bootstrap.cmd` is per-invocation for the scoop
  installer's piped `iex`; it persists nothing.
- README commands are written for the daily shell (fish/MSYS2), so paths use
  `~/`. pwsh doesn't expand `~` itself, so there is no form that also works in
  cmd.exe — `%USERPROFILE%` is cmd-only. Bootstrap is the exception; it names
  cmd.exe explicitly. The wrong shell fails loudly, which is the intended
  outcome: assume the reader knows `sudo`, `pwsh`, and `~/`, and can act on an
  error. Don't add shell detection or explain the difference in the README.

## README is a map, not a manual

The reader is the user on a fresh machine: they know the tools, they need the
route. Keep the commands, and the things they'd forget — where a Windows setting
lives, that a step needs a reboot, that bootstrap is safe to re-run. Cut the
rationale: why the script is linear, why scoop over winget, what a flag does.
That belongs in this file or in the script's own comments. A section that grows
past a short paragraph plus its commands has turned into documentation.

Trim rationale, not grammar. Full sentences, not note-taking fragments — clipped
text ("Linear: stops at first failure.") reads as fragile, not concise.

## When unsure

Ask. The user knows this machine and prefers simple, explicit wording over
hand-holding. Don't explain command-line basics in README or comments.
