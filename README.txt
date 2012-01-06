
Bit Whirl Viewer
----------------

This is the client application used to connect to virtual worlds/games on the Bit Whirl (www.bitwhirl.com) platform.
It is an application made with Adobe Flash CS3 and therefore allows anyone with a browser to access Bit Whirl.

Bit Whirl is a full featured platform for multiplayer games. A browser game engine, a flash game framework. The basics, movement, interaction with objects, network communication, are all there so you can concentrate on the creative and fun part. To learn more about what can be done with Bit Whirl, check out the Possibilities.

http://www.bitwhirl.com/features
http://www.bitwhirl.com/content/multiplayer-game-engine

The Bit Whirl platform is a product of ScyDev GmbH, a web development company based in Switzerland.



Random
------
* Infilion was the internal project name before we renamed it to Bit Whirl.

* Input messages to the server are handled in: Ajax.as, EditFunctions.as, PlayFunctions.as

* Output messages from server are handled in: Ajax.as, JavaCallableFunctions.as



Dependencies
------------
* Adobe Flash CS3 Professional

* The ASTRA Flash Components (v1.2.0) for GUI elements.
  Found in the lib directory.
  http://developer.yahoo.com/flash/astra-flash/
  
* The files in the server directory are needed for testing and to prevent errors when compiling the flash app in Adobe Flash CS3.



Testing
-------
1.) Make sure when you compile the Flash app, the SWF goes to client/test/bitwhirl_client.swf
2.) Use the file client/test/bitwhirl_viewer.html to connect to the server with your local SWF file
3.) If network connection doesn't work, you need to change your Flash settings and add security exceptions for the file bitwhirl_client.swf and www.bitwhirl.com.
    (Global settings -> Advanced -> Developer tools) 
    Works in Windows, Linux was being stubborn.



License
-------
This file is part of Bit Whirl Viewer.

Bit Whirl Viewer is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Bit Whirl Viewer is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Bit Whirl Viewer.  If not, see <http://www.gnu.org/licenses/>.



