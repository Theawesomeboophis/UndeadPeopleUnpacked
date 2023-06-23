@echo off
:: Create default config file if none found
if not exist !compose_main.ini (
	echo sources_path=!dda\> !compose_main.ini
	echo output_path=!dda\generated_packed\>> !compose_main.ini
	echo game_path=>> !compose_main.ini
)

:: .ini reading: https://stackoverflow.com/a/4518146
@call:ini "!compose_main.ini" sources_path SRC
@call:ini "!compose_main.ini" output_path OUT
@call:ini "!compose_main.ini" game_path GME

:: Compose
@echo Starting Composition from %SRC% to %OUT%... & @echo:
python compose.py %SRC%\ %OUT%\

:: Copy permanent files and lint tile_config.json
@echo: & @echo Copying permanent tileset files to %OUT%... & @echo:
copy "%SRC%"\ "%OUT%"\
.\json_formatter.exe %OUT%\tile_config.json

:: Update tileset in game files if specified
if not ["%GME%"] == [""] (
	@echo: & @echo Copying tileset to local game files at "%GME%"... & @echo:
	copy "%OUT%"\ "%GME%"\
)

pause
@goto:eof

:ini    
@for /f "tokens=2 delims==" %%a in ('find "%~2=" "%~1"') do @set %~3=%%a