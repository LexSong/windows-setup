# Windows Setup

## Winget Apps

Install apps with winget, avoid opening Edge:

    winget install Google.Chrome
    winget install Valve.Steam

## Bootstrap

Enable Developer Mode (Settings > System > For developers) so symlinks work
without admin. Then open this page in Chrome and paste into cmd:

    curl -LO https://raw.githubusercontent.com/LexSong/windows-setup/main/bootstrap.cmd
    bootstrap.cmd

The script is linear on purpose: it stops at the first failure and is safe to
run again after fixing the problem. In order, it: sets `HOME` so MSYS2 uses the
Windows home; installs Scoop and its packages; sets up MSYS2 + fish (the daily
shell); installs the uv and npm global tools; symlinks the loose dotfiles from
[dotfiles/](dotfiles) into home; and clones the config repos —
[windows-terminal-settings](https://github.com/LexSong/windows-terminal-settings)
and the [Neovim config](https://github.com/LexSong/nvim). Desktop apps are not
covered — see below. Read [bootstrap.cmd](bootstrap.cmd) for the details.

## WSL and Docker Sandboxes

Docker Sandboxes expects an installed WSL. Run in an admin prompt and reboot:

    wsl --install

Then:

    winget install Docker.sbx

## Remap Capslock to Ctrl Key

Skip this if the keyboard already remaps in hardware.

1.  Download the [CapslockToCtrl.reg](https://raw.githubusercontent.com/LexSong/windows-setup/main/CapslockToCtrl.reg) registry file and double-click it.
2.  Click Yes on both the UAC security prompt and the registry confirmation.
3.  Restart the computer for the key remapping to take effect.

## Related Repos

- Windows Terminal settings: https://github.com/LexSong/windows-terminal-settings
- Neovim config: https://github.com/LexSong/nvim
