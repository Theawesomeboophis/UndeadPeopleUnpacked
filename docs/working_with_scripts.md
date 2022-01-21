### Tileset Composition and Decomposition

Before we start, let's go through things that are mentioned in base game [TILESET.md](https://github.com/cataclysmbnteam/Cataclysm-BN/blob/upload/doc/TILESET.md):

> tilesets that are submitted as fully composited tilesheets are called legacy tilesets, and tilesets that submitted as individual sprite image files are compositing tilesets.

I'm finding this choose of terminology confusing since "legacy" here is only tied to submission method but not to the actual tileset themselves. Better names incoming:

* Composed: tilesets as we see them within compiled game and/or mods
* Decomposed: tilesets in form of many separate files and folders

This goes in line with scripts that do the work: `compose.py` and `decompose.py` and is intuitive that way: to "combine" many separate tiles into one-sheet-tileset, we'd choose `compose.py`, and to "slice" one-sheet-tileset to many images - `decompose.py`

Since most likely the one who's willing to work with tiles will end up having only Composed ones on hands, from mods or downloaded game, we'll start on process of decomposition.

# DECOMPOSING

1. Installing pyvips: [simple video guide for Windows users](https://www.youtube.com/watch?v=O5iBsdAd1_w) and [text instructions for everyone](https://pypi.org/project/pyvips/)
2. Preparing existing Composed tileset for decomposition:
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
4. Run script again. It will now run without any messages at all, but you'll notice that there are new folders where files were copied: 

`pngs_Aftershock_normal_32x32`
`pngs_Aftershock_large_64x80`
and new file `tile_info.json` which is crucial for composing process.

`tile_config.json` contents has changed and now mentioning `fallback.png`, which section you should remove in case you'll want another decomposition process.

Decomposing is done, you can now go and alter each individual Decomposed tile and it's corresponding .json file as you wish.

# COMPOSING

1. Simply running `compose.py` and pointing the folder where Decomposed files and `tile_info.json` are located is enough and will produce Composed tileset as well as newly updated `tile_config.json`
2. Resulting `tile_config.json` is actually not ready to be used by game:
* First, it needs linting, which can be done at https://dev.narc.ro/cataclysm/format.html (see [JSON_STYLE.md](https://github.com/cataclysmbnteam/Cataclysm-BN/blob/upload/doc/JSON_STYLE.md))
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

# TODO: COMBINING TILESETS OF SEVERAL MODS

This is mostly the same process as mentioned above, but will require some manual tweaking of .json files for script to actually process them as part of one mod on composing stage.
