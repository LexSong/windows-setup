# Windows Setup

## Winget Apps

Install apps with winget, avoid opening Edge:

    winget install Google.Chrome
    winget install Valve.Steam

## Bootstrap

Enable Developer Mode (Settings > System > For developers) so symlinks work without admin. Then copy and run these commands in cmd.exe:

    curl -LO https://raw.githubusercontent.com/LexSong/windows-setup/main/bootstrap.cmd
    bootstrap.cmd

The script is linear — it stops at the first failure and is safe to run again. In order, it:

- Sets `HOME`, so MSYS2 uses the Windows home instead of its own.
- Installs Scoop and its packages.
- Sets up MSYS2 and installs fish, the daily shell.
- Installs the uv and npm global tools.
- Clones this repo to `%USERPROFILE%\windows-setup`, with the [Windows Terminal settings](https://github.com/LexSong/windows-terminal-settings) nested in [dotfiles/](dotfiles), then symlinks the files there into home.
- Clones the [fish](https://github.com/LexSong/fish) and [Neovim](https://github.com/LexSong/nvim) config repos into place.

Bootstrap only installs what scoop, uv, and npm can manage portably; Chrome, Steam, and WSL are separate steps. Read [bootstrap.cmd](bootstrap.cmd) for the details.

## WSL and Docker Sandboxes

Docker Sandboxes expects an installed WSL. Run in an admin prompt and reboot:

    wsl --install

Then:

    winget install Docker.sbx

## Remap Capslock to Ctrl Key

For a keyboard that doesn't already do this in hardware. Needs admin:

    sudo pwsh ~/windows-setup/scripts/capslock-to-ctrl.ps1

Restart the computer for the remapping to take effect.

## Related Repos

- Windows Terminal settings: https://github.com/LexSong/windows-terminal-settings
- fish config: https://github.com/LexSong/fish
- Neovim config: https://github.com/LexSong/nvim
