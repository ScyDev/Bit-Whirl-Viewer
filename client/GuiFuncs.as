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
	import InfilionMovieClip;
	import flash.display.MovieClip;	
	import flash.display.DisplayObject;
	import flash.display.Stage;
    import flash.events.Event;		
	import flash.events.MouseEvent;	
	import flash.text.TextField;
	import flash.display.LineScaleMode;
	
	public class GuiFuncs extends GlobalStage
	{
		// GUI Functions
		
		public static var currSelectedClip:InfilionMovieClip;
		public static var currSelectionClip:MovieClip; // this be the green overlay!!!
		public static var currSelectedInventoryObjId;
		
		public static var currViewportFollowingClip;
		
		public static var deleteFocusObjectId; // also used now for perms dialog, not only delete anymore
		public static var deleteFocusObjectName;
		public static var deleteFocusPlace;
		public static var SELECTION_FOCUS_INVENTORY = 2; // these must correspond to TARGET_DATABASE_XXX in InventoryHandler.java
		public static var SELECTION_FOCUS_MAP = 1;
		public static var SELECTION_FOCUS_CONTENTS = 3;
		
		public static var clearHandleAfterClick = 1;
		
		public static function clearDeleteFocus()
		{
			GuiFuncs.deleteFocusObjectId = null;
			GuiFuncs.deleteFocusObjectName = null;
			GuiFuncs.deleteFocusPlace = null;
		}
		
		public static function setDeleteFocus(new_deleteFocusObjectId, new_deleteFocusObjectName, new_deleteFocusPlace)
		{
			GuiFuncs.deleteFocusObjectId = new_deleteFocusObjectId;
			GuiFuncs.deleteFocusObjectName = new_deleteFocusObjectName;
			GuiFuncs.deleteFocusPlace = new_deleteFocusPlace;
		}
		
		
		public static function clearEditHandles()
		{
			clearDeleteFocus();
			clearObjProps(currSelectedClip);
			
			if (GuiFuncs.currSelectedClip != null && GuiFuncs.currSelectedClip.parent != null 
				&& GuiFuncs.currSelectedClip.parent.getChildByName("selection") != null)
			{
				//MovieClip(currSelectedClip.root).output("clearing "+GuiFuncs.currSelectedClip.inflObjId);
				var selectionChild = GuiFuncs.currSelectedClip.parent.getChildByName("selection");
				//selectionChild.graphics.clear();
				selectionChild.handleLR.parent.removeChild(selectionChild.handleLR);
				selectionChild.parent.removeChild(selectionChild);

			}
			
			GuiFuncs.currSelectedClip = null;
		}
			
		public static function drawEditHandles(targetClip:InfilionMovieClip)
		{
			if (targetClip != GuiFuncs.currSelectedClip)
			{
			}
				clearEditHandles();
				clearHandleAfterClick = 1;
			
				//MovieClip(targetClip.root).output(targetClip);
				GuiFuncs.currSelectedClip = targetClip;
				
				var selectionClip = new MovieClip();
				selectionClip.name = "selection";
				GuiFuncs.currSelectionClip = selectionClip;

				var border = 0;
				var handleSize = 10;
				
				selectionClip.graphics.lineStyle(2, 0x00FF00, 1.0, true, LineScaleMode.NONE);
				selectionClip.graphics.beginFill(0x00FF00, 0.1);
				selectionClip.graphics.moveTo(0+border, 0+border);
				//selectionClip.graphics.drawRect(0+border, 0+border, (targetClip.width)-(2*border), (targetClip.height)-(2*border));
				selectionClip.graphics.drawRect(0+border, 0+border, (targetClip.desiredWidth)-(2*border), (targetClip.desiredHeight)-(2*border));

				selectionClip.origX = GuiFuncs.currSelectedClip.x;
				selectionClip.origY = GuiFuncs.currSelectedClip.y;
				selectionClip.myTargetClip = GuiFuncs.currSelectedClip;
				selectionClip.pressed = 0;
				selectionClip.dragging = 0;
			
				function onClickSelection(event:Event)
				{
					if (clearHandleAfterClick == 1)
					{
						GuiFuncs.clearEditHandles();
					}
					clearHandleAfterClick = 1;
				}
				selectionClip.addEventListener(MouseEvent.CLICK, onClickSelection);
			
				function onPressSelection(event:Event)
				{
					setDeleteFocus(selectionClip.myTargetClip.inflObjId, selectionClip.myTargetClip.inflObjName, GuiFuncs.SELECTION_FOCUS_MAP);
					
					selectionClip.pressed = 1;
				}
				selectionClip.addEventListener(MouseEvent.MOUSE_DOWN, onPressSelection);
					
				function onMoveSelection(event:Event)
				{
					
					
					if (selectionClip.pressed == 1)
					{
						clearHandleAfterClick = 0;
						
						//MovieClip(currSelectedClip.root).output("MOVED!", 0);
						selectionClip.dragging = 1;
						selectionClip.startDrag();
						
						selectionClip.pressed = 0;
					}
					if (selectionClip.dragging == 1)
					{
						selectionClip.handleLR.x = selectionClip.x+selectionClip.width;
						selectionClip.handleLR.y = selectionClip.y+selectionClip.height;
						
						GuiFuncs.currSelectedClip.x = selectionClip.x;
						GuiFuncs.currSelectedClip.y = selectionClip.y;
					}
				}
				selectionClip.addEventListener(MouseEvent.MOUSE_MOVE, onMoveSelection);
				
				function onReleaseSelection(event:Event)
				{
					// release resize handle, just in case mousepointer is no longer over it
					if (GuiFuncs.currSelectionClip != null)
					{
						GuiFuncs.currSelectionClip.handleLR.releaseHandle(event);
					}
					
					selectionClip.pressed = 0;
					
					if (selectionClip.dragging == 1)
					{
						selectionClip.dragging = 0;
						
						selectionClip.stopDrag();
						// selectionClip._x and _y seem to be relative to starting pos here... so, add it to objects orig pos
						MovieClip(selectionClip.parent.root).editFunctions.edit_relocateObject(GuiFuncs.currSelectedClip.inflObjId, selectionClip.x, selectionClip.y);
					}
				}
				selectionClip.addEventListener(MouseEvent.MOUSE_UP, onReleaseSelection);
			
				selectionClip.x = GuiFuncs.currSelectedClip.x;
				selectionClip.y = GuiFuncs.currSelectedClip.y;
				targetClip.parent.addChild(selectionClip);
				//targetClip.addChild(selectionClip);
				
				selectionClip.contextMenu = GuiFuncs.currSelectedClip.myContextMenu;
				
			//////////////  HANDLES ///////////////
				var handleLR = new MovieClip();
				handleLR.name = "handleLR";
				handleLR.graphics.beginFill(0x00FF00, 1.0);
				handleLR.graphics.drawRect(0, 0, handleSize, handleSize);
				handleLR.x = targetClip.x+targetClip.desiredWidth;
				handleLR.y = targetClip.y+targetClip.desiredHeight;
				handleLR.pressed = 0;
				
				function pressHandle(event:Event)
				{
					var currMouseX = MovieClip(GuiFuncs.currSelectedClip.root).viewport.content.mouseX;
					var currMouseY = MovieClip(GuiFuncs.currSelectedClip.root).viewport.content.mouseY;
					
					GuiFuncs.currSelectedClip.scaleAnchorX = currMouseX;
					GuiFuncs.currSelectedClip.scaleAnchorY = currMouseY;
					
					handleLR.pressed = 1;
					handleLR.startDrag();
					
					//event.target.parent.startResizePos
				}
				handleLR.addEventListener(MouseEvent.MOUSE_DOWN, pressHandle);
				
				function dragHandle(event:Event)
				{
					if (handleLR.pressed == 1)
					{
						var currMouseX = MovieClip(GuiFuncs.currSelectedClip.root).viewport.content.mouseX;
						if (currMouseX < GuiFuncs.currSelectedClip.x+(GuiFuncs.currSelectedClip.width/2)+10)
							currMouseX = GuiFuncs.currSelectedClip.x+(GuiFuncs.currSelectedClip.width/2)+10;
						var currMouseY = MovieClip(GuiFuncs.currSelectedClip.root).viewport.content.mouseY;
						if (currMouseY < GuiFuncs.currSelectedClip.y+(GuiFuncs.currSelectedClip.height/2)+10)
							currMouseY = GuiFuncs.currSelectedClip.y+(GuiFuncs.currSelectedClip.height/2)+10;
						
						var scaleDeltaX = Math.ceil(currMouseX - GuiFuncs.currSelectedClip.scaleAnchorX)*2; // *2 cause below we move it by delta/2, to make center oriented
						var scaleDeltaY = Math.ceil(currMouseY - GuiFuncs.currSelectedClip.scaleAnchorY)*2;
	
						selectionClip.x = GuiFuncs.currSelectedClip.x-(scaleDeltaX/2);
						selectionClip.y = GuiFuncs.currSelectedClip.y-(scaleDeltaY/2);
						
						MovieClip(GuiFuncs.currSelectedClip.root).output("desired "+GuiFuncs.currSelectedClip.desiredWidth+"/"+GuiFuncs.currSelectedClip.desiredHeight+"  actual "+GuiFuncs.currSelectedClip.width+"/"+GuiFuncs.currSelectedClip.height, 0);
						selectionClip.width = GuiFuncs.currSelectedClip.desiredWidth+scaleDeltaX;
						selectionClip.height = GuiFuncs.currSelectedClip.desiredHeight+scaleDeltaY;
					}
				}

				handleLR.addEventListener(MouseEvent.MOUSE_MOVE, dragHandle);
				
				function releaseHandle(event:Event)
				{
					//MovieClip(currSelectedClip.root).output("handle release!", 0);
					if (handleLR.pressed == 1)
					{
						handleLR.pressed = 0;
						handleLR.stopDrag();
	
						var currMouseX = MovieClip(GuiFuncs.currSelectedClip.root).viewport.content.mouseX;
						if (currMouseX < GuiFuncs.currSelectedClip.x+(GuiFuncs.currSelectedClip.width/2)+10)
							currMouseX = GuiFuncs.currSelectedClip.x+(GuiFuncs.currSelectedClip.width/2)+10;
						var currMouseY = MovieClip(GuiFuncs.currSelectedClip.root).viewport.content.mouseY;
						if (currMouseY < GuiFuncs.currSelectedClip.y+(GuiFuncs.currSelectedClip.height/2)+10)
							currMouseY = GuiFuncs.currSelectedClip.y+(GuiFuncs.currSelectedClip.height/2)+10;
						
						var scaleDeltaX = Math.round(currMouseX - GuiFuncs.currSelectedClip.scaleAnchorX)*2; // *2 cause below we move it by delta/2, to make center oriented (see dragHandle)
						var scaleDeltaY = Math.round(currMouseY - GuiFuncs.currSelectedClip.scaleAnchorY)*2;

						selectionClip.width = GuiFuncs.currSelectedClip.desiredWidth+scaleDeltaX;
						selectionClip.height = GuiFuncs.currSelectedClip.desiredHeight+scaleDeltaY;

						selectionClip.handleLR.x = selectionClip.x+selectionClip.width;
						selectionClip.handleLR.y = selectionClip.y+selectionClip.height;
						
						MovieClip(GuiFuncs.currSelectedClip.root).editFunctions.edit_resizeObject(GuiFuncs.currSelectedClip.inflObjId, GuiFuncs.currSelectedClip.desiredWidth+scaleDeltaX, GuiFuncs.currSelectedClip.desiredHeight+scaleDeltaY);
					}
				}
				handleLR.releaseHandle = releaseHandle;
				handleLR.addEventListener(MouseEvent.MOUSE_UP, releaseHandle);
				
				selectionClip.handleLR = handleLR;
				GuiFuncs.currSelectedClip.parent.addChild(handleLR);
		
				updateObjProps(GuiFuncs.currSelectedClip);
		}
		
		public static function clearObjProps(concernedObject:InfilionMovieClip)
		{
			if (concernedObject != null)
			{
			MovieClip(concernedObject.root).obj_props.props_obj_id.text = "";
			MovieClip(concernedObject.root).obj_props.props_obj_name.text = "";
			MovieClip(concernedObject.root).obj_props.props_obj_rotZ.text = "";
			MovieClip(concernedObject.root).obj_props.props_obj_x.text = "";
			MovieClip(concernedObject.root).obj_props.props_obj_y.text = "";
			MovieClip(concernedObject.root).obj_props.props_obj_z.text = "";
			MovieClip(concernedObject.root).obj_props.props_obj_sell.selected = false;
			MovieClip(concernedObject.root).obj_props.props_obj_price.text = "";
			MovieClip(concernedObject.root).obj_props.props_obj_solid.selected = false;
			MovieClip(concernedObject.root).obj_props.props_obj_owner.text = "";
			MovieClip(concernedObject.root).obj_props.props_obj_sizeX.text = "";
			MovieClip(concernedObject.root).obj_props.props_obj_sizeY.text = "";
			}
		}
		
		public static function updateObjProps(concernedObject:InfilionMovieClip)
		{
			//MovieClip(concernedObject.root).output("handle release!", 0);
			
			MovieClip(concernedObject.root).obj_props.props_obj_id.text = concernedObject.inflObjId;
			MovieClip(concernedObject.root).obj_props.props_obj_name.text = concernedObject.inflObjName;
			MovieClip(concernedObject.root).obj_props.props_obj_rotZ.text = concernedObject.rotZ;
			MovieClip(concernedObject.root).obj_props.props_obj_x.text = concernedObject.x;
			MovieClip(concernedObject.root).obj_props.props_obj_y.text = concernedObject.y;
			MovieClip(concernedObject.root).obj_props.props_obj_z.text = InfilionMovieClip(concernedObject).parent.getChildIndex(concernedObject);
			MovieClip(concernedObject.root).obj_props.props_obj_sell.selected = concernedObject.sell;
			MovieClip(concernedObject.root).obj_props.props_obj_price.text = concernedObject.price;
			MovieClip(concernedObject.root).obj_props.props_obj_solid.selected = concernedObject.solid;
			//MovieClip(concernedObject.root).obj_props.props_obj_clickThrough.selected = concernedObject.clickThrough;
			MovieClip(concernedObject.root).obj_props.props_obj_owner.text = concernedObject.inflObjOwner;
			MovieClip(concernedObject.root).obj_props.props_obj_sizeX.text = concernedObject.desiredWidth;
			MovieClip(concernedObject.root).obj_props.props_obj_sizeY.text = concernedObject.desiredHeight;

			//concernedObject.activateClickthrough(MovieClip(concernedObject.root).obj_props.props_obj_clickThrough.selected);
		}		
		
		public static function activateClickthroughForAll(map_container, hud_container, activate:Boolean)
		{
			var child_num = map_container.numChildren;
			
			for (var i = 0; i < child_num; i++)
			{
				var curr_child = map_container.getChildAt(i);
				
				if (curr_child instanceof InfilionMovieClip)
				{
					curr_child.activateClickthrough(activate);
				}
			}
		}
		
		public static function getSelectedListFromTree(target_tree, currDraggedItem)
		{
			var selectedItems:Array = target_tree.selectedIndices;
			
			var delete_list = "list(";
			
			if (selectedItems.length > 0)
			{
				
				for (var i = 0; i < selectedItems.length; i++)
				{
					var currItem = target_tree.getItemAt(selectedItems[i]);
					delete_list += currItem.id+",";
				}
			}
			if (delete_list.indexOf(currDraggedItem) < 0)
			{
				delete_list += currDraggedItem;
			}
			delete_list += ")"
			
			return delete_list;
		}
	
	}
}
