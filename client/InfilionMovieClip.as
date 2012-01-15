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
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Loader;
    import flash.events.Event;	
	import flash.events.MouseEvent;	
	import flash.ui.Keyboard;	
	import flash.ui.ContextMenu;	
	import flash.ui.ContextMenuItem;	
	import flash.events.ContextMenuEvent;	
	import flash.geom.Point;
	import com.yahoo.astra.fl.managers.AlertManager;
	
	
	// used for rotationg and other transitions
	import fl.transitions.*;
	import fl.transitions.easing.*;
	import fl.motion.MatrixTransformer;
	import flash.geom.Matrix;
	
	public dynamic class InfilionMovieClip extends flash.display.Sprite
	{
		var ourRoot;
		
		public var inflObjId = "";
		public var inflObjName = "";
		public var sell = false;
		public var solid = false;
		public var clickThrough = false;
		public var price = 0;
		public var representationUrl = "";
		
		// x y z whre the server wants the obj to be
		public var targetX = 0;
		public var targetY = 0;
		public var targetZ = 0;
		
		public var activePath;
		public var currPathSegment = 0;
		public var activeTarget = 0;
		public var projectedDurationMillis = 0;
		public var speed = 0;

		public var activeResize = 1;
		public var desiredWidth:int = 0;
		public var desiredHeight:int = 0;
		
		public var rotZ = 0;
		public var activeRot = 0;
		public var targetRotZ = 0;
		public var rotDir = 0;
		public var rotSpeed = 0;
		public var rotContinuous = 0;
		
		public var isSprite = 0;
		public var tileX = 0;
		public var tileY = 0;
		public var startFrame = 0;
		public var endFrame = 0;
		public var fps = 0;
		public var stopAnimOnMovementDest = 1;
		
		public var isHudElement = 0;
		public var asAvatar = 0;
		public var rotationFollowMousePointer = false;
		
		public var bitmapSprite:BitmapSprite;
		
		public var scaleAnchorX = 0;
		public var scaleAnchorY = 0;
		
		public var attachedObjects = new Array();
		public var attachedToObj = null;
		public var attachedRelativeX:int = 0;
		public var attachedRelativeY:int = 0;
		
		var myContextMenu:ContextMenu;
		
		public var pathwalker:PathWalker;
		
		var pressed = 0;
		var dragging = 0;
		
		var createdTime = 0;
		var refresedTime = 0;
		var outOfBoundsTime = 0;
		
		
		public function initMc()
		{
			this.createdTime = new Date().getTime();
			this.refresedTime = new Date().getTime();
			this.outOfBoundsTime = -1;
			
			//ourRoot = 
			this.addEventListener(MouseEvent.MOUSE_DOWN, onPressMc);
			//this.addEventListener(MouseEvent.MOUSE_MOVE, onMoveMc);
			//this.addEventListener(MouseEvent.MOUSE_UP, onReleaseMc);
			
			this.setContextMenu();
		}
		
		public function moveMyself (path, new_speed, projected_duration_millis)
		{
			//output("moveMyself called!");
			this.activeTarget = 1;
			this.projectedDurationMillis = projected_duration_millis;
			this.speed = new_speed;
			
			var totalLength = 0;
		
			// parse path
			var pathSegments = path.split(":");
			for (var i = 0; i < pathSegments.length; i++)
			{
				pathSegments[i] = pathSegments[i].split("/");
				if (i > 0)
				{
					totalLength += Math.sqrt(Math.pow(Math.abs(pathSegments[i][0]-pathSegments[i-1][0]), 2) + Math.pow(Math.abs(pathSegments[i][1]-pathSegments[i-1][1]), 2));
				}
				MovieClip(this.root).output("path segment: "+pathSegments[i][0]+"/"+pathSegments[i][1], 0);
			}
			
			// set duration per segment
			for (var i = 0; i < pathSegments.length; i++)
			{
				pathSegments[i].push(0);
				if (i > 0)
				{
					pathSegments[i][2] = (this.projectedDurationMillis/totalLength) * Math.sqrt(Math.pow(Math.abs(pathSegments[i][0]-pathSegments[i-1][0]), 2) + Math.pow(Math.abs(pathSegments[i][1]-pathSegments[i-1][1]), 2));
				}
				MovieClip(this.root).output("duration for segment: "+pathSegments[i][2], 0);
			}

			this.currPathSegment = 1; // start with segment 1, cause 0 is the current location
			this.activePath = pathSegments;
			this.targetX = this.activePath[this.currPathSegment][0]; 
			this.targetY = this.activePath[this.currPathSegment][1];
			
			pathwalker = new PathWalker(this.x, this.y, this.targetX, this.targetY, new_speed, this.activePath[this.currPathSegment][2]);
	
			// add event on every frame to perform movement
			stage.addEventListener(Event.ENTER_FRAME, onEveryFrameMove, false, 0, true);
		}
		
		public function onEveryFrameMove(event:Event)
		{
			// MOVEMENT
			if (this != null && this.activeTarget == 1)
			{
				if (pathwalker != null)
				{
					pathwalker.nextStep();
					
					var theViewport = MovieClip(this.root).viewport;
					var mapCanvas = MovieClip(this.root).guiEvents.getMapCanvas();
					
					/*
					// check if Z needs to be swapped on next step. overlapping any object?
					//var intersectingObjects = MovieClip(this.root).getObjectsUnderPoint(mapCanvas.localToGlobal(new Point(this.x, this.y)));
					var intersectingObjects = mapCanvas.getObjectsUnderPoint(mapCanvas.localToGlobal(new Point(this.x, this.y)));
					//intersectingObjects = intersectingObjects.concat(mapCanvas.getObjectsUnderPoint(mapCanvas.localToGlobal(new Point(this.x+this.width, this.y))));
					//intersectingObjects = intersectingObjects.concat(mapCanvas.getObjectsUnderPoint(mapCanvas.localToGlobal(new Point(this.x+this.width, this.y+this.height))));
					//intersectingObjects = intersectingObjects.concat(mapCanvas.getObjectsUnderPoint(mapCanvas.localToGlobal(new Point(this.x, this.y+this.height))));
					
					MovieClip(this.root).output("for "+intersectingObjects.length, 0);
					for (var i = 0; i < intersectingObjects.length; i++)
					{
						//MovieClip(this.root).output("wehuuuu", 0);
						var currObj = intersectingObjects[i];
						//MovieClip(this.root).output("INTERSECTING:"+currObj.name+" "+currObj+" "+currObj.parent+" "+currObj.parent.parent+" "+currObj.parent.parent.parent+" "+currObj.parent.parent.parent.parent, 0); //InfilionMovieClip(currObj).inflObjId
						
						//if (currObj is InfilionMovieClip && currObj.inflObjId != this.inflObjId)
						
						if (currObj.parent != null && currObj.parent is Loader && currObj.parent.parent != null && currObj.parent.parent is InfilionMovieClip && InfilionMovieClip(currObj.parent.parent).inflObjId != this.inflObjId)
						{
							currObj = InfilionMovieClip(currObj.parent.parent);
							
							//MovieClip(this.root).output("OK! Z-ing with an InfilionMovieClip", 0);
							if (this.y+(this.height/2) >= currObj.y+(currObj.height/2))
							{
								// is lower (y) so put before
								var targetClip = currObj.parent.getChildAt(currObj.parent.getChildIndex(currObj)+1);
								if (targetClip != null)
								{
									MovieClip(this.root).update_moveObjectZ(this.inflObjId, InfilionMovieClip(targetClip).inflObjId);
								}
								else
								{
								}
							}
							else
							{
								// is higher (y), so put behind
								MovieClip(this.root).update_moveObjectZ(this.inflObjId, InfilionMovieClip(currObj).inflObjId);
							}
						}
					}
					*/
					
					//MovieClip(root).output("step: "+(this.x-pathwalker.currX) );
					
					this.x = pathwalker.currX;
					this.y = pathwalker.currY;
					
					// scroll viewport
					//if (this.viewportFollowingThisClip == 1)
					if (GuiFuncs.currViewportFollowingClip != null && GuiFuncs.currViewportFollowingClip.inflObjId == this.inflObjId)
					{
						MovieClip(root).header.label_map.text = MovieClip(root).guiEvents.curr_map_name+"/"+(pathwalker.currX + this.desiredWidth/2)+"/"+(pathwalker.currY + this.desiredHeight/2)+"/"+0;
						
						theViewport.horizontalScrollPosition = pathwalker.currX * theViewport.content.scaleX - theViewport.width/2 + this.desiredWidth/2;
						theViewport.verticalScrollPosition = pathwalker.currY * theViewport.content.scaleY - theViewport.height/2 + this.desiredHeight/2;
						
						//theViewport.checkObjectsInViewportBoundary();
					}
					
					// move attached objects with this object
					for (var i = 0; i < this.attachedObjects.length; i++)
					{
						var currAttachyObj = this.attachedObjects[i];
						currAttachyObj.x = this.x + currAttachyObj.attachedRelativeX;
						currAttachyObj.y = this.y + currAttachyObj.attachedRelativeY;
					}
					
					//MovieClip(root).output("move on frame: "+inflObjName, 0);
					// remove event handler if at target (must be made more sensible in the future, if more things than movement happen)
					if (this.x == this.targetX && this.y == this.targetY)
					{
						if (this.currPathSegment < this.activePath.length-1)
						{
							MovieClip(root).output("moving, next path segment.", 0);
							this.currPathSegment++;
							this.targetX = this.activePath[this.currPathSegment][0]; // start with segment 1, cause 0 is the current location
							this.targetY = this.activePath[this.currPathSegment][1];
							
							pathwalker = new PathWalker(this.x, this.y, this.targetX, this.targetY, speed, this.activePath[this.currPathSegment][2]);
						}
						else
						{
							MovieClip(root).output("reached target: "+inflObjName, 0);
							if (stopAnimOnMovementDest == 1)
							{
								if (this.isSprite && bitmapSprite != null)
								{
									//MovieClip(root).output("STOP ANIMATING!", 0);
									bitmapSprite.removeEnterFrameEvent();
									
									bitmapSprite.internFrameCounter = -1; // so next frame drawn will be frame 0
									bitmapSprite.drawMyself(null);
								}
							}
							
							//this.onEnterFrame = null;
							this.activeTarget = 0;
							this.activePath = null;
							this.currPathSegment = 0;
							
							stage.removeEventListener(Event.ENTER_FRAME, onEveryFrameMove);
							//this.remove
							MovieClip(root).output("ARRIVED!! "+MovieClip(root).guiEvents.edit_mode, 0);
							// redraw handles if clip is selected
							if (MovieClip(root).guiEvents.edit_mode == 1 && this == GuiFuncs.currSelectedClip)
							{
								GuiFuncs.drawEditHandles(GuiFuncs.currSelectedClip);
							}
						}
					}
				}
			}

		}
		
		public function setRotationFollowMouse(theVal)
		{
			this.rotationFollowMousePointer = theVal;
			
			if (theVal)
			{
				stage.addEventListener(Event.ENTER_FRAME, onEveryFrameRotate, false, 0, true);
			}
		}
	
		public function rotateMyself(rotZ, rotDir, new_speed, continuous)
		{
			this.activeRot = 1;
			this.targetRotZ = rotZ;
			this.rotDir = rotDir;
			this.rotSpeed = new_speed;
			this.rotContinuous = continuous;
			
			//MovieClip(root).output("start rot "+this.rotZ, 1);

			if (stage != null)
			{
				stage.addEventListener(Event.ENTER_FRAME, onEveryFrameRotate, false, 0, true);
			}
		}
		
		public function onEveryFrameRotate(event:Event)
		{
			if (this.activeRot == 1)
			{				
				//MovieClip(root).output("rot "+this.rotZ+" speed "+this.rotSpeed+" dir "+this.rotDir+" continuous "+this.rotContinuous+" targetRot "+this.targetRotZ, 1);
				var oldRot = this.rotZ;
				
				if (this.rotContinuous != 1 
					&& Math.abs(this.targetRotZ - this.rotZ) <= this.rotSpeed)
					//&& this.targetRotZ >= Math.min(oldRot, this.rotZ) && this.targetRotZ <= Math.max(oldRot, this.rotZ))
				{
					this.addRotation(this.targetRotZ - this.rotZ); // remainder
					
					//MovieClip(root).output("finish rot! "+this.rotZ+" - "+this.targetRotZ, 1);
					this.activeRot = 0;
					
					//stage.removeEventListener(Event.ENTER_FRAME, onEveryFrameRotate); // don't remove, cause we need it for rot-follow-mouse
				}
				else
				{
					this.addRotation(this.rotSpeed * this.rotDir);
				}
			}
			else if (this.rotationFollowMousePointer == true)
			{
				var currMouseX = MovieClip(this.root).viewport.content.mouseX;
				var currMouseY = MovieClip(this.root).viewport.content.mouseY;				
				
				var x_dist = currMouseX-(this.x+(desiredWidth/2));
				var y_dist = currMouseY-(this.y+(desiredHeight/2));
		  
				// http://www.euclideanspace.com/maths/algebra/vectors/angleBetween/index.htm
				var objRot = Math.atan2(y_dist, -x_dist) -  Math.atan2(1,0)
		
				objRot = objRot * (180/Math.PI);
		  
		  		// invert, otherwise it will run counter to the mouse pointer
				objRot = 360 - objRot;
				
				this.addRotation(objRot - this.rotZ);
			}
			
		}
		
		public function resizeMyself (new_width, new_height, new_x, new_y)
		{
			//MovieClip(root).output("resizeMyself called!");

			this.activeResize = 1;
			
			this.desiredWidth = new_width;
			this.desiredHeight = new_height;
			
			// add event on every frame to perform movement
			if (stage != null)
			{
				stage.addEventListener(Event.ENTER_FRAME, onEveryFrameResize, false, 0, true);
			}
			else
			{
				//MovieClip(root).output("STAGE NULL!!! OMG!!!!!!!¨¨111111");
			}
						
			if (new_x != this.x || new_y != this.y)
			{
				this.relocateMyself(new_x, new_y);
			}
			
		}
		
		public function onEveryFrameResize(event:Event) 
		{
			if (this.activeResize == 1)
			{
				//output("RESIZE");
				// SIZE
				MovieClip(root).output("setting width! "+this.width+" - "+this.desiredWidth, 0);
				
					// HACK to avoid wrong size when obj is rotated, cause we don't know (or are too lazy) to calculate from bounds of inner representation
					var oldRot = this.rotZ;
					this.addRotation(0);
					
					this.width = this.desiredWidth;
					this.height = this.desiredHeight;
					
					if (this.getChildByName("spriteRepresentation") != null)
					{
						this.scaleX = 1.0; // important for when the new image has another resolution than the old
						this.scaleY = 1.0;
						bitmapSprite.scaleX = 1.0; // important for when the new image has another resolution than the old
						bitmapSprite.scaleY = 1.0;
						this.getChildByName("spriteRepresentation").scaleX = 1.0; // important for when the new image has another resolution than the old
						this.getChildByName("spriteRepresentation").scaleY = 1.0;
						this.getChildByName("spriteRepresentation").width = this.desiredWidth;
						this.getChildByName("spriteRepresentation").height = this.desiredHeight;
					} 
					
					// and reverse rot Hack
					this.addRotation(oldRot);
					
					// redraw handles if clip is selected
					if (this == GuiFuncs.currSelectedClip)
					{
						GuiFuncs.drawEditHandles(GuiFuncs.currSelectedClip);
					}
				
				this.activeResize = 0;
				stage.removeEventListener(Event.ENTER_FRAME, onEveryFrameResize);
			}
		}
		
		public function removeListeners()
		{
			stage.removeEventListener(Event.ENTER_FRAME, onEveryFrameResize);
			stage.removeEventListener(Event.ENTER_FRAME, onEveryFrameMove);
			if (bitmapSprite != null)
			{
				bitmapSprite.removeEnterFrameEvent();
				//stage.removeEventListener(Event.ENTER_FRAME, bitmapSprite.drawMyself);
			}
		}
		
		public function relocateMyself (new_x, new_y)
		{
			this.x = new_x;
			this.y = new_y;
		}
		
		public function onPressMc(event:Event)
		{
			//MovieClip(root).output("pressed... "+MovieClip(root).getEditMode()+"  "+GuiFuncs.currSelectedClip);
			if (MovieClip(root).editFunctions.getEditMode() == 1)
			{
				// release currently dragged clip if a new one is clicked (usefull if mouse is released outside of flash player, so we miss the event: obj sticks to mousepointer)
				if (GuiFuncs.currSelectedClip != null && GuiFuncs.currSelectedClip.dragging == 1)
				{
					GuiFuncs.currSelectedClip.onReleaseMc(event);
				}
				
				// select in layer list
				var layer_list = MovieClip(root).layer_list;

				for (var i = 0; i < layer_list.dataProvider.length; i++)
				{
					if (layer_list.dataProvider.getItemAt(i).id == this.inflObjId)
					{
						layer_list.selectedIndex = i;
						layer_list.scrollToIndex(i);
					}
				}
				
				// resize or drag
				if (Key.isDown(Keyboard.SHIFT) && Key.isDown(Keyboard.CONTROL))
				{
					var currMouseX = MovieClip(root).viewport.content.mouseX;
					var currMouseY = MovieClip(root).viewport.content.mouseY;
					
					this.scaleAnchorX = currMouseX;
					this.scaleAnchorY = currMouseY;
				}
				else if (Key.isDown(Keyboard.SHIFT))
				{
					MovieClip(root).output("changing to Z: "+GuiFuncs.currSelectedClip, 0);
					MovieClip(root).editFunctions.edit_changeObjectZ(GuiFuncs.currSelectedClip.inflObjId, 1, this.inflObjId);
				}
				else if (Key.isDown(Keyboard.CONTROL))
				{
					MovieClip(root).output("changing to Z: "+GuiFuncs.currSelectedClip, 0);
					MovieClip(root).editFunctions.edit_changeObjectZ(GuiFuncs.currSelectedClip.inflObjId, 0, this.inflObjId);
				}
				else
				{
					pressed = 1;
					//output("dragging "+this);
				}
					
				GuiFuncs.drawEditHandles(this);
				GuiFuncs.currSelectedClip = this;
				
				GuiFuncs.deleteFocusObjectId = this.inflObjId;
				GuiFuncs.deleteFocusObjectName = this.inflObjName;
				GuiFuncs.deleteFocusPlace = GuiFuncs.SELECTION_FOCUS_MAP;
				
				GuiFuncs.updateObjProps(this);
				//this.setContextMenu();
				
			}
		}
		
		public function setContextMenu()
		{
			var movieClipReference = this;
					this.myContextMenu = new ContextMenu(); 
					this.myContextMenu.hideBuiltInItems();
					
					if (this.isHudElement != 1 && this.asAvatar != true)
					{
						var itemTake:ContextMenuItem = new ContextMenuItem(".:. Take");
						itemTake.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemClicked);
						this.myContextMenu.customItems.push(itemTake);
					}
								
					if (this.asAvatar == true)
					{
						var itemProfile:ContextMenuItem = new ContextMenuItem(".:. Profile");
						itemProfile.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemClicked);
						this.myContextMenu.customItems.push(itemProfile);

						var itemPay:ContextMenuItem = new ContextMenuItem(".:. Pay");
						itemPay.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemClicked);
						this.myContextMenu.customItems.push(itemPay);
					}
					
					if (this.sell == true)
					{

						var itemBuy:ContextMenuItem = new ContextMenuItem(".:. Buy");
						itemBuy.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemClicked);
						this.myContextMenu.customItems.push(itemBuy);
					}
					
					if (this.isHudElement == 1)
					{
						var itemUnhud:ContextMenuItem = new ContextMenuItem(".:. Remove from HUD");
						itemUnhud.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemClicked);
						this.myContextMenu.customItems.push(itemUnhud);
					}
					
					var itemMuteObj:ContextMenuItem = new ContextMenuItem(".:. Mute Object");
					itemMuteObj.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemClicked);
					this.myContextMenu.customItems.push(itemMuteObj);

					var itemMuteUser:ContextMenuItem = new ContextMenuItem(".:. Mute User/Owner");
					itemMuteUser.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemClicked);
					this.myContextMenu.customItems.push(itemMuteUser);
					
				    function onItemClicked(event:ContextMenuEvent):void  
				    {  
				 	    //MovieClip(root).output("You chose " + event.target.caption);  
						
						if (event.target.caption == ".:. Take")
						{
							MovieClip(root).editFunctions.edit_takeObject(inflObjId);
						}
						else if (event.target.caption == ".:. Profile")
						{
							MovieClip(root).search.showUserProfile("", inflObjId);
						}
						else if (event.target.caption == ".:. Pay")
						{
							MovieClip(root).guiEvents.showPayDialog(inflObjId, inflObjName, "");
						}
						else if (event.target.caption == ".:. Buy")
						{
							function buyConfirmHandler(event)
							{
								if (event.target.label == "Yes")
								{
									MovieClip(root).playFunctions.play_buyObject(inflObjId);
								}
							}
							AlertManager.createAlert(MovieClip(root), "Do you want to buy "+movieClipReference.inflObjName+" for "+movieClipReference.price+" Bits?", "Really buy?", ["Yes", "No"], buyConfirmHandler);  
							
						}
						else if (event.target.caption == ".:. Remove from HUD")
						{
							MovieClip(root).editFunctions.edit_removeFromHud(inflObjId);
						}
						else if (event.target.caption == ".:. Mute Object")
						{
							MovieClip(root).playFunctions.play_muteObject(inflObjId);
						}
						else if (event.target.caption == ".:. Mute User/Owner")
						{
							MovieClip(root).playFunctions.play_muteUser(inflObjId);
						}
				    }  

					Sprite(this).contextMenu = this.myContextMenu;
				
		}

		public function onMoveMc(event:Event)
		{
			if (Object(root).getEditMode() == 1) 
			{
				if (pressed == 1)
				{
					//MovieClip(root).output("MOVED!");
					dragging = 1;
					this.startDrag();
					
					pressed = 0;
				}
			}
		}
		
		public function onReleaseMc(event:Event)
		{
			// release resize handle, just in case mousepointer is no longer over it
			if (GuiFuncs.currSelectionClip != null)
			{
				GuiFuncs.currSelectionClip.handleLR.releaseHandle(event);
			}
			
			if (MovieClip(root).editFunctions.getEditMode() == 1) 
			{
				//if (currSelectedClip == viewport.content["selection"].myTargetClip)
				//{
					if (Key.isDown(Keyboard.SHIFT) && Key.isDown(Keyboard.CONTROL))
					{
						var currMouseX = MovieClip(root).viewport.content.mouseX;
						var currMouseY = MovieClip(root).viewport.content.mouseY;
						
						var scaleDeltaX = Math.ceil(currMouseX - this.scaleAnchorX);
						var scaleDeltaY = Math.ceil(currMouseY - this.scaleAnchorY);
						
						//MovieClip(root).output("RESIZE!!! "+scaleDeltaX+" "+scaleDeltaY);
						
						//selectionClip._width = currSelectedClip._x+scaleDeltaX;
						//selectionClip._height = currSelectedClip._y+scaleDeltaY;
						
						MovieClip(root).editFunctions.edit_resizeObject(GuiFuncs.currSelectedClip.inflObjId, GuiFuncs.currSelectedClip.width+scaleDeltaX, GuiFuncs.currSelectedClip.height+scaleDeltaY);
					}
					else
					{
						pressed = 0;
						
						if (GuiFuncs.currSelectedClip.dragging == 1)
						{
							//MovieClip(root).output("letgo: calling "+MovieClip(root).editFunctions.edit_relocateObject+" for "+GuiFuncs.currSelectedClip.inflObjId, 0);
							GuiFuncs.currSelectedClip.dragging = 0;
							
							GuiFuncs.currSelectedClip.stopDrag();
							// selectionClip._x and _y seem to be relative to starting pos here... so, add it to objects orig pos
							MovieClip(root).editFunctions.edit_relocateObject(GuiFuncs.currSelectedClip.inflObjId, GuiFuncs.currSelectedClip.x, GuiFuncs.currSelectedClip.y);
						}
					}
				//}
			}
		}
		
		public function activateClickthrough(activate:Boolean)
		{
			if (this.clickThrough == true)
			{
				this.mouseEnabled = !activate;
				this.mouseChildren = !activate;
			}
		}
		
		public function addRotation(rotZ)
		{
			//TransitionManager.start(concernedClip, {type:Rotate, direction:Transition.IN, duration:3, easing:Strong.easeInOut, ccw:false, degrees:rotZ});
			//concernedClip.rotation = rotZ;
			
			var rep = null;
			if (isSprite == 1)
			{
				rep = this.getChildByName("spriteRepresentation");
			}
			else if (this.getChildByName("representation") is Loader)
			{
				rep = Loader(this.getChildByName("representation")).content;
			}
			else
			{
				rep = this.getChildByName("representation");
			}
			
			/**/
			if (rep != null)
			{
				//MovieClip(root).output(inflObjId+"setRotation around "+rep.width/2+"/"+rep.height/2+" scale: "+rep.scaleX+"/"+scaleY, 1);				
				
				/*
				var matrix:Matrix = rep.transform.matrix;
				MatrixTransformer.rotateAroundInternalPoint(matrix, (rep.width/2)*rep.scaleX, (rep.height/2)*rep.scaleY, rotZ-this.rotZ); // damn... 50/50 seems to be a good point... why?
				rep.transform.matrix = matrix;
				*/
				
				var oldBounds = rep.getBounds(this);
				rep.rotation += rotZ;//-rep.rotation;
				
				var newBounds = rep.getBounds(this);
				//MovieClip(root).output("ROT rep boundaries   old:"+oldRepWidth+"/"+oldRepHeight+"  new: "+rep.width+"/"+rep.height, 0);
				var deltaBoundsX = oldBounds.x-newBounds.x;
				var deltaBoundsY= oldBounds.y-newBounds.y;
				var deltaBoundsW = oldBounds.width-newBounds.width;
				var deltaBoundsH= oldBounds.height-newBounds.height;
				rep.x += deltaBoundsX + deltaBoundsW/2;
				rep.y += deltaBoundsY + deltaBoundsH/2;
				//MovieClip(root).output("ROT rep delta :"+deltaRepWidth+"/"+deltaRepHeight+"  rep pos: "+rep.x+"/"+rep.y, 0);
				//MovieClip(root).output("BOUNDS :"+rep.getBounds(this), 0);
				
				//this.opaqueBackground = 0xFF0000;
				//MovieClip(root).output("rotation: "+rep.rotation, 0);			
				
				//because flashs rot is -180 to 180, while server is 0 to 360
				if (rep.rotation < 0) this.rotZ = 360-Math.abs(rep.rotation);
				else this.rotZ = rep.rotation; 
			}
			

			/*
			if (this.width > 0 && this.height > 0)
			{
			MovieClip(root).output("setRotation around "+this.width/2+"/"+this.height/2, 0);				
			var matrix:Matrix = this.transform.matrix;
			MatrixTransformer.rotateAroundInternalPoint(matrix, 50, 50, rotZ-this.rotZ);
			this.transform.matrix = matrix;
			}
			*/
			
			
		}
		
	}
}
