/*
Copyright 2008 - 2012 Lukas Sägesser


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
*/

package
{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.*;
	import fl.events.*;
	import flash.net.*;

	import flash.utils.*;

	public class PlayFunctions extends GlobalStage
	{
		public var playUrlLoader:URLLoader = new URLLoader();
		public var playCommandCounter = 0;
		
		public function PlayFunctions()
		{
			playUrlLoader.addEventListener(flash.events.IOErrorEvent.IO_ERROR, MovieClip(ROOT).editFunctions.onUrlLoaderIoError);
			
			MovieClip(ROOT).output("INIT: PlayFunctions has run...", 0);
		}
		
		public function play_userClickAt(toX, toY, hudX, hudY)
		{
			if (MovieClip(ROOT).guiEvents.edit_mode == 0)
			{
				var date = new Date();
				MovieClip(ROOT).output("play_userClickAt "+date.getMinutes()+":"+date.getSeconds()+"."+date.getMilliseconds(), 0);
				
				var vars = "cmd=userClickAt&posX="+toX+"&posY="+toY+"&hudX="+hudX+"&hudY="+hudY;
				sendPlayInputNow(vars);
			}
		}
		
		public function play_sendViewportDimensions()
		{
			//MovieClip(ROOT).output("edit_takeObject: "+objId);
			
			var vars = "cmd=setViewportDimensions&width="+MovieClip(ROOT).viewport.width+"&height="+MovieClip(ROOT).viewport.height;
			sendPlayInputHttp(vars);
			
		}
				
		public function play_createLandmark(folderId)
		{
			//MovieClip(ROOT).output("edit_takeObject: "+objId);
			
			var vars = "cmd=createLandmark&folderId="+folderId;
			sendPlayInputHttp(vars);
			
		}
		
		public function play_teleportToLandmark(landmarkId)
		{
				var vars = "cmd=teleportToLandmark&landmarkId="+landmarkId;
				sendPlayInputHttp(vars);
		}
		
		public function play_teleportToMap(mapName)
		{
				var vars = "cmd=teleportToMap&mapName="+mapName;
				sendPlayInputHttp(vars);
		}
		
		public function play_buyObject(objId)
		{
			MovieClip(ROOT).output("play_buyObject: "+objId, 0);
			
			var vars = "cmd=buyObject&objId="+objId;
			sendPlayInputHttp(vars);
			
		}
		
		public function play_payToObject(objId, amount)
		{
			var vars = "cmd=payToObject&objId="+objId+"&amount="+amount;
			sendPlayInputHttp(vars);
			
		}
		
		public function play_payToUser(username, amount)
		{
			var vars = "cmd=payToUser&username="+username+"&amount="+amount;
			sendPlayInputHttp(vars);
			
		}
		
		public function play_avatarSay(msg)
		{
			if (msg.length > 1000)
			{
				msg = msg.substring(0, 1000);
			}
			
				var vars = "cmd=avatarSay&msg="+flash.utils.escapeMultiByte(msg);
				sendPlayInputHttp(vars);
		}
		
		public function play_keyPressed(key, currMouseX, currMouseY, hudX, hudY)
		{
				MovieClip(ROOT).output("play_keyPressed: "+key, 0);
				var vars = "cmd=keyPressed&key="+key+"&posX="+currMouseX+"&posY="+currMouseY+"&hudX="+hudX+"&hudY="+hudY;
				sendPlayInputNow(vars);
		}
		
		public function play_keyReleased(key, currMouseX, currMouseY, hudX, hudY)
		{
				MovieClip(ROOT).output("play_keyReleased: "+key, 0);
				var vars = "cmd=keyReleased&key="+key+"&posX="+currMouseX+"&posY="+currMouseY+"&hudX="+hudX+"&hudY="+hudY;
				sendPlayInputNow(vars);
		}
		
		public function play_muteObject(key)
		{
				var vars = "cmd=muteObject&key="+key;
				sendPlayInputHttp(vars);
		}
		
		public function play_muteUser(key)
		{
				var vars = "cmd=muteUser&key="+key;
				sendPlayInputHttp(vars);
		}
		
		public function sendPlayInputNow(vars)
		{
			if (MovieClip(ROOT).ajax.myXMLSocket.connected == true)
			{
				//MovieClip(ROOT).output("sendPlayInputNow: "+vars+"&cmdCounter="+playCommandCounter, 1);
				
				playCommandCounter++;
				
				var date = new Date();
				MovieClip(ROOT).ajax.sentCmds[playCommandCounter] = date.getTime();
				
				var meanLag = MovieClip(ROOT).ajax.calcMeanLag();
				
				var cmdData = "(y)BEGINPARAMS(y)"+vars+"&cmdCounter="+playCommandCounter+"&meanLag="+meanLag;
				//MovieClip(ROOT).output("sendPlayInputNow send cmd: "+cmdData+" socket:"+MovieClip(ROOT).ajax.myXMLSocket.connected, 0);
				cmdData = MovieClip(ROOT).ajax.encrypt(cmdData);
				
				var cmd = "CMD:"+cmdData+"(y)ENDPARAMS(y)";
				
				//MovieClip(ROOT).output("encrypted: "+cmd, 0);
				MovieClip(ROOT).ajax.myXMLSocket.writeUTFBytes(cmd);
				MovieClip(ROOT).ajax.myXMLSocket.flush();
				//MovieClip(ROOT).output("sendPlayInputNow: Yes sent!", 1);
				//MovieClip(ROOT).ajax.myXMLSocket.send("ZGBTRETrvftzGZVRttvvVUztfbbzgfbzfbZGBZgtfvZFCzftVBzTfv"+"\0");
			}
			else
			{
				MovieClip(ROOT).output("DISCONNECTED! Try reloading the client...", 1);
				MovieClip(ROOT).chat.displayChatBubble("DISCONNECTED! Try reloading the client...");
			}
		}
		
		public function sendPlayInputHttp(vars)
		{
			//MovieClip(ROOT).output("sendPlayInputHttp: "+vars+"&cmdCounter="+playCommandCounter, 1);
			
			
			playCommandCounter++;
			if (MovieClip(ROOT).host != null)
			{
				MovieClip(ROOT).editFunctions.editUrlLoader.load(new URLRequest("https://"+MovieClip(ROOT).host+"/app/server/play_input.jsp"+"?"+vars+"&cmdCounter="+playCommandCounter));
			}
			else
			{
				MovieClip(ROOT).editFunctions.editUrlLoader.load(new URLRequest("../server/play_input.jsp"+"?"+vars+"&cmdCounter="+playCommandCounter));
			}
		}

	}
}
