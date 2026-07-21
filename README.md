# Windows Setup

## Winget Apps

Install apps with winget, avoid opening Edge:

    winget install Google.Chrome
    winget install Valve.Steam

## Bootstrap

Open this page in Chrome and paste into cmd:

    curl -LO https://raw.githubusercontent.com/LexSong/windows-setup/main/bootstrap.cmd
    bootstrap.cmd

The script is linear on purpose: it stops at the first failure and is safe to
run again after fixing the problem. It installs Scoop and Git, checks out the
bare [dotfiles](https://github.com/LexSong/dotfiles) repo into the home
directory, then installs everything else: CLI tools, MSYS2 + fish (the daily
shell), fonts, uv and npm tools. Desktop apps are not covered by the script.
See the comments in [bootstrap.cmd](bootstrap.cmd) for details.

## Windows Terminal Settings

The bootstrap clones [windows-terminal-settings](https://github.com/LexSong/windows-terminal-settings)
into the home directory; linking needs admin, so run `link-settings.cmd` there
yourself.

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

- dotfiles: https://github.com/LexSong/dotfiles
- Windows Terminal settings: https://github.com/LexSong/windows-terminal-settings
- Neovim config: https://github.com/LexSong/nvim
