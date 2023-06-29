# Windows Environments Setup

## Essential Apps

### [Scoop](https://scoop.sh/)

Install Scoop with PowerShell:

    irm get.scoop.sh | iex
    scoop install 7zip aria2 git sudo
    scoop bucket add extras

### Neovim

Install Neovim:

    scoop install neovim

Also install Visual C++ Redistributable:

    scoop install vcredist2015
    scoop uninstall vcredist2015

### Python

Download and install [Miniforge3](https://github.com/conda-forge/miniforge#miniforge3). No need to add PATH.

Initialize Conda, restart command prompt:

    miniforge3\Scripts\conda.exe init

Update conda and brotlipy together due to [this issue](https://github.com/conda/conda/issues/9903) identified on 2023-06-08:

    conda update -n base conda brotlipy
    conda update -n base --all

Add `miniforge3\condabin\venv.bat`:

    echo conda.bat activate .\.venv > miniforge3\condabin\venv.bat

Updated Conda solver to libmamba

    conda install -n base conda-libmamba-solver
    conda config --set solver libmamba

Create a virtual environment for Neovim pynvim:

    conda create -n pynvim pynvim

### Install Python Apps with pipx

Create a virtual environment for pipx:

    conda create -n pipx pipx
    pipx ensurepath

May need reboot to set PATH properly.

    pipx install black
    pipx install conda-lock
    pipx install flake8
    pipx install poetry
    pipx install reorder-python-imports
    pipx install yamllint

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
