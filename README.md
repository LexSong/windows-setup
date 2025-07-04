# Windows Environments Setup

## Essential Apps

### [Scoop](https://scoop.sh/)

Install Scoop with PowerShell:

    irm get.scoop.sh | iex
    scoop install 7zip aria2 git pwsh
    scoop bucket add extras

### Neovim

Install Neovim:

    scoop install neovim

Also install Visual C++ Redistributable:

    scoop install vcredist2022
    scoop uninstall vcredist2022

### Python

Use `pixi` and `uv` to install conda and python environments instead.

    scoop install pixi
    scoop install uv

Use `uv tool` to install Python apps instead if they're not available in Scoop.

    scoop install ruff
    uv tool install reorder-python-imports

## Personal Configs

### dotfiles

https://github.com/LexSong/dotfiles

### Neovim Configs

https://github.com/LexSong/nvim

## System Tweaks

### Remap Capslock to Ctrl Key

    curl -O https://raw.githubusercontent.com/LexSong/windows-setup/master/CapslockToCtrl.reg
    sudo reg import CapslockToCtrl.reg

Reboot for the above changes to take effect.

### Enable Virtual Terminal

    reg add HKEY_CURRENT_USER\Console /v VirtualTerminalLevel /t REG_DWORD /d 0x00000001 /f

See https://superuser.com/a/1300251 for more details.
