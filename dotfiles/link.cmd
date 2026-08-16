:: link.cmd -- symlink these dotfiles into the home directory.
::
:: :link <repo file> <target relative to %USERPROFILE%> replaces the target
:: with a symlink back to the copy in this repo, so in-place edits show up
:: as git diffs here.
::
:: File symlinks need Developer Mode (or an admin prompt) -- see README.md.

setlocal
set "SRC=%~dp0"
cd /d "%USERPROFILE%"

call :link .gitconfig .gitconfig || exit /b
call :link yt-dlp.config AppData\Roaming\yt-dlp\config || exit /b
:: from the windows-terminal-settings repo, cloned next to the dotfiles
call :link windows-terminal-settings\settings.json AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json || exit /b
goto :eof

:link
if not exist "%~dp2" mkdir "%~dp2"
if exist "%~2" del "%~2"
mklink "%~2" "%SRC%%~1" || exit /b
goto :eof
