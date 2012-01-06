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
	
	
	public class EditFunctions extends GlobalStage
	{
		public var editUrlLoader:URLLoader = new URLLoader();
		
		public function EditFunctions()
		{
			editUrlLoader.addEventListener(flash.events.IOErrorEvent.IO_ERROR, onUrlLoaderIoError);
			
			MovieClip(ROOT).output("INIT: EditFunctions has run...", 0);
		}

		public function getEditMode()
		{
			return MovieClip(ROOT).guiEvents.edit_mode;
		}
		
		
		public function edit_createNewObject()
		{
			
			//MovieClip(ROOT).output("NEW OBJ");
			
			var vars = "cmd=newObj&posX=10&posY=10";
			sendEditorInputNow(vars);
		}
		
		public function edit_rezObject(objId, newPosX, newPosY, disableScripts, forceNoCopy)
		{
			//MovieClip(ROOT).output("REZ OBJ");
			
			var vars = "cmd=rezObj&objId="+objId+"&posX="+newPosX+"&posY="+newPosY+"&disableScripts="+disableScripts+"&forceNoCopy="+forceNoCopy+"&targetDatabase="+GuiFuncs.deleteFocusPlace;
			sendEditorInputNow(vars);
		}
		
		public function edit_copyObject(objId)
		{
			//MovieClip(ROOT).output("COPY OBJ");
			
			var vars = "cmd=copyObj&objId="+objId;
			sendEditorInputNow(vars);
		}
		
		public function edit_delObject(objId)
		{
			//MovieClip(ROOT).output("DEL OBJ: "+objId);
			
			var vars = "cmd=delObj&objId="+objId+"&targetDatabase="+GuiFuncs.deleteFocusPlace;
			sendEditorInputNow(vars);
		}
		
		public function edit_relocateObject(objId, newPosX, newPosY)
		{
			//MovieClip(ROOT).output("relocate: "+objId);
			
			var vars = "cmd=relocateObj&objId="+objId+"&posX="+newPosX+"&posY="+newPosY;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_changeObjectZ(objId, before, targetObjId)
		{
			//MovieClip(ROOT).output("change Z: "+objId);
			
			var vars = "cmd=changeObjZ&objId="+objId+"&targetObjId="+targetObjId+"&before="+before;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_resizeObject(objId, newSizeX, newSizeY)
		{
			//MovieClip(ROOT).output("resize: "+objId);
			
			var vars = "cmd=resizeObj&objId="+objId+"&sizeX="+newSizeX+"&sizeY="+newSizeY;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_assignImage(objId, imgId)
		{
			//MovieClip(ROOT).output("assignImage: "+objId);
			
			var vars = "cmd=assignImage&objId="+objId+"&imgId="+imgId;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_assignScript(objId, scriptId)
		{
			//MovieClip(ROOT).output("assignImage: "+objId);
			
			var vars = "cmd=assignScript&objId="+objId+"&scriptId="+scriptId;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_assignText(objId, textId)
		{
			//MovieClip(ROOT).output("assignImage: "+objId);
			
			var vars = "cmd=assignText&objId="+objId+"&textId="+textId;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_takeObject(objId)
		{
			//MovieClip(ROOT).output("edit_takeObject: "+objId);
			
			var vars = "cmd=takeObject&objId="+objId;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_setAsAvatar(objId)
		{
			//MovieClip(ROOT).output("edit_takeObject: "+objId);
			
			var vars = "cmd=setAsAvatar&objId="+objId;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_wearOnHud(objId)
		{
			//MovieClip(ROOT).output("edit_takeObject: "+objId);
			
			var vars = "cmd=wearOnHud&objId="+objId;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_removeFromHud(objId)
		{
			//MovieClip(ROOT).output("edit_takeObject: "+objId);
			
			var vars = "cmd=removeFromHud&objId="+objId;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_toggleInventoryFolder(folderId)
		{
			//MovieClip(ROOT).output("edit_takeObject: "+objId);
			
			var vars = "cmd=toggleInventoryFolder&folderId="+folderId;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_newInvFolder(folderId)
		{
			//MovieClip(ROOT).output("edit_takeObject: "+objId);
			
			var vars = "cmd=newInvFolder&folderId="+folderId;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_renameInventory(itemId, newName)
		{
			//MovieClip(ROOT).output("edit_takeObject: "+objId);
			
			var vars = "cmd=renameInventory&itemId="+itemId+"&newName="+newName+"&targetDatabase="+GuiFuncs.deleteFocusPlace;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_moveInventoryToFolder(itemId, targetItemId, copy)
		{
			//MovieClip(ROOT).output("edit_takeObject: "+objId);
			
			var vars = "cmd=moveInventoryToFolder&itemId="+itemId+"&targetItemId="+targetItemId+"&copy="+copy;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_moveInventoryToObjContents(itemId, targetObjId)
		{
			MovieClip(ROOT).output("moveInventoryToObjContents: "+itemId, 0);
			
			var vars = "cmd=moveInventoryToObjContents&itemId="+itemId+"&targetObjId="+targetObjId;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_giveInventoryToUser(itemId, targetUser)
		{
			MovieClip(ROOT).output("edit_giveInventoryToUser: "+itemId, 0);
			
			var vars = "cmd=giveInventoryToUser&itemId="+itemId+"&targetUser="+targetUser;
			sendEditorInputNow(vars);
			
		}
		
		
		public function edit_applyObjectProps(objId, obj_name, obj_x, obj_y, obj_z, obj_rotZ, obj_sell, obj_price, obj_solid, obj_clickThrough, obj_sizeX, obj_sizeY)
		{
			//MovieClip(ROOT).output("edit_applyObjectProps: "+objId);
			
			var vars = "cmd=applyObjectProps&objId="+objId+"&obj_name="+obj_name+"&obj_x="+obj_x+"&obj_y="+obj_y+"&obj_z="+obj_z+"&obj_rotZ="+obj_rotZ+"&obj_sell="+obj_sell+"&obj_price="+obj_price+"&obj_solid="+obj_solid+"&obj_clickThrough="+obj_clickThrough+"&obj_sizeX="+obj_sizeX+"&obj_sizeY="+obj_sizeY+"&targetDatabase="+GuiFuncs.deleteFocusPlace;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_requestObjectPerms(objId)
		{
			//MovieClip(ROOT).output("edit_requestObjectPerms: "+objId);
			
			var vars = "cmd=requestObjectPerms&objId="+objId+"&targetDatabase="+GuiFuncs.deleteFocusPlace;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_applyObjectPerms(objId, next_copy, next_mod, next_trans, next_buyer_copy, next_buyer_mod, next_buyer_trans)
		{
			//MovieClip(ROOT).output("edit_applyObjectProps: "+objId);
			
			var vars = "cmd=applyObjectPerms&objId="+objId+"&next_copy="+next_copy+"&next_mod="+next_mod+"&next_trans="+next_trans+"&next_buyer_copy="+next_buyer_copy+"&next_buyer_mod="+next_buyer_mod+"&next_buyer_trans="+next_buyer_trans+"&targetDatabase="+GuiFuncs.deleteFocusPlace;
			sendEditorInputNow(vars);
			
		}
		
		public function edit_newText(folderId)
		{
			var vars = "cmd=newText&folderId="+folderId;
			sendEditorInputNow(vars);
		}
		
		public function edit_newScript(folderId)
		{
			var vars = "cmd=newScript&folderId="+folderId;
			sendEditorInputNow(vars);
		}
		
		public function sendEditorInputNow(vars)
		{
			if (MovieClip(ROOT).host != null)
			{
				editUrlLoader.load(new URLRequest("https://"+MovieClip(ROOT).host+"/app/server/editor_input.jsp"+"?"+vars));
			}
			else
			{
				editUrlLoader.load(new URLRequest("../server/editor_input.jsp"+"?"+vars));
			}
		}
		
		public function onUrlLoaderIoError(event:IOErrorEvent)
		{
			//MovieClip(ROOT).output("IO error: "+event.text);
			checkConnection();
			MovieClip(ROOT).output("DISCONNECTED! Try reloading the client...", 1);
			MovieClip(ROOT).chat.displayChatBubble("DISCONNECTED! Try reloading the client...");
		}
		
		public function checkConnection()
		{
			var connectionCheckUrlLoader:URLLoader = new URLLoader();
			connectionCheckUrlLoader.addEventListener(flash.events.IOErrorEvent.IO_ERROR , connectionCheckIoError);
			
			if (MovieClip(ROOT).host != null)
			{
				connectionCheckUrlLoader.load(new URLRequest("https://"+MovieClip(ROOT).host+"/app/server/connection_check.jsp"));
			}
			else
			{
				connectionCheckUrlLoader.load(new URLRequest("../server/connection_check.jsp"));
			}
			
			function connectionCheckIoError(event)
			{
				MovieClip(ROOT).output("DISCONNECTED! Try reloading the client...", 1);
				MovieClip(ROOT).chat.displayChatBubble("DISCONNECTED! Try reloading the client...");
			}
		}

	}
}
