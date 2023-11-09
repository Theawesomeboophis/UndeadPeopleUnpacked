# Working with Scripts
## General Workflow
Before we start, let's go through things that are mentioned in base game [TILESET.md](https://github.com/cataclysmbnteam/Cataclysm-BN/blob/upload/doc/TILESET.md) (which also contains explanations for how tilesets are formatted and is recommended to read for new contributors):

> tilesets that are submitted as fully composited tilesheets are called legacy tilesets, and tilesets that submitted as individual sprite image files are compositing tilesets.

I'm finding this choice of terminology confusing since "legacy" here is only tied to submission method but not to the actual tilesets themselves. Better names incoming:

* Composed: tilesets as we see them within compiled game and/or mods
* Decomposed: tilesets in form of many separate files and folders


This goes in line with scripts that do the work: `compose.py` and `decompose.py` and is intuitive that way: to "combine" many separate tiles into one-sheet-tileset, we'd choose `compose.py`, and to "slice" one-sheet-tileset to many images - `decompose.py`. See the sections on [Manual Composing](#Manual-Composing) and [Decomposing](#Decomposing) for details.

Mind that the *UndeadPeopleUnpacked* repository **already contains decomposed and organized files** within the `!dda`, `!default_mods`, etc. directories, which means that running the decompose script isn't usually necessary. These are the files you'll want to edit and create pull requests for when making changes to the tileset itself. 

It's not recommended to manually edit the *composed tilesheets* directly, unless you want to test changes to a few specific tiles without having to wait for the entire composing process to finish. In this case, don't forget to **add your changes to the actual decomposed tiles** afterwards, or they may get lost the next time you compose.

If you're on Windows, you can also compose the main `!dda` tileset using the `!COMPOSE_MAIN.bat` script which automates all manual steps with one simple click, including updating the tileset within your game files. See [Automatic Composing](#Automatic-Composing) for details.

You may also want to set the in-game keybinding `Reload tileset` to quickly apply the changes you've made.


## Installation
To run the scripts you need **Python**, the image processing library **libvips** and its Python wrapper **pyvips**.
For details see [simple video guide for Windows users](https://www.youtube.com/watch?v=O5iBsdAd1_w) and [text instructions for everyone](https://pypi.org/project/pyvips/).

### Some important notes:
- Pyvips **does not support Python versions 3.8 and above** without specific configuration of the scripts. Use Python 3.7 instead for now.
- There may also be issues with Anaconda virtual environments. Try using Python directly if you are getting errors.
- Don't forget to add the path to your `vips-dev-<version>\bin\` directory to the enviroment variable `PATH` (or a new variable `LIBVIPS_PATH`).

## Automatic Composing
(The following applies only to Windows and the main vanilla tileset in `!dda` at this time.)

If it doesn't exist yet, `!COMPOSE_MAIN.bat` creates the config file `!compose_main.ini` and sets default values for the source and output directories:
```
sources_path=!dda\
output_path=!dda\generated_packed\
```
After composing the permanent tileset files (`fallback.png`, `tileset.txt`, ...) are copied to `generated_packed\` and `tile_config.json` gets linted using `json_formatter.exe` so that the folder now contains a complete and usuable build of the tileset.

Optionally, you can also add the tileset's location within your game files to `game_path` in `!compose_main.ini`. If the value is non-empty, the script automatically updates it as well to make testing changes in-game quicker. For example, in my case it looks like this:
```
sources_path=!dda\
output_path=!dda\generated_packed\
game_path=D:\Games\Cataclysm Dark Days Ahead\dda\userdata\gfx\MSX++UnDeadPeopleEdition
```
If you're using the [Catapult Launcher](https://github.com/qrrk/Catapult) it's recommended to use the `userdata\gfx\` directory like in this example instead of the one in the actual game files. This makes sure that your *UndeadPeople* tileset doesn't get removed when updating to another experimental game version.

Both the `generated_packed\` folder and `!compose_main.ini` file are part of `.gitignore` so that your local generated files and game path don't accidentally get pushed upstream.

## Manual Composing

1. Simply running `compose.py` and pointing the folder where Decomposed files and `tile_info.json` are located is enough and will produce Composed tileset as well as newly updated `tile_config.json`
2. Resulting `tile_config.json` is actually not ready to be used by game:
* First, it needs linting, which can be done at https://dev.narc.ro/cataclysm/format.html or with the included `json_formatter.exe` (see [JSON_STYLE.md](https://github.com/cataclysmbnteam/Cataclysm-BN/blob/upload/doc/JSON_STYLE.md))
* Square brackets at the beginning and the end of the file should be restored
* If there is no actual `fallback.png` present, it's section should be removed
* Replace **"tile_info"** section with 

  ```"type": "mod_tileset",
  "compatibility": [
    "Chibi_Ultica",
    "UltimateCataclysm",
    "MshockXottoplus",
    "UNDEAD_PEOPLE",
    "UNDEAD_PEOPLE_BASE",
    "UNDEAD_PEOPLE_LEGACY",
    "UlticaShell",
    "MshockXottoplus12",
    "MSX++DEAD_PEOPLE",
    "MXplus12_for_cosmetics",
    "MSXotto+"
  ],```
  
  or something else that will make compatibility sense
  
* Lint again, just in case

3. Remove original mod tileset files and replace them with newly composed. Renaming `tile_config.json` into `mod_tileset.json` is not strictly necessary for game to run. 
Now go test it, spawn some zombear or something else from Aftershock mod to see if things are showing up correctly. They should. 
If the game fails at loading, it will say what's wrong with config file - in this case this should be easily fixable.

Composing is done.

## Decomposing

Preparing existing Composed tileset for decomposition:
* As example, let's take `Aftershock` mod which is distributed with the game
* To keep original files intact, we'll need to copy tileset files somewhere else
* In this case: 

`Aftershock_normal.png`
`Aftershock_large.png`
`mod_tileset.json`

* Now we can try to call decomposition script from source game files, located in [\Cataclysm-BN\tools\gfx_tools](https://github.com/cataclysmbnteam/Cataclysm-BN/tree/upload/tools/gfx_tools)
* Mandatory argument: path to tileset directory. This should be path to our copied files. Example (Windows PowerShell/cmd):

> D:\gfx_tools\decompose.py "D:\aftershock_copied_tileset"

* If everything done correctly, script process will terminate telling that there is no `tile_config.json`
* Rename `mod_tileset.json` to `tile_config.json`
* Now running script again will result in termination, but the different kind: 
> 'list' object has no attribute 'get'
* Open previously renamed `tile_config.json` and do necessary changes:
1. Remove opening and closing square brackets from very beginning and the end of the file
2. Replace everything before **"tiles-new"** with following:
  
  ```"tile_info": [ { "width": 32, "height": 32 } ],```
	
3. Change width and height to the size of each individual tile in tileset, in pixels. UndeadPeople is 32x32, so this can be skipped
* Run script again. It will now run without any messages at all, but you'll notice that there are new folders where files were copied: 

`pngs_Aftershock_normal_32x32`
`pngs_Aftershock_large_64x80`
and new file `tile_info.json` which is crucial for composing process.

`tile_config.json` contents has changed and now mentioning `fallback.png`, which section you should remove in case you'll want another decomposition process.

Decomposing is done, you can now go and alter each individual Decomposed tile and it's corresponding .json file as you wish.

# TODO: COMBINING TILESETS OF SEVERAL MODS

This is mostly the same process as mentioned above, but will require some manual tweaking of .json files for script to actually process them as part of one mod on composing stage.
