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
	import flash.display.*;
	import flash.display.Stage;
	import flash.events.*;
	import fl.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.text.*;
	import flash.geom.*;
	
	import fl.events.ListEvent;
	import fl.events.ComponentEvent;
	import fl.controls.TextInput;
	import com.yahoo.astra.fl.controls.Tree;
	import com.yahoo.astra.fl.controls.treeClasses.*;  
	
	public class TreeActions extends GlobalStage
	{
		public var myTree = MovieClip(ROOT).inventory_tree;
		public var inventoryUrlLoader;

		// dragging
		public var draggingTreeItem = null;
		public var draggingTreeItemId = null;
		public var treeDragPic = null;
		
		public var scrollIncrement = 0;
		
		public var tree_copy_paste_list = "";
		public var copy_on_paste = false;

		
		public function TreeActions()
		{
			myTree.addEventListener(ListEvent.ITEM_ROLL_OVER, rollOverItem);
			myTree.addEventListener(Event.COMPLETE, onInventoryXmlLoad); 
			myTree.addEventListener(ListEvent.ITEM_CLICK, handleTreeClick);  
			myTree.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleTreeDoubleClick);  
			myTree.addEventListener(MouseEvent.MOUSE_DOWN, onPressTreeItem);
			myTree.addEventListener(MouseEvent.MOUSE_MOVE, onMoveTreeItem);
			Stage(STAGE).addEventListener(MouseEvent.MOUSE_MOVE, detectTreeScroll);
			myTree.addEventListener(Event.ENTER_FRAME, doScrollTree);
			myTree.addEventListener(MouseEvent.MOUSE_UP, onReleaseTreeItem);
	
			MovieClip(ROOT).output("INIT: Tree Actions has run...", 0);		
		}
		
		
		function loadInventoryTree()
		{
			myTree.setRendererStyle("width", 600);
			if (MovieClip(ROOT).host != null)
			{
				inventoryUrlLoader = new URLLoader(new URLRequest("https://"+MovieClip(ROOT).host+"/app/server/inventory_tree.jsp"));
			}
			else
			{
				inventoryUrlLoader = new URLLoader(new URLRequest("../server/inventory_tree.jsp"));
			}
			inventoryUrlLoader.addEventListener(Event.COMPLETE, onInventoryLoaded);
		}
		
		
		function onInventoryLoaded(event:Event)
		{
			var myTreeDataProvider = new XML(inventoryUrlLoader.data); 
			
			myTreeDataProvider.ignoreWhite = true;
			
			myTree.dataProvider = new TreeDataProvider( myTreeDataProvider ); 
			
			var nodeToOpen = myTree.findNode("type", "folder_open");
			while (nodeToOpen != null)
			{
				nodeToOpen.openNode();
				nodeToOpen.type = "folder";
				//MovieClip(ROOT).output("opened:"+nodeToOpen.id);
				
				nodeToOpen = myTree.findNode("type", "folder_open");
			}
			myTree.allowMultipleSelection = true;
			
			//myTree.openAllNodes();
			
			/*
			var treeItemIndex = 0;
			var nodeToResize = myTree.getItemAt(treeItemIndex);
		
			while (nodeToResize != null)
			{
				MovieClip(ROOT).output(nodeToResize, 0);
				var theRenderer = myTree.itemToCellRenderer(nodeToResize) as TreeCellRenderer;
				if (theRenderer != null)
				{
					MovieClip(ROOT).output(theRenderer, 0);
				theRenderer.setSize(600,  30);
				theRenderer.width = 600;
				
				}
				treeItemIndex++;
				nodeToResize = myTree.getItemAt(treeItemIndex);
			}
			*/
		}
		
		
		function rollOverItem (evt:ListEvent) 
		{
			// Get the cell renderer for the item we just rolled over
			var cr:TreeCellRenderer = myTree.itemToCellRenderer(evt.item) as TreeCellRenderer;
			cr.width = 600;
			cr.textField.width = 600;
			//cr.setSize(600, 30);
			
			setInventoryContextMenu(evt.item); // for some reason, a loop onLoadCompleted doesn't work.. so we do it here
		}
		
			
		// onLoad handler for XML data
		function onInventoryXmlLoad(event:Event)
		{ 
		   
		}
		
		// change event handler
		function handleTreeClick(eventObject:ListEvent)
		{
			
			// the selected node
			var theSelectedNode = eventObject.item;
				   
			// the label of the selected node
			var theSelectedNodeLabel = theSelectedNode.label;
			var theSelectedNodeType = theSelectedNode.type;
			var theSelectedNodeId = theSelectedNode.id;    
			
			MovieClip(ROOT).output("Tree selected: "+theSelectedNodeId, 0);
			
			// add a status message to the status message text area component
			//MovieClip(ROOT).output(theSelectedNodeLabel);
			
			if (theSelectedNodeType == "object")
			{
				//MovieClip(ROOT).output("curr selected inv obj: "+theSelectedNodeId);
				GuiFuncs.currSelectedInventoryObjId = theSelectedNodeId;
			}
				
			if (theSelectedNode instanceof BranchNode)
			{
				myTree.toggleNode(theSelectedNode); // negate automatic toggle on single-click, cause we only wants it on double-click
			}
				
			//setInventoryContextMenu(theSelectedNode);
		
			GuiFuncs.currSelectedInventoryObjId = theSelectedNodeId;
			
			
		}
		// add the event listeners
		
		function handleTreeDoubleClick(eventObject:ListEvent)
		{
			// the selected node
			var theSelectedNode = eventObject.item;
				   
			// the label of the selected node
			var theSelectedNodeLabel = theSelectedNode.label;
			var theSelectedNodeType = theSelectedNode.type;
			var theSelectedNodeId = theSelectedNode.id;    
			
			//var targetedItemId = TreeCellRenderer(eventObject.mouseTarget).data.id
			
			if (theSelectedNode instanceof BranchNode)
			{
				MovieClip(ROOT).editFunctions.edit_toggleInventoryFolder(theSelectedNodeId);
			}
			else if (theSelectedNodeType == "script")
			{
				navigateToURL(new URLRequest("../client/edit_script.jsp?load_script_id="+theSelectedNodeId), "_blank");
			}
			else if (theSelectedNodeType == "text")
			{
				navigateToURL(new URLRequest("../client/edit_text.jsp?load_text_id="+theSelectedNodeId), "_blank");
			}
			else if (theSelectedNodeType == "landmark")
			{
				MovieClip(ROOT).playFunctions.play_teleportToLandmark(theSelectedNodeId);
			}
			
		}
		
		
		function onPressTreeItem(event:Event)
		{
		
			//MovieClip(ROOT).output("press on "+event.target.data.label);
			if (treeDragPic == null)
			{
				if (event.target instanceof TreeCellRenderer)
				{
					GuiFuncs.deleteFocusObjectId = event.target.data.id;
					GuiFuncs.deleteFocusObjectName = event.target.data.label;
					GuiFuncs.deleteFocusPlace = GuiFuncs.SELECTION_FOCUS_INVENTORY;
				
					if (event.target.selected != true && !Key.isDown(Keyboard.SHIFT) && !Key.isDown(Keyboard.CONTROL))
					{
						myTree.selectedIndices = [];
						event.target.selected == true;
					}
					treeDragPic = null;
					
					draggingTreeItem = event.target;
					draggingTreeItemId = event.target.data.id;
				}
			}
			else
			{
				clearTreeDrag();
			}
			
		}
		
		function onMoveTreeItem(event:Event)
		{
			if (draggingTreeItem != null)
			{
				if (treeDragPic == null)
				{
					var dragBitmapData = new BitmapData(200, 200, true, 0x00FFFFFF);
					dragBitmapData.draw(draggingTreeItem);
					var dragPicBitmap = new Bitmap(dragBitmapData);
					
					treeDragPic = new Sprite();
					treeDragPic.addChild(dragPicBitmap);
					
					var globalPoint = myTree.localToGlobal(new Point(myTree.mouseX, myTree.mouseY));
					treeDragPic.x = globalPoint.x+5;
					treeDragPic.y = globalPoint.y+5;
					Stage(STAGE).addChild(treeDragPic);
					
					function onReleaseTreeDrag(event)
					{
						Stage(STAGE).removeChild(treeDragPic);
					}
					treeDragPic.addEventListener(MouseEvent.MOUSE_DOWN, onReleaseTreeDrag);
					
					//Sprite(draggingTreeItem).startDrag();
					treeDragPic.startDrag();
				}
			}
		}
		
		function detectTreeScroll(event:Event)
		{
			// scrolling while dragging
			if (draggingTreeItem != null || MovieClip(ROOT).objectContents.draggingContentsItem != null)
			{
				var treeMousePos = new Point(Stage(STAGE).mouseX, Stage(STAGE).mouseY);
				treeMousePos = myTree.globalToLocal(treeMousePos);
		
				scrollIncrement = 0;
				var borderToNoticeExitingMouse = 5;
				
				if (treeMousePos.x > 10 && treeMousePos.x < myTree.width-borderToNoticeExitingMouse 
					&& treeMousePos.y > borderToNoticeExitingMouse && treeMousePos.y < myTree.height-borderToNoticeExitingMouse)
				{
					
					// up
					if (treeMousePos.y < 20)
					{
						scrollIncrement = -10;
					}
					else if (treeMousePos.y < 40)
					{
						scrollIncrement = -5;
					}
					else if (treeMousePos.y < 60)
					{
						scrollIncrement = -2;
					}
					// down
					else if (treeMousePos.y > myTree.height-20)
					{
						scrollIncrement = 10;
					}
					else if (treeMousePos.y > myTree.height-40)
					{
						scrollIncrement = 5;
					}
					else if (treeMousePos.y > myTree.height-60)
					{
						scrollIncrement = 2;
					}
				}
			}
		}
		
		function doScrollTree(event)
		{
			if (scrollIncrement != 0)
			{
				myTree.verticalScrollPosition += scrollIncrement;
			}
		}
		
		function clearTreeDrag()
		{
			draggingTreeItem = null;
			draggingTreeItemId = null;
			
			if (treeDragPic != null && Stage(STAGE).contains(treeDragPic))
			{
				Stage(STAGE).removeChild(treeDragPic);
			}
			treeDragPic = null;
		}
		
		function onReleaseTreeItem(event:Event)
		{
			scrollIncrement = 0;
			
			if (draggingTreeItem != null && treeDragPic != null)
			{
				var treeDropTarget = null;
				if (treeDragPic.dropTarget instanceof TextField && treeDragPic.dropTarget.parent instanceof TreeCellRenderer)
				{
					treeDropTarget = treeDragPic.dropTarget.parent;
				}
				else if (treeDragPic.dropTarget instanceof Shape && treeDragPic.dropTarget.parent.parent instanceof TreeCellRenderer)
				{
					treeDropTarget = treeDragPic.dropTarget.parent.parent;
				}
				
				if (treeDropTarget != null)
				{
					if (treeDropTarget.data.id != draggingTreeItem.data.id)
					{
						MovieClip(ROOT).output(treeDropTarget.data.id+" "+draggingTreeItem.data.id, 0);
						var drag_list = GuiFuncs.getSelectedListFromTree(MovieClip(ROOT).inventory_tree, draggingTreeItemId);
						
						MovieClip(ROOT).editFunctions.edit_moveInventoryToFolder(drag_list, treeDropTarget.data.id, false);
					}
					
				}
			}
			clearTreeDrag();
			
			if (MovieClip(ROOT).objectContents.draggingContentsItem != null && MovieClip(ROOT).objectContents.contentsDragPic != null)
			{
				var treeDropTarget = null;
				if (MovieClip(ROOT).objectContents.contentsDragPic.dropTarget instanceof TextField && MovieClip(ROOT).objectContents.contentsDragPic.dropTarget.parent instanceof TreeCellRenderer)
				{
					treeDropTarget = MovieClip(ROOT).objectContents.contentsDragPic.dropTarget.parent;
				}
				else if (MovieClip(ROOT).objectContents.contentsDragPic.dropTarget instanceof Shape && MovieClip(ROOT).objectContents.contentsDragPic.dropTarget.parent.parent instanceof TreeCellRenderer)
				{
					treeDropTarget = MovieClip(ROOT).objectContents.contentsDragPic.dropTarget.parent.parent;
				}
				
				if (treeDropTarget != null)
				{
					if (treeDropTarget.data.id != MovieClip(ROOT).objectContents.draggingContentsItem.data.id)
					{
						var drag_list = GuiFuncs.getSelectedListFromTree(MovieClip(ROOT).objectContents.contentsList, MovieClip(ROOT).objectContents.draggingContentsItemId);
						
						MovieClip(ROOT).output(treeDropTarget.data.id+" "+MovieClip(ROOT).objectContents.draggingContentsItem.data.id, 0);
						MovieClip(ROOT).editFunctions.edit_moveInventoryToFolder(drag_list, treeDropTarget.data.id, true);
					}
					
				}
			}
			MovieClip(ROOT).objectContents.clearContentsDrag();
		}
		
		// functions on each tree folder
		function setInventoryContextMenu(theSelectedItem)
		{
				//MovieClip(ROOT).output("adding context menu to "+theSelectedFolder);
				var myContextMenu:ContextMenu = new ContextMenu(); 
				myContextMenu.hideBuiltInItems();
				
				if (theSelectedItem.type == "folder")
				{
					var itemNew:ContextMenuItem = new ContextMenuItem(".:. New Folder");
					itemNew.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
					myContextMenu.customItems.push(itemNew);
		
					var itemPaste:ContextMenuItem = new ContextMenuItem(".:. Paste");
					itemPaste.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
					myContextMenu.customItems.push(itemPaste);
		
					var itemNewLandmark:ContextMenuItem = new ContextMenuItem(".:. New Landmark");
					itemNewLandmark.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
					itemNewLandmark.separatorBefore = true;
					myContextMenu.customItems.push(itemNewLandmark);
		
					var itemNewText:ContextMenuItem = new ContextMenuItem(".:. New Text");
					itemNewText.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
					itemNewText.separatorBefore = true;
					myContextMenu.customItems.push(itemNewText);
		
					var itemNewScript:ContextMenuItem = new ContextMenuItem(".:. New Script");
					itemNewScript.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
					itemNewScript.separatorBefore = true;
					myContextMenu.customItems.push(itemNewScript);
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
				else if (theSelectedItem.type == "image")
				{
					var itemPutImg:ContextMenuItem = new ContextMenuItem(".:. Put on Object");
					itemPutImg.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
					myContextMenu.customItems.push(itemPutImg);
				}
				
				var itemRename:ContextMenuItem = new ContextMenuItem(".:. Rename");
				itemRename.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
				myContextMenu.customItems.push(itemRename);
				
				var itemCut:ContextMenuItem = new ContextMenuItem(".:. Cut");
				itemCut.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
				myContextMenu.customItems.push(itemCut);
		
				var itemCopy:ContextMenuItem = new ContextMenuItem(".:. Copy");
				itemCopy.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTreeItemClicked);
				myContextMenu.customItems.push(itemCopy);
				
				function onTreeItemClicked(event:ContextMenuEvent):void  
				{  
					var targetedItemId = TreeCellRenderer(event.mouseTarget).data.id
					//MovieClip(ROOT).output("You chose " + TreeCellRenderer(event.mouseTarget).data.id);  
					
					if (event.target.caption == ".:. New Folder")
					{
						MovieClip(ROOT).editFunctions.edit_newInvFolder(targetedItemId);
					}
					else if (event.target.caption == ".:. New Landmark")
					{
						MovieClip(ROOT).playFunctions.play_createLandmark(targetedItemId);
					}
					else if (event.target.caption == ".:. New Text")
					{
						MovieClip(ROOT).editFunctions.edit_newText(targetedItemId);
					}
					else if (event.target.caption == ".:. New Script")
					{
						MovieClip(ROOT).editFunctions.edit_newScript(targetedItemId);
					}
					else if (event.target.caption == ".:. Wear on HUD")
					{
						MovieClip(ROOT).editFunctions.edit_wearOnHud(targetedItemId);
					}
					else if (event.target.caption == ".:. Set as Avatar")
					{
						MovieClip(ROOT).editFunctions.edit_setAsAvatar(targetedItemId);
					}
					else if (event.target.caption == ".:. Put on Object")
					{
						if (GuiFuncs.currSelectedClip != null)
						{
							MovieClip(ROOT).editFunctions.edit_assignImage(GuiFuncs.currSelectedClip.inflObjId, targetedItemId);
						}
					}
					else if (event.target.caption == ".:. Copy")
					{
						tree_copy_paste_list = GuiFuncs.getSelectedListFromTree(MovieClip(ROOT).inventory_tree, "");
						//MovieClip(ROOT).output("copy: "+tree_copy_paste_list);
						copy_on_paste = true;
					}
					else if (event.target.caption == ".:. Cut")
					{
						tree_copy_paste_list = GuiFuncs.getSelectedListFromTree(MovieClip(ROOT).inventory_tree, "");
						//MovieClip(ROOT).output("cut: "+tree_copy_paste_list);
						copy_on_paste = false;
					}
					else if (event.target.caption == ".:. Paste")
					{
						//MovieClip(ROOT).output(tree_copy_paste_list+" --> "+targetedItemId+" as "+copy_on_paste);
						MovieClip(ROOT).editFunctions.edit_moveInventoryToFolder(tree_copy_paste_list, targetedItemId, copy_on_paste);
						tree_copy_paste_list = "";
					}
					else if (event.target.caption == ".:. Rename")
					{
						MovieClip(ROOT).guiEvents.rename_mode = 1;
						myTree.selectable = false;
						
						var newName:TextInput = new TextInput();
						newName.name = "newName";
						var labelText = MovieClip(ROOT).trimFront(TreeCellRenderer(event.mouseTarget).data.label);
						labelText = labelText.substring(0, labelText.length-6); // to cut off " [CMT]" from the label
						newName.x = TreeCellRenderer(event.mouseTarget).x;
						newName.y = TreeCellRenderer(event.mouseTarget).y;
						newName.width = myTree.width-20;
						newName.appendText(labelText);
						newName.addEventListener(ComponentEvent.ENTER, enterPressed); 
						myTree.addChild(newName);
						newName.setFocus();
						
						function enterPressed(event:ComponentEvent)
						{
							MovieClip(ROOT).guiEvents.rename_mode = 0;
							myTree.selectable = true;
							
							//MovieClip(ROOT).output(event.target.text);
							myTree.removeChild(newName);
							MovieClip(ROOT).editFunctions.edit_renameInventory(targetedItemId, event.target.text);
						}
						
						function escPressed(event:KeyboardEvent)
						{
							if (event.keyCode == Keyboard.ESCAPE)
							{
								MovieClip(ROOT).guiEvents.rename_mode = 0;
								myTree.selectable = true;
								myTree.removeChild(newName);
							}
						}
						newName.addEventListener(KeyboardEvent.KEY_DOWN, escPressed);
						
					}
			
				}  
				
				// set context menu on cell renderer of selected item
				var theRenderer = myTree.itemToCellRenderer(theSelectedItem) as TreeCellRenderer;
				if (theRenderer != null)
				{
					theRenderer.contextMenu = myContextMenu;
				}

		}

	}
}
