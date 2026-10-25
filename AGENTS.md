# Notes for coding agents

This repo is the version-controlled layer of one personal Windows 11 Home
machine. Optimize for this machine, not for portability.

## Rules

- **Never commit or push without my approval.** Show the diff, then wait. I
  often have my own edits in the working tree, so avoid `git commit -a`.
- **`bootstrap.cmd` and `dotfiles/link.cmd` must stay CRLF.** They run under
  cmd.exe on a bare machine. `.gitattributes` pins `*.cmd -text`, but an editor
  can still write LF, so check the line endings after an edit.
- **`bootstrap.cmd` stays linear.** It runs non-admin, top to bottom, in one
  pass, and stops at the first failure. Don't add retries or error recovery.
  Its comments mark the steps whose order matters; keep that order.
- **Put `call` before every `.cmd` shim** (`scoop`, `npm`). Without it, batch
  jumps into the shim and never returns.
- **Run repo `.ps1` files with `pwsh`, not `powershell`.** pwsh defaults to
  `RemoteSigned`, but Windows PowerShell 5.1 on a fresh machine does not.

## Where things go

- **`dotfiles/`**: only files that `link.cmd` symlinks into home. A file that
  stops being linked moves out. `dotfiles/windows-terminal-settings/` is a
  separate repo (gitignored) that bootstrap clones there.
- **`scripts/`**: payloads run from the clone, by hand or by a fish function.
  Fish reaches a script by its path, so moving a script means editing the fish
  repo too.
- **root**: `bootstrap.cmd`, the only file fetched before the clone exists, plus
  repo metadata.
- **Other repos**: fish, Neovim, Windows Terminal and `~/.claude` each have
  their own repo, and so do my uv tools `my-python-cookiecutter` and
  `yt-sub-txt`. Make their changes there.

## Installs

Scoop, uv and npm install apps portable, which I prefer, so bootstrap covers
what they can manage. Some apps need a stateful install (Chrome, so it can be
the default browser; Steam), or admin plus a reboot (WSL, Docker Sandboxes).
Those go through winget by hand and stay out of bootstrap.

MSYS2 uses the Windows `HOME`, so `setx HOME` is the only glue between Windows
and fish. Don't add path fixups.

## README

README is a map for me on a fresh machine. Keep the commands and what I would
forget: where a Windows setting lives, which step needs a reboot, that
bootstrap is safe to re-run. Rationale goes in this file or in script comments.
Write full sentences, not clipped notes.

Commands are written for fish, so paths use `~/`. Don't add shell detection,
and don't explain other shells.
