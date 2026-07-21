:: bootstrap.cmd -- set up a fresh Windows machine from zero.
::
:: On a fresh machine, open a regular (non-admin) cmd prompt and run:
::
::     curl -LO https://raw.githubusercontent.com/LexSong/windows-setup/main/bootstrap.cmd
::     bootstrap.cmd
::
:: Linear on purpose: every step carries "|| exit /b" so the script stops
:: at the first failure (batch keeps going on errors by default). Echo is
:: left ON so the failing line is visible. The few lines WITHOUT the guard
:: are allowed to fail so a crashed run can simply be re-run.

setlocal

:: Set HOME permanently (setx writes the user environment in the registry).
:: MSYS2 honors an existing HOME env var instead of /home/<user>, so fish
:: reads ~/.config/fish from the real Windows home. This is the only glue.
setx HOME "%USERPROFILE%" || exit /b

:: --- Scoop (PowerShell only as a subprocess, just for the installer) ---
if not exist "%USERPROFILE%\scoop" powershell -NoProfile -ExecutionPolicy Bypass -Command "irm get.scoop.sh | iex" || exit /b
set "PATH=%USERPROFILE%\scoop\shims;%PATH%"

:: --- Scoop packages (snapshot of the working machine, 2026-07-22) ---

:: Git first -- scoop needs it to add the extras bucket below.
:: 7zip and aria2 are the helpers scoop uses for archives and downloads
call scoop install git 7zip aria2 || exit /b

:: extras bucket holds vcredist and the GUI apps
:: (re-adding an existing bucket fails harmlessly)
call scoop bucket add extras

:: Shells and editor
call scoop install msys2 neovim pwsh || exit /b

:: Neovim needs the VC++ runtime: install it system-wide, then drop the package.
call scoop install vcredist2022 || exit /b
call scoop uninstall vcredist2022 || exit /b

:: Essential command-line tools
call scoop install bat diffutils dust fd fzf just ripgrep scoop-search topgrade || exit /b

:: Programming languages and dev tooling
call scoop install gcc jq nodejs pixi ruff rust sqlite stylua taplo tree-sitter uv || exit /b

:: Multimedia
call scoop install avidemux ffmpeg IrfanView vlc || exit /b

:: Downloads, cloud sync, and backup
call scoop install megacmd qbittorrent rclone restic || exit /b

:: Misc:
::   adb, scrcpy - Android
::   CrystalDiskMark - benchmark
::   czkawka, krokiet - duplicate finder (krokiet is the GUI)
::   innounp - Inno Setup unpacker
::   llama-swap - local LLM proxy
::   mitmproxy - HTTP debugging proxy
::   pandoc - document converter
::   rapidee - environment variable editor
::   spacesniffer - disk usage
::   typora - markdown editor
::   winmerge - diff and merge
call scoop install adb scrcpy CrystalDiskMark czkawka krokiet innounp llama-swap mitmproxy pandoc rapidee spacesniffer typora winmerge || exit /b

:: --- Fonts: "CaskaydiaMono Nerd Font", used by the Windows Terminal profile ---
call scoop bucket add nerd-fonts
call scoop install CascadiaMono-NF || exit /b

:: Minecraft: Prism Launcher (personal build) + Java 8 for old versions
call scoop bucket add java
call scoop bucket add my-scoop-bucket https://github.com/LexSong/my-scoop-bucket
call scoop install temurin8-jre prismlauncher-np || exit /b

:: --- MSYS2 + fish (the daily shell) ---
set "MSYS2=%USERPROFILE%\scoop\apps\msys2\current"
"%MSYS2%\usr\bin\bash.exe" -lc true || exit /b
:: -Syu runs twice on purpose: the first pass may upgrade only the core
:: (msys2-runtime, pacman) and stop there; the second pass updates the rest.
"%MSYS2%\usr\bin\pacman.exe" -Syu --noconfirm || exit /b
"%MSYS2%\usr\bin\pacman.exe" -Syu --noconfirm || exit /b
"%MSYS2%\usr\bin\pacman.exe" -S --needed --noconfirm fish || exit /b

:: --- Python CLI tools (no global python -- everything through uv) ---
:: Scoop wrote the UV_* vars into the user environment (registry): new
:: shells get them, but this session must set them itself so uv places
:: tools in the persist dir.
set "UV_CACHE_DIR=%USERPROFILE%\scoop\persist\uv\cache"
set "UV_PYTHON_BIN_DIR=%USERPROFILE%\scoop\persist\uv\python\shims"
set "UV_PYTHON_INSTALL_DIR=%USERPROFILE%\scoop\persist\uv\python\versions"
set "UV_TOOL_BIN_DIR=%USERPROFILE%\scoop\persist\uv\tools\shims"
set "UV_TOOL_DIR=%USERPROFILE%\scoop\persist\uv\tools\versions"
:: also put the tool shims on PATH, or every install below prints a warning
set "PATH=%UV_TOOL_BIN_DIR%;%PATH%"
uv tool install gallery-dl || exit /b
uv tool install git-filter-repo || exit /b
uv tool install huggingface-hub || exit /b
uv tool install reorder-python-imports || exit /b
uv tool install yt-dlp || exit /b

:: --- npm global tools ---
:: nodejs has no scoop shims; it lives on PATH via the user environment
:: (registry), which this session doesn't see -- add it manually.
set "PATH=%USERPROFILE%\scoop\apps\nodejs\current\bin;%USERPROFILE%\scoop\apps\nodejs\current;%PATH%"
:: npm itself first: the global copy lives in the persist dir, so it
:: survives nodejs updates (the bundled one is replaced each update)
call npm install -g npm || exit /b
call npm install -g cspell prettier pyright || exit /b

:: --- Dotfiles: bare repo in %USERPROFILE%\.dotfiles, work tree = home ---
git init --bare "%USERPROFILE%\.dotfiles" || exit /b
git --git-dir="%USERPROFILE%\.dotfiles" remote add origin https://github.com/LexSong/dotfiles
git --git-dir="%USERPROFILE%\.dotfiles" fetch origin || exit /b
git --git-dir="%USERPROFILE%\.dotfiles" --work-tree="%USERPROFILE%" checkout main || exit /b

:: --- Windows Terminal settings ---
:: Linking needs admin: run link-settings.cmd there manually afterwards.
if not exist "%USERPROFILE%\windows-terminal-settings" (git clone https://github.com/LexSong/windows-terminal-settings "%USERPROFILE%\windows-terminal-settings" || exit /b)

:: --- Neovim config ---
if not exist "%LOCALAPPDATA%\nvim" (git clone https://github.com/LexSong/nvim "%LOCALAPPDATA%\nvim" || exit /b)

echo Done. Open the "MSYS2 Fish" profile in Windows Terminal.
echo See README.md for the remaining steps (WSL, Docker Sandboxes).
