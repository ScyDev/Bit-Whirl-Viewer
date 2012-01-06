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
	import fl.controls.Label;
	import flash.events.*;
	import fl.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.text.*;
	
	public class JavaCallableFunctions extends GlobalStage
	{
		public function JavaCallableFunctions()
		{
			MovieClip(ROOT).output("INIT: JavaCallableFunctions has run...", 0);		
		}

		public function update_moveObjectZ(clip_name, new_z)
		{
			GuiFuncs.clearEditHandles();
			
			var concernedClip = MovieClip(ROOT).guiEvents.getObjectFromMap(clip_name);
			if (concernedClip == null)
			{
				concernedClip = MovieClip(ROOT).guiEvents.getObjectFromHud(clip_name);
			}
		
			if (concernedClip != null)
			{
				MovieClip(ROOT).output("Adding obj moveObjectZ: "+clip_name, 0);
				addObjectToContainerAndZOrder(concernedClip, clip_name, new_z, concernedClip.parent);
				
				//MovieClip(ROOT).output("moveZ called with: "+clip_name+", "+new_z, 0); 
				/*
				if (concernedClip != null)
				{
					if (new_z != clip_name)
					{ 
						//concernedClip.parent.removeChild(concernedClip);
						//concernedClip.parent.addChild(concernedClip);
						var targetChild = concernedClip.parent.getChildByName(new_z);
						if (targetChild != null)
						{
							var theParent = concernedClip.parent;
							var bleh = new MovieClip();
							bleh.addChild(concernedClip);
							//theParent.addChild(concernedClip);
									
							var targetChildIndex = theParent.getChildIndex(targetChild);
							MovieClip(ROOT).output("target index: "+targetChildIndex, 0); 
							theParent.addChildAt(concernedClip, targetChildIndex);
						}
			
						return;
					}
					
				}*/
			}
		}
		
		public function update_moveObject(clip_name, path, new_z, new_speed, projected_duration_millis, cmdCounter)
		{
			var concernedClip = MovieClip(ROOT).guiEvents.getObjectFromMap(clip_name);
			if (concernedClip == null)
			{
				concernedClip = MovieClip(ROOT).guiEvents.getObjectFromHud(clip_name);
			}
		
			//MovieClip(ROOT).output("moveIt called with: "+clip_name+", "+new_x+", "+new_y); 
			if (concernedClip != null)
			{
				var date = new Date();
				MovieClip(ROOT).output("Start moving object: "+date.getMinutes()+":"+date.getSeconds()+"."+date.getMilliseconds(), 1);
				
				concernedClip.moveMyself(path, new_speed, projected_duration_millis);
			}
		}
		
		public function update_rotateObject(clip_name, rotZ, rotDir, new_speed, continuous)
		{
			var concernedClip = MovieClip(ROOT).guiEvents.getObjectFromMap(clip_name);
			if (concernedClip == null)
			{
				concernedClip = MovieClip(ROOT).guiEvents.getObjectFromHud(clip_name);
			}
		
			//MovieClip(ROOT).output("moveIt called with: "+clip_name+", "+new_x+", "+new_y); 
			if (concernedClip != null)
			{
				//concernedClip.addRotation(rotZ);
				concernedClip.rotateMyself(rotZ, rotDir, new_speed, continuous);
			}
		}
		
		public function update_removeObj(clip_name)
		{
			var concernedClip = MovieClip(ROOT).guiEvents.getObjectFromMap(clip_name);
			if (concernedClip == null)
			{
				concernedClip = MovieClip(ROOT).guiEvents.getObjectFromHud(clip_name);
			}
			
			if (concernedClip != null)
			{
				if (concernedClip == GuiFuncs.currSelectedClip)
				{
					GuiFuncs.clearEditHandles();
				}
					
				concernedClip.removeListeners(); // so we don't get null pointers when event is triggered
				concernedClip.graphics.clear();
				
				//removeFromZOrder(concernedClip); // not good, need to splice out
				MovieClip(ROOT).guiEvents.zOrder.splice(MovieClip(ROOT).guiEvents.getZOrderIndexOf(clip_name), 1);
				
				//concernedClip.removeChild(concernedClip.getChildByName("representation")); // why??
				concernedClip.parent.removeChild(concernedClip);
				//MovieClip(ROOT).output("DELETED: "+clip_name, 0);
			}
		}
		
		public function update_warpObject(clip_name, new_x, new_y)
		{
			var concernedClip = MovieClip(ROOT).guiEvents.getObjectFromMap(clip_name);
			if (concernedClip != null)
			{
				//MovieClip(ROOT).output("update_warpObject called with: "+clip_name+", "+new_x+", "+new_y);
				
				concernedClip.x = new_x;
				concernedClip.y = new_y;
				
				if (MovieClip(ROOT).guiEvents.edit_mode == 1 && concernedClip == GuiFuncs.currSelectedClip)
				{
					GuiFuncs.drawEditHandles(GuiFuncs.currSelectedClip);
				}
				
			}
		}
		
		public function update_resizeObject(clip_name, new_w, new_h, new_x, new_y)
		{
			var concernedClip = MovieClip(ROOT).guiEvents.getObjectFromMap(clip_name);
			if (concernedClip == null)
			{
				concernedClip = MovieClip(ROOT).guiEvents.getObjectFromHud(clip_name);
			}
		
			//MovieClip(ROOT).output("resize called with: "+clip_name+", "+new_w+", "+new_h);
			if (concernedClip != null)
			{
				concernedClip.resizeMyself(new_w, new_h, new_x, new_y);
			}
		}
		
		public function update_changeImage(clip_name, objUrl, isSprite, tileX, tileY, startFrame, endFrame, fps)
		{
			var concernedClip = MovieClip(ROOT).guiEvents.getObjectFromMap(clip_name);
			if (concernedClip == null)
			{
				concernedClip = MovieClip(ROOT).guiEvents.getObjectFromHud(clip_name);
			}
		
			//MovieClip(ROOT).output("changeImage called with: "+clip_name+"="+concernedClip+", "+objUrl);
			if (concernedClip != null)
			{
				var currWidth = concernedClip.width;
				var currHeight = concernedClip.height;
				var currX = concernedClip.x;
				var currY = concernedClip.y;
				var currZ = concernedClip.parent.getChildIndex(concernedClip);
				
				// NEW: replace just representation
				concernedClip.isSprite = isSprite;
				concernedClip.tileX = tileX;
				concernedClip.tileY = tileY;
				concernedClip.startFrame = startFrame;
				concernedClip.endFrame = endFrame;
				concernedClip.fps = fps;
				
				while (concernedClip.getChildByName("representation") != null)
				{
					concernedClip.removeChild(concernedClip.getChildByName("representation"));
				}
				concernedClip.representationUrl = objUrl;
				
				var date = new Date();
				MovieClip(ROOT).output("IMG loading... "+date.getMinutes()+":"+date.getSeconds()+"."+date.getMilliseconds(), 0);
		
				MovieClip(ROOT).movieLoader.loadImage(concernedClip, objUrl, "representation");
			}
		}
		
		public function update_setObjectProps(clip_name, objName, rotZ, sell, price, solid, clickThrough, owner, sizeX, sizeY)
		{
			var concernedClip = MovieClip(ROOT).guiEvents.getObjectFromMap(clip_name);
			if (concernedClip == null)
			{
				concernedClip = MovieClip(ROOT).guiEvents.getObjectFromHud(clip_name);
			}
		
			if (concernedClip != null)
			{
				//concernedClip.addRotation(rotZ);
		 
				concernedClip.inflObjName = objName;
				if (sell == "true") {sell = true} else {sell = false};
				concernedClip.sell = sell;
				concernedClip.price = price;
				if (solid == "true") {solid = true} else {solid = false};
				concernedClip.solid = solid;
				if (clickThrough == "true") {clickThrough = true} else {clickThrough = false};
				concernedClip.clickThrough = clickThrough;
				concernedClip.inflObjOwner = owner;
				concernedClip.desiredWidth = sizeX;
				concernedClip.desiredHeight = sizeY;
				
				concernedClip.setContextMenu();
			}
			
			
		}
		
		public function update_playSound(soundUrl, loop)
		{
			update_stopSound(soundUrl); // BETTER: after playing sound, it should autom. remove itself from playingSounds
			
			if (MovieClip(ROOT).soundEffects.playingSounds[soundUrl] == null)
			{
				var currSound:Sound = null;
				//MovieClip(ROOT).output("playing sound: "+soundUrl, 0);
				if (MovieClip(ROOT).soundEffects.loadedSounds[soundUrl] != null)
				{
					currSound = MovieClip(ROOT).soundEffects.loadedSounds[soundUrl] as Sound;
				}
				else
				{
					currSound = new Sound(new URLRequest(soundUrl));
				}
				
				if (currSound != null)
				{
					function onSoundIoError()
					{
						MovieClip(ROOT).output("failed to load sound: "+soundUrl, 0);
					}
					currSound.addEventListener(IOErrorEvent.IO_ERROR, onSoundIoError);
					
					var soundChannel:SoundChannel = currSound.play(0, loop, MovieClip(ROOT).soundEffects.volumeSoundTransform);
					
					MovieClip(ROOT).soundEffects.playingSounds[soundUrl] = soundChannel;
				}
			}
		}
		
		public function update_stopSound(soundUrl)
		{
			if (MovieClip(ROOT).soundEffects.playingSounds[soundUrl] != null)
			{
				SoundChannel(MovieClip(ROOT).soundEffects.playingSounds[soundUrl]).stop();
				MovieClip(ROOT).soundEffects.playingSounds[soundUrl] = null;
			}
		}
				
		
		public function update_createNewObj(objId, objUrl, posX, posY, targetZObj, sizeX, sizeY, rotZ, isSprite, tileX, tileY, startFrame, endFrame, fps, isHudElement, asAvatar)
		{
			var insertionContainer:MovieClip = MovieClip(ROOT).guiEvents.getMapCanvas();
			if (isHudElement == 1)
			{
				insertionContainer = MovieClip(ROOT).guiEvents.getHudCanvas();
			}
			
			if (insertionContainer.getChildByName(objId) == null)
			{	
				var newMc = new InfilionMovieClip();
				newMc.name = objId;
				newMc.rotZ = rotZ;
				
				newMc.targetZ = targetZObj;
				
				newMc.inflObjId = objId;
		
				newMc.isSprite = isSprite;
				newMc.tileX = tileX;
				newMc.tileY = tileY;
				newMc.startFrame = startFrame;
				newMc.endFrame = endFrame;
				newMc.fps = fps;
				
				newMc.isHudElement = isHudElement;
				newMc.asAvatar = asAvatar;
				
				// löl
				MovieClip(ROOT).output("Adding obj createNewObj: "+objId, 0);
				addObjectToContainerAndZOrder(newMc, objId, targetZObj, insertionContainer);
				
				newMc.initMc()
		
				newMc.representationUrl = objUrl;
				
				newMc.x = posX;
				newMc.y = posY;
				
				//newMc.width = sizeX; // this makes object invisible... so use delayed call after init
				//newMc.height = sizeY;
			
				// initial resize
				newMc.desiredWidth = sizeX;
				newMc.desiredHeight = sizeY;
		
				MovieClip(ROOT).movieLoader.loadImage(newMc, objUrl, "representation");
				
				// for some reason, direct calls of resizeMyself doesn't work here. maybe it's too early for onEnterFrame event...
				//viewport.content[objName].resizeMyself(sizeX, sizeY, posX, posY);
			}
			else
			{
				InfilionMovieClip(insertionContainer.getChildByName(objId)).refreshedTime = new Date().getTime();
				InfilionMovieClip(insertionContainer.getChildByName(objId)).outOfBoundsTime = -1;
				//MovieClip(ROOT).output("obj "+objName+" already exists!");
			}
		}
		
		public function addObjectToContainerAndZOrder(concernedObj, objId, targetZObj, insertionContainer)
		{
			var zOrder = MovieClip(ROOT).guiEvents.zOrder;
			
				MovieClip(ROOT).output("TARGET ON CREATE for "+objId+": "+targetZObj, 0);
				var targetZId = int(targetZObj);
				if (concernedObj.isHudElement != 1) // no Z ordering for HUD elements ATM
				{
					// if this obj already exists in zOrder, remove it
					var existingZOrderIndex = MovieClip(ROOT).guiEvents.getZOrderIndexOf(objId);
					while (existingZOrderIndex > -1)
					{
						MovieClip(ROOT).output("splicing "+objId+" out at "+existingZOrderIndex, 0);
						zOrder.splice(existingZOrderIndex, 1);
						existingZOrderIndex = MovieClip(ROOT).guiEvents.getZOrderIndexOf(objId);
					}
					
					// find the targetMC, with help of zOrder, to insert new obj in display list
					var targetMc = null;
					if (zOrder[targetZId] != null && zOrder[targetZId] != -1)
					{
						targetMc = insertionContainer.getChildByName(zOrder[targetZId]);
						MovieClip(ROOT).output("found target clip in zOrder: "+targetMc, 0);
					}
					else
					{
						MovieClip(ROOT).output("search next higher... for "+targetZId, 0);
						
						if (targetZId >= zOrder.length) // fill up with -1
						{
							for (var i = zOrder.length; i < targetZId+1; i++)
							{
								zOrder[i] = -1;
							}
						}
						else
						{
							for (var i = targetZId; i < zOrder.length; i++)
							{
								if (zOrder[i] != -1)
								{
									//MovieClip(ROOT).output("found next higher! to insert below "+zOrder[i], 0);
									targetMc = insertionContainer.getChildByName(zOrder[i]);
									break;
								}
							}
						}
					}
					MovieClip(ROOT).output("targetMc: "+targetMc, 0);
					
					if (targetMc != null)
					{
						var targetZ = insertionContainer.getChildIndex(targetMc);
						insertionContainer.addChildAt(concernedObj, targetZ);
					}
					else
					{
						//MovieClip(ROOT).output("movieclip was null for: "+targetZObj);
						insertionContainer.addChild(concernedObj);
					}
				}
				else
				{
					insertionContainer.addChild(concernedObj);
				}
				
				// add object to our custom zLayer manager
				if (concernedObj.isHudElement != 1)
				{
					if (zOrder[targetZId] != null && zOrder[targetZId] != -1)
					{
						//zOrder[targetZId] = objId;
						zOrder.splice(targetZId, 0, objId);
					}
					else
					{
						zOrder[targetZId] = objId;
					}
				}
		
		}
		
		public function update_showLoadingScreen(x, y)
		{
			MovieClip(ROOT).guiEvents.closeLens(MovieClip(ROOT).viewport.horizontalScrollPosition+(MovieClip(ROOT).guiEvents.fixedViewportWidth/2), MovieClip(ROOT).viewport.verticalScrollPosition+(MovieClip(ROOT).guiEvents.fixedViewportHeight/2));
		}
		
		public function update_newMap(mapName, w, h, viewport_w, viewport_h)
		{
			// these to make sure we are fully back in play mode before making new map
			// to prevent viewport scaling messup
			MovieClip(ROOT).borderLayout.chatConsoleHeight = MovieClip(ROOT).borderLayout.minChatHeight+1;
			MovieClip(ROOT).borderLayout.clickChatHandleHandler(null);
			MovieClip(ROOT).guiEvents.clickPlay(null);
			
			
			// stop all playing sounds
			for each (var channel:SoundChannel in MovieClip(ROOT).soundEffects.playingSounds)
			{
				if (channel != null)
				{
					channel.stop();
				}
			}
			MovieClip(ROOT).soundEffects.playingSounds = new Object();
			MovieClip(ROOT).soundEffects.loadedSounds = new Object();
			MovieClip(ROOT).movieLoader.loadedGfx = new Object();
			
			MovieClip(ROOT).guiEvents.curr_map_name = mapName;
			MovieClip(ROOT).header.label_map.text = mapName;
			MovieClip(ROOT).guiEvents.initCanvas(w, h);
			
			if (viewport_w > 100)
			{
				MovieClip(ROOT).guiEvents.fixedViewportWidth = viewport_w;
			}
			if (viewport_h > 100)
			{
				MovieClip(ROOT).guiEvents.fixedViewportHeight = viewport_h;
			}
			MovieClip(ROOT).borderLayout.adjustLayoutSizes();
			MovieClip(ROOT).borderLayout.setPlayLayoutMode(true);
			//resizeViewport(viewport_w, viewport_h);
			
			MovieClip(ROOT).guiEvents.openLens(MovieClip(ROOT).viewport.horizontalScrollPosition+(MovieClip(ROOT).guiEvents.fixedViewportWidth/2), MovieClip(ROOT).viewport.verticalScrollPosition+(MovieClip(ROOT).guiEvents.fixedViewportHeight/2));
		}
		
		public function update_setObjectsToLoadCount(count)
		{
			MovieClip(ROOT).movieLoader.objectsToLoad = count;
		}
		
		public function update_mapLoaded()
		{
			MovieClip(ROOT).borderLayout.hideLoadingScreen();
			MovieClip(ROOT).guiEvents.openLens(MovieClip(ROOT).viewport.horizontalScrollPosition+(MovieClip(ROOT).guiEvents.fixedViewportWidth/2), MovieClip(ROOT).viewport.verticalScrollPosition+(MovieClip(ROOT).guiEvents.fixedViewportHeight/2));
		}
		
		public function update_scrollView(toX, toY, speed)
		{
			//MovieClip(ROOT).output("update_scrollView called with: "+toX+", "+toY);
			//header.label_map.text = curr_map_name+"/"+toX+"/"+toY+"/"+0;
			
			toX = int(toX);
			if (toX < 0) {toX = 0;}
			toY = int(toY);
			if (toY < 0) {toY = 0;}
			
			MovieClip(ROOT).viewport.scrollTo(toX*MovieClip(ROOT).viewport.content.scaleX, toY*MovieClip(ROOT).viewport.content.scaleY, speed*MovieClip(ROOT).viewport.content.scaleX);
			//viewport.scrollTo(toX, toY, speed);
		}
		
		public function update_refreshInventory()
		{
			MovieClip(ROOT).treeActions.loadInventoryTree();
		}
		
		public function update_refreshObjectContents()
		{
			if (MovieClip(ROOT).objectContents.contentsDialog != null)
			{
				MovieClip(ROOT).objectContents.loadObjContents(MovieClip(ROOT).objectContents.contentsDialog.list_obj_contents, MovieClip(ROOT).objectContents.contentsDialog.object_id.text);
			}
		}
		
		public function update_refreshLayers()
		{
			MovieClip(ROOT).layerList.loadLayerList();
		}
		
		public function update_setWatchedKeys(keys)
		{
			MovieClip(ROOT).guiEvents.setWatchedKeys(keys);
		}
		
		public function update_displayCredits(currCredits)
		{
			MovieClip(ROOT).header.label_credits.text = currCredits;
		}
		
		public function update_goToWebsite(url, target)
		{
			navigateToURL(new URLRequest(url), target);
		}
		
		public function update_displayChat(talker, msg, type)
		{
			MovieClip(ROOT).output("--- CHAT --- "+talker+": "+msg, 1);
			
			MovieClip(ROOT).chat.displayChatBubble(talker+": "+msg);
		}
		
		public function update_displayTextOnObject(clip_name, cssName, offsetX, offsetY)
		{
			var theCss = null;
			
			if (cssName != null && cssName != "")
			{
				var cssLoader = new URLLoader(new URLRequest("../server/get_css.jsp?obj_id="+clip_name+"&css_name="+cssName));
				cssLoader.addEventListener(Event.COMPLETE, onCssLoaderComplete);
				function onCssLoaderComplete(event:Event)
				{
					theCss = cssLoader.data;
					showTextNow(clip_name, theCss, offsetX, offsetY);
				}
			}
			else
			{
				showTextNow(clip_name, null, offsetX, offsetY);
			}
			
		
		}
		
		public function showTextNow(clip_name, theCss, offsetX, offsetY)
		{
			var textLoader = new URLLoader(new URLRequest("../server/get_text.jsp?obj_id="+clip_name));
			textLoader.addEventListener(Event.COMPLETE, onTextLoaderComplete);
			function onTextLoaderComplete(event:Event)
			{
				var theText = textLoader.data;
				
				var concernedClip = MovieClip(ROOT).guiEvents.getObjectFromMap(clip_name);
				//MovieClip(ROOT).output("setting TEXT: "+theText+" on: "+concernedClip.inflObjId, 0);
				if (concernedClip == null)
				{
					concernedClip = MovieClip(ROOT).guiEvents.getObjectFromHud(clip_name);
				}
		
				if (concernedClip != null)
				{
					
					var textField = TextField(concernedClip.getChildByName("objText"));
					if (textField == null)
					{
						textField = new TextField();
						textField.name = "objText";
						
						// use desiredWidth/Height because real width/height may have not been set yet if the loader is slow..
						textField.width = concernedClip.desiredWidth/concernedClip.scaleX;
						textField.height = concernedClip.desiredHeight/concernedClip.scaleY;
						
						textField.wordWrap = true;
						textField.multiline = true;
						textField.selectable = false;
						//textField.background = true;
						//textField.border = true;
				
					
						var format:TextFormat = new TextFormat();
						format.font = "Verdana";
						format.color = 0x000000;
						format.size = 32;
						//format.underline = true;
						textField.defaultTextFormat = format;
						
						concernedClip.addChild(textField);
					}
					
					if (theCss != null)
					{
						var sheet:StyleSheet = new StyleSheet();
						sheet.parseCSS(theCss);
						textField.styleSheet = sheet;
					}
					textField.htmlText = theText;
					textField.x = offsetX;
					textField.y = offsetY;
				}
			}	
		}
		
		public function update_showObjectPerms(clip_name, oc, om, ot, nc, nm, nt, bc, bm, bt)
		{
			var permsDialog = MovieClip(ROOT).guiEvents.permsDialog;
			
			if (permsDialog != null)
			{
				permsDialog.perms_yours_copy.selected = (oc == "true"); 
				permsDialog.perms_yours_mod.selected = (om == "true"); 
				permsDialog.perms_yours_trans.selected = (ot == "true"); 
				permsDialog.perms_nextowners_copy.selected = (nc == "true"); 
				permsDialog.perms_nextowners_mod.selected = (nm == "true"); 
				permsDialog.perms_nextowners_trans.selected = (nt == "true"); 
				permsDialog.perms_nextbuyers_copy.selected = (bc == "true"); 
				permsDialog.perms_nextbuyers_mod.selected = (bm == "true"); 
				permsDialog.perms_nextbuyers_trans.selected = (bt == "true"); 
			}
			else
			{
				MovieClip(ROOT).output("NO DLG?!!?", 0);
			}
		}
		
		public function update_viewportFollowObject(clip_name)
		{
			//MovieClip(ROOT).output("FOLLOWIIIIIIIIIIIIING "+clip_name, 0);
			
			if (GuiFuncs.currViewportFollowingClip != null)
			{
				//MovieClip(ROOT).output("RESETTING FOLLOW OBJ!", 0);
				GuiFuncs.currViewportFollowingClip = null;
			}
			
			var concernedClip = MovieClip(ROOT).guiEvents.getObjectFromMap(clip_name);
			if (concernedClip != null)
			{
				GuiFuncs.currViewportFollowingClip = concernedClip;
				
				//header.label_map.text = curr_map_name+"/"+(concernedClip.x + concernedClip.desiredWidth/2)+"/"+(concernedClip.y + concernedClip.desiredHeight/2)+"/"+0;
				//MovieClip(ROOT).output("YES REALLY FLWING "+InfilionMovieClip(MovieClip(getMapCanvas()).getChildByName(clip_name)).viewportFollowingThisClip, 0);
			}
			else
			{
				MovieClip(ROOT).output("OMFG!! obj to follow not found!", 0);
			}
		}
		
		public function update_objectAttachObject(mainObjectId, attachyObjectId, relativeX:int, relativeY:int)
		{
			var concernedClip = MovieClip(MovieClip(ROOT).guiEvents.getMapCanvas()).getChildByName(mainObjectId);
			var attachyClip = MovieClip(MovieClip(ROOT).guiEvents.getMapCanvas()).getChildByName(attachyObjectId);
			if (concernedClip != null && attachyClip != null)
			{
				concernedClip.attachedObjects.push(attachyClip);
				attachyClip.attachedToObject = concernedClip;
				attachyClip.attachedRelativeX = relativeX;
				attachyClip.attachedRelativeY = relativeY;
				
				attachyClip.x = concernedClip.x + attachyClip.attachedRelativeX;
				attachyClip.y = concernedClip.y + attachyClip.attachedRelativeY;
			}
			
		}
		
		public function update_objectDetachObject(mainObjectId, detachyObjectId)
		{
			var concernedClip = MovieClip(MovieClip(ROOT).guiEvents.getMapCanvas()).getChildByName(mainObjectId);
			var attachyClip = MovieClip(MovieClip(ROOT).guiEvents.getMapCanvas()).getChildByName(detachyObjectId);
			
			if (concernedClip != null && attachyClip != null)
			{
				var attachyIndex = concernedClip.attachedObjects.indexOf(attachyClip);
				MovieClip(ROOT).output("update_objectDetachObject index:"+attachyIndex, 1);
				if (attachyIndex >= 0)
				{
					concernedClip.attachedObjects.splice(attachyIndex, 1);
				}
				attachyClip.attachedToObject = null;
				attachyClip.attachedRelativeX = 0;
				attachyClip.attachedRelativeY = 0;
			}
			
		}
		
		public function update_respondLag(cmdCounter)
		{
			if (MovieClip(ROOT).ajax.sentCmds[cmdCounter] != null)
			{
				var date = new Date();
				MovieClip(ROOT).ajax.sentCmdsLag.push(date.getTime()-MovieClip(ROOT).ajax.sentCmds[cmdCounter]);
				//MovieClip(ROOT).output("lag for cmd "+cmdCounter+": "+MovieClip(ROOT).ajax.sentCmdsLag[MovieClip(ROOT).ajax.sentCmdsLag.length-1], 0);
				delete MovieClip(ROOT).ajax.sentCmds[cmdCounter];
			}
		}
		
		public function update_objectRotFollowMousePointer(mainObjectId, theValue)
		{
			var concernedClip = MovieClip(MovieClip(ROOT).guiEvents.getMapCanvas()).getChildByName(mainObjectId);
			
			if (concernedClip != null)
			{
				concernedClip.setRotationFollowMouse(theValue);
			}
		}
		

	}
}
