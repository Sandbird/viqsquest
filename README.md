viqsquest
=========

This is a 2D platformer game written in Objective-C.
Contains a similar resemblance to Super Mario Brothers.

Project Folder Explanation
==========================
--> Core-Data: Contains all the files necessary for using the Core Data framework's datastore

--> Data-Files: Contains all the files used for animations for each type of entity

--> Game-Screen: Contains all classes used for the actual level itself

--> GameObjectLiterals/Boxables: Classes for powerups + slope

--> GameObjectLiterals/Collectables: Classes for coins + UC + arrows

--> GameObjectLiterals/Enemies: Classes fo r each enemy type

--> GameObjectLiterals/Firing: Arrow class

--> GameObjectLiterals/Hazards: Lethal + Nonlethal hazard

--> GameObjectLiterals/Player: Player Class

--> GameObjectLiterals/Terrain: Checkpoint + Platform

--> GameObjectSuperclass: Superclasses for each type which allows for easy method sharing and inheritance

--> JSTileMap (External Library)

--> JSTileMapCategory: Class that extends the functionality of the tile map itself

--> ParallaxNode ( External Library )

--> SKEmitters: Files used for particle emitters such as fire!

--> SKTUtils (External Library)

--> Singletons: Classes for game management + texture atlas management

--> SoundEffects: All the sound effects files

--> Textures:Images :: Folder that contains all the images/main music artifacts

--> TileMaps: Contains all the .tmx files

--> UI Controllers: Classes for each different controller and scene

OldeEnglish.tff: Custom font

PSKAppDelegate (.h/.m) main delegate class that gets called when application first loads and critical events

External Libraries Used
=======================

--> JSTileMap
This library was used mainly for a necessary integration with Tiled Maps and maps generated with Tiled. (TMX Format)
https://github.com/slycrel/JSTileMap

--> SKTUtils
A library written by RayWenderlich and that is also on GitHub used for simplifying several things, such as math relating to CGPoints
https://github.com/raywenderlich/SKTUtils

--> ParallaxNode
A class that helps simplify the process of adding a parallax background to a 2D platformer Sprite-Kit Game. A parallax background is where the different layers of the background appear to move at different speeds.
