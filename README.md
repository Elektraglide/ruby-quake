# ruby-quake
Reads quake1 and halflife1 files into SketchUp using awesome bit-struct [https://github.com/vjoel/bit-struct]; I've embedded it here for convenience.

At SketchUp console:

__load "{SOMEPATH}/quake.rb"__

to install a SketchUp Importer. From the Import menu you can choose a Quake 1 or Halflife1 map files to start an import of map and all entities.  
Entities have JSON attached as SketchUp attribute with all parameters.
Various animation and lighting parameters are LightUp ready - just start lighting.

