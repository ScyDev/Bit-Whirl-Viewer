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

	import flash.net.navigateToURL;
	import fl.events.ListEvent;
	import flash.events.*;
	import fl.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	
	import fl.events.ComponentEvent;
	import fl.controls.TextInput;
	import com.yahoo.astra.fl.controls.Tree;
	import com.yahoo.astra.fl.controls.treeClasses.*;  

	public class ObjectContents extends GlobalStage
	{
		public var contentsDialog;
		public var contentsUrlLoader;
		public var contentsList:Tree;
		
		// dragging
		public var draggingContentsItem = null;
		public var draggingContentsItemId = null;
		public var contentsDragPic = null;
		
		public function ObjectContents()
		{
			MovieClip(ROOT).output("INIT: Obj Contents has run...", 0);
		}

		public function loadObjContents(currContentsList, objId)
		{
			//MovieClip(ROOT).output("loading contents for "+objId+" into "+currContentsList);
			contentsList = currContentsList;
			
			if (MovieClip(ROOT).host != null)
			{
				contentsUrlLoader = new URLLoader(new URLRequest("https://"+MovieClip(ROOT).host+"/app/server/object_contents.jsp?objId="+objId));
			}
			else
			{
				contentsUrlLoader = new URLLoader(new URLRequest("../server/object_contents.jsp?objId="+objId));
			}
			
			contentsUrlLoader.addEventListener(Event.COMPLETE, onObjContentsLoaded);
		}
		
		
		public function onObjContentsLoaded(event:Event)
		{
			//MovieClip(ROOT).output("contents loaded:"+contentsUrlLoader.data);
			var myTreeDataProvider = new XML(contentsUrlLoader.data); 
			
			myTreeDataProvider.ignoreWhite = true;
			
			contentsList.dataProvider = new TreeDataProvider( myTreeDataProvider ); 
		
			contentsList.openAllNodes();
			contentsList.allowMultipleSelection = true;
			
			contentsList.addEventListener(ListEvent.ITEM_ROLL_OVER, rollOverItem);
			contentsList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleContentsDoubleClick);  
			contentsList.addEventListener(ListEvent.ITEM_CLICK, handleContentsClick);  
			contentsList.addEventListener(MouseEvent.MOUSE_DOWN, onPressContentsItem);
			contentsList.addEventListener(MouseEvent.MOUSE_MOVE, onMoveContentsItem);
			contentsList.addEventListener(KeyboardEvent.KEY_UP, MovieClip(ROOT).guiEvents.someKeyUp);
			
			Key.initialize(contentsList);
		}
		
		function rollOverItem (evt:ListEvent) 
		{
			// Get the cell renderer for the item we just rolled over
			var cr:TreeCellRenderer = contentsList.itemToCellRenderer(evt.item) as TreeCellRenderer;
			cr.width = 600;
			cr.textField.width = 600;
			//cr.setSize(600, 30);
		}
		
		// change event handler
		public function handleContentsClick(eventObject:ListEvent)
		{
			// the selected node
			var theSelectedNode = eventObject.item;
				   
			// the label of the selected node
			var theSelectedNodeLabel = theSelectedNode.label;
			var theSelectedNodeType = theSelectedNode.type;
			var theSelectedNodeId = theSelectedNode.id;      
					
			setContentsContextMenu(theSelectedNode);
		
			GuiFuncs.deleteFocusObjectId = theSelectedNodeId;
			GuiFuncs.deleteFocusObjectName = theSelectedNodeLabel;
			GuiFuncs.deleteFocusPlace = GuiFuncs.SELECTION_FOCUS_CONTENTS;
			
		}
		
		
		public function handleContentsDoubleClick(eventObject:ListEvent)
		{
			// the selected node
			var theSelectedNode = eventObject.item;
				   
			// the label of the selected node
			var theSelectedNodeLabel = theSelectedNode.label;
			var theSelectedNodeType = theSelectedNode.type;
			var theSelectedNodeId = theSelectedNode.id;
			
			if (theSelectedNodeType == "script")
			{
				navigateToURL(new URLRequest("../client/edit_script.jsp?load_script_id="+theSelectedNodeId), "_blank");
			}
			else if (theSelectedNodeType == "text")
			{
				navigateToURL(new URLRequest("../client/edit_text.jsp?load_text_id="+theSelectedNodeId), "_blank");
			}
			
		}
		
		
		public function onPressContentsItem(event:Event)
		{
			//MovieClip(ROOT).output("press on "+event.target.data.label);
			if (contentsDragPic == null)
			{
				if (event.target instanceof TreeCellRenderer)
				{
					GuiFuncs.deleteFocusObjectId = event.target.data.id;
					GuiFuncs.deleteFocusObjectName = event.target.data.label;
					GuiFuncs.deleteFocusPlace = GuiFuncs.SELECTION_FOCUS_CONTENTS;
					
					if (event.target.selected != true && !Key.isDown(Keyboard.SHIFT) && !Key.isDown(Keyboard.CONTROL))
					{
						contentsList.selectedIndices = [];
						event.target.selected == true;
					}
					contentsDragPic = null;
					
					draggingContentsItem = event.target;
					draggingContentsItemId = event.target.data.id;
				}
			}
			else
			{
				clearContentsDrag();
			}
			
		}
		
		
		public function onMoveContentsItem(event:Event)
		{
			if (draggingContentsItem != null)
			{
				if (contentsDragPic == null)
				{
					var dragBitmapData = new BitmapData(200, 200, true, 0x00FFFFFF);
					dragBitmapData.draw(draggingContentsItem);
					var dragPicBitmap = new Bitmap(dragBitmapData);
					
					contentsDragPic = new Sprite();
					contentsDragPic.addChild(dragPicBitmap);
					
					var globalPoint = contentsList.localToGlobal(new Point(contentsList.mouseX, contentsList.mouseY));
					contentsDragPic.x = globalPoint.x+5;
					contentsDragPic.y = globalPoint.y+5;
					Stage(STAGE).addChild(contentsDragPic);
					
					function onReleaseContentsDrag(event)
					{
						Stage(STAGE).removeChild(contentsDragPic);
					}
					contentsDragPic.addEventListener(MouseEvent.MOUSE_DOWN, onReleaseContentsDrag);
					
					//Sprite(draggingTreeItem).startDrag();
					contentsDragPic.startDrag();
				}
			}
		}
		
		public function clearContentsDrag()
		{
			draggingContentsItem = null;
			draggingContentsItemId = null;
			
			if (contentsDragPic != null && Stage(STAGE).contains(contentsDragPic))
			{
				Stage(STAGE).removeChild(contentsDragPic);
			}
			contentsDragPic = null;
		}
		
		
		public function setContentsOnReleaseEvent()
		{
			function onReleaseContentsItem(event:Event)
			{
				if (MovieClip(ROOT).treeActions.draggingTreeItem != null && MovieClip(ROOT).treeActions.treeDragPic != null)
				{
					var drag_list = GuiFuncs.getSelectedListFromTree(MovieClip(ROOT).inventory_tree, MovieClip(ROOT).treeActions.draggingTreeItemId);
		
					//MovieClip(ROOT).output("put into contents "+draggingTreeItem+" "+draggingTreeItemId+" "+contentsDialog.object_id.text);
					MovieClip(ROOT).editFunctions.edit_moveInventoryToObjContents(drag_list, contentsDialog.object_id.text);
				}
				MovieClip(ROOT).treeActions.clearTreeDrag();
				
				if (draggingContentsItem != null && contentsDragPic != null)
				{
					
				}
				clearContentsDrag();
				
			}
			contentsList.addEventListener(MouseEvent.MOUSE_UP, onReleaseContentsItem);
		}
		
		
		// functions on each tree folder
		public function setContentsContextMenu(theSelectedItem)
		{
				//MovieClip(ROOT).output("adding context menu to "+theSelectedFolder);
				var myContextMenu:ContextMenu = new ContextMenu(); 
				myContextMenu.hideBuiltInItems();
				
				/*
				if (theSelectedItem.type == "folder")
				{
					var itemNew:ContextMenuItem = new ContextMenuItem(".:. New Folder");
					itemNew.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
					myContextMenu.customItems.push(itemNew);
				}
				else if (theSelectedItem.type == "object")
				{
					var itemHud:ContextMenuItem = new ContextMenuItem(".:. Wear on HUD");
					itemHud.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
					myContextMenu.customItems.push(itemHud);
		
					var itemAvatar:ContextMenuItem = new ContextMenuItem(".:. Set as Avatar");
					itemAvatar.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
					myContextMenu.customItems.push(itemAvatar);
				}
				*/
				
				var itemRename:ContextMenuItem = new ContextMenuItem(".:. Rename");
				itemRename.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
				myContextMenu.customItems.push(itemRename);
				
				function onTreeItemClicked(event:ContextMenuEvent):void  
				{  
					//MovieClip(ROOT).MovieClip(ROOT).output("You chose " + event.target.caption);  
					
					if (event.target.caption == ".:. Rename")
					{
						MovieClip(ROOT).guiEvents.rename_mode = 1;
						contentsList.selectable = false;
						
						var newName:TextInput = new TextInput();
						newName.name = "newName";

						var labelText = MovieClip(ROOT).trimFront(theSelectedItem.label);
						newName.x = TreeCellRenderer(event.mouseTarget).x;
						newName.y = TreeCellRenderer(event.mouseTarget).y;
						newName.width = contentsList.width-20;
						newName.appendText(labelText);
						newName.addEventListener(ComponentEvent.ENTER, enterPressed); 
						contentsList.addChild(newName);
						newName.setFocus();
						
						function enterPressed(event:ComponentEvent)
						{
							MovieClip(ROOT).guiEvents.rename_mode = 0;
							contentsList.selectable = true;
							
							//MovieClip(ROOT).output(event.target.text);
							contentsList.removeChild(newName);
							MovieClip(ROOT).editFunctions.edit_renameInventory(theSelectedItem.id, event.target.text);
						}
						
						function escPressed(event:KeyboardEvent)
						{
							if (event.keyCode == Keyboard.ESCAPE)
							{
								MovieClip(ROOT).guiEvents.rename_mode = 0;
								contentsList.selectable = true;
								contentsList.removeChild(newName);
							}
						}
						newName.addEventListener(KeyboardEvent.KEY_DOWN, escPressed);
						
					}
			
				}  
			
				contentsList.contextMenu = myContextMenu;
		
		
		}

	}
}
