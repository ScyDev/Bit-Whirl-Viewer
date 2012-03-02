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

	import fl.data.*;
	import com.yahoo.astra.fl.managers.AlertManager;
	import fl.events.ScrollEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	
	public class GuiEvents extends GlobalStage
	{
		public var edit_mode = 0;
		public var editScrollPosX = 0;
		public var editScrollPosY = 0;
		public var playScrollPosX = 0;
		public var playScrollPosY = 0;
		public var editZoom = 1.0;
		
		public var rename_mode = 0;
		
		public var zOrder = new Array();
		public var attachedObjects = new Object();
		
		public var fullscreen_mode = 0;

		public var zoomTargetX = null;
		public var zoomTargetY = null;
		
		public var clickthrough_mode = 0;
		
		public var permsDialog;
		public var viewportContentWidth = 1000;
		public var viewportContentHeight = 1000;
		public var fixedViewportWidth = 600;
		public var fixedViewportHeight = 500;
		public var autoUnloadObjects = true;
		public var hudContainer:MovieClip = new MovieClip();
		public var keysDown:Object = new Object();
		public var watchedKeys:Object = new Object();
	
		public var curr_map_name = "No map loaded...";
	
		public function GuiEvents()
		{
			ToolTip.init(Stage(STAGE), {textalign: 'center', opacity: 85, defaultdelay: 500});
			MovieClip(ROOT).logo_button.addEventListener("click", clickLogo, false, 0, true);
			ToolTip.attach(MovieClip(ROOT).logo_button, 'Learn more about Bit Whirl');
			MovieClip(ROOT).edit_tools.new_button.addEventListener("click", clickNew, false, 0, true);
			ToolTip.attach(MovieClip(ROOT).edit_tools.new_button, 'Create new object');
			MovieClip(ROOT).edit_tools.copy_button.addEventListener("click", clickCopy, false, 0, true);
			ToolTip.attach(MovieClip(ROOT).edit_tools.copy_button, 'Copy object');
			MovieClip(ROOT).edit_tools.del_button.addEventListener("click", clickDel, false, 0, true);
			ToolTip.attach(MovieClip(ROOT).edit_tools.del_button, 'Delete object');
			MovieClip(ROOT).chatConsole.chat_send_button.addEventListener("click", clickChatSend, false, 0, true);
			MovieClip(ROOT).chatConsole.chat_input.addEventListener(ComponentEvent.ENTER, clickChatSend, false, 0, true); 
			MovieClip(ROOT).edit_tools.zoom_in_button.addEventListener("click", clickZoomIn, false, 0, true);
			MovieClip(ROOT).edit_tools.zoom_out_button.addEventListener("click", clickZoomOut, false, 0, true);
			MovieClip(ROOT).viewport.addEventListener(ScrollEvent.SCROLL, onUserScroll, false, 0, true);
			MovieClip(ROOT).edit_button_schnipsel.play_button.addEventListener("click", clickPlay, false, 0, true);
			ToolTip.attach(MovieClip(ROOT).edit_button_schnipsel.play_button, 'Play mode');
			MovieClip(ROOT).edit_button_schnipsel.edit_button.addEventListener("click", clickEdit, false, 0, true);
			ToolTip.attach(MovieClip(ROOT).edit_button_schnipsel.edit_button, 'Edit mode');
			MovieClip(ROOT).header.label_map.addEventListener(ComponentEvent.ENTER, mapEnter, false, 0, true);
			MovieClip(ROOT).header.map_go_button.addEventListener("click", mapEnter);
			MovieClip(ROOT).header.fullscreen_button.addEventListener("click", clickFullscreen, false, 0, true);
			ToolTip.attach(MovieClip(ROOT).header.fullscreen_button, 'Fullscreen');
			MovieClip(ROOT).header.mute_button.addEventListener("click", clickMute, false, 0, true);
			MovieClip(ROOT).header.sound_button.addEventListener("click", clickMute, false, 0, true);
			ToolTip.attach(MovieClip(ROOT).header.mute_button, 'Mute Sounds');
			ToolTip.attach(MovieClip(ROOT).header.sound_button, 'Unmute Sounds');
			MovieClip(ROOT).header.search_button.addEventListener("click", clickSearch, false, 0, true);
			ToolTip.attach(MovieClip(ROOT).header.search_button, 'Find People, Places, Products');
			MovieClip(ROOT).obj_props.props_apply_button.addEventListener("click", clickApplyProps);
			MovieClip(ROOT).obj_props.props_obj_name.addEventListener(ComponentEvent.ENTER, clickApplyProps, false, 0, true);
			MovieClip(ROOT).obj_props.props_obj_rotZ.addEventListener(ComponentEvent.ENTER, clickApplyProps, false, 0, true);
			MovieClip(ROOT).obj_props.props_obj_x.addEventListener(ComponentEvent.ENTER, clickApplyProps, false, 0, true);
			MovieClip(ROOT).obj_props.props_obj_y.addEventListener(ComponentEvent.ENTER, clickApplyProps, false, 0, true);
			MovieClip(ROOT).obj_props.props_obj_z.addEventListener(ComponentEvent.ENTER, clickApplyProps, false, 0, true);
			MovieClip(ROOT).obj_props.props_obj_price.addEventListener(ComponentEvent.ENTER, clickApplyProps, false, 0, true);
			MovieClip(ROOT).obj_props.props_obj_sizeX.addEventListener(ComponentEvent.ENTER, clickApplyProps, false, 0, true);
			MovieClip(ROOT).obj_props.props_obj_sizeY.addEventListener(ComponentEvent.ENTER, clickApplyProps, false, 0, true);
			MovieClip(ROOT).obj_props.obj_contents_button.addEventListener("click", clickObjContents, false, 0, true);
			MovieClip(ROOT).obj_props.obj_perms_button.addEventListener("click", clickObjPerms, false, 0, true);
			
			//initCanvas(1000, 1000);
			
			MovieClip(ROOT).viewport.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownViewport, false, 0, true);
			MovieClip(ROOT).viewport.addEventListener(MouseEvent.MOUSE_UP, onReleaseViewport, false, 0, true);
			this.hudContainer.name = "hudCanvas";
			MovieClip(ROOT).viewport.addChild(hudContainer);
			Stage(STAGE).addEventListener(KeyboardEvent.KEY_DOWN, reportKeyDown, false, 0, true);
			Stage(STAGE).addEventListener(KeyboardEvent.KEY_UP, reportKeyUp, false, 0, true);
			MovieClip(ROOT).viewport.addEventListener(KeyboardEvent.KEY_UP, someKeyUp, false, 0, true);
			MovieClip(ROOT).treeActions.myTree.addEventListener(KeyboardEvent.KEY_UP, someKeyUp, false, 0, true);
			
			Key.initialize(MovieClip(ROOT).treeActions.myTree);
			Key.initialize(MovieClip(ROOT).layer_list);
			Key.initialize(Stage(STAGE));
			
			
			MovieClip(ROOT).output("INIT: GuiEvents run...", 0);
		}

		
		// #####################################
		// ############ BUTTONS     ############
		// #####################################
		
		public function clickLogo(eventObj:Object):void {
			navigateToURL(new URLRequest("https://www.bitwhirl.com"), "_blank");
		}
		
		
		public function clickNew(eventObj:Object):void {
			MovieClip(ROOT).editFunctions.edit_createNewObject();
		}
		
		public function clickCopy(eventObj:Object):void {
			MovieClip(ROOT).editFunctions.edit_copyObject(GuiFuncs.currSelectedClip.inflObjId);
		}
		
		public function clickDel(eventObj:Object):void {
			function buyConfirmHandler(event)
			{
				if (event.target.label == "Yes")
				{
					if (GuiFuncs.deleteFocusPlace == GuiFuncs.SELECTION_FOCUS_INVENTORY)
					{
						var delete_list = GuiFuncs.getSelectedListFromTree(MovieClip(ROOT).inventory_tree, "");
						MovieClip(ROOT).editFunctions.edit_delObject(delete_list);
					}
					else if (GuiFuncs.deleteFocusPlace == GuiFuncs.SELECTION_FOCUS_CONTENTS)
					{
						if (MovieClip(ROOT).objectContents.contentsList != null)
						{
							var delete_list = GuiFuncs.getSelectedListFromTree(MovieClip(ROOT).objectContents.contentsList, "");
							MovieClip(ROOT).editFunctions.edit_delObject(delete_list);
						}
					}
					else if (GuiFuncs.deleteFocusPlace == GuiFuncs.SELECTION_FOCUS_MAP)
					{
						MovieClip(ROOT).editFunctions.edit_delObject(GuiFuncs.deleteFocusObjectId);
					}
					
					GuiFuncs.clearDeleteFocus();
					GuiFuncs.clearObjProps(GuiFuncs.currSelectedClip);
				}
			}
			var msgTargetDesc = "";
			var msgTargetDescAdditional = "";
			if (GuiFuncs.deleteFocusPlace == GuiFuncs.SELECTION_FOCUS_INVENTORY)
			{
				msgTargetDesc = "YOUR INVENTORY";
				msgTargetDescAdditional = " (and all selected) ";
			}
			else if (GuiFuncs.deleteFocusPlace == GuiFuncs.SELECTION_FOCUS_CONTENTS)
			{
				msgTargetDesc = "OBJECT CONTENTS";
				msgTargetDescAdditional = " (and all selected) ";
			}
			else if (GuiFuncs.deleteFocusPlace == GuiFuncs.SELECTION_FOCUS_MAP)
			{
				msgTargetDesc = "the MAP";
			}
		
			if (rename_mode == 0)
			{
				if (GuiFuncs.deleteFocusObjectId != null)
				{
					AlertManager.createAlert(MovieClip(ROOT), "Delete '"+GuiFuncs.deleteFocusObjectName+"'"+msgTargetDescAdditional+" \nfrom "+msgTargetDesc+" ?", "Really delete?", ["Yes", "No"], buyConfirmHandler);  
				}
				else
				{
					AlertManager.createAlert(MovieClip(ROOT), "Nothing to delete.", "Delete", ["OK"], null);  
				}
			}
			
		}
		
		public function clickChatSend(eventObj:Object):void {
			MovieClip(ROOT).playFunctions.play_avatarSay(MovieClip(ROOT).chatConsole.chat_input.text);
			MovieClip(ROOT).chatConsole.chat_input.text = "";
		}
		
		public function clickZoomIn(eventObj:Object):void {
			editZoom += 0.10;
			MovieClip(ROOT).borderLayout.zoomViewport(editZoom, editZoom);
		
			MovieClip(ROOT).viewport.scrollTo(zoomTargetX*editZoom, zoomTargetY*editZoom, 500);
			//zoomTargetX = viewport.horizontalScrollPosition;
			//zoomTargetY = viewport.verticalScrollPosition;
			
			MovieClip(ROOT).edit_tools.zoomFactor.text = editZoom;
		}
		
		public function clickZoomOut(eventObj:Object):void {
			editZoom -= 0.10;
			MovieClip(ROOT).borderLayout.zoomViewport(editZoom, editZoom);
			
			MovieClip(ROOT).viewport.scrollTo(zoomTargetX*editZoom, zoomTargetY*editZoom, 500);
			
			MovieClip(ROOT).edit_tools.zoomFactor.text = editZoom;
		}
		
		public function onUserScroll(event:ScrollEvent)
		{
			zoomTargetX = MovieClip(ROOT).viewport.horizontalScrollPosition;
			zoomTargetY = MovieClip(ROOT).viewport.verticalScrollPosition;	
		}
		
		public function clickPlay(eventObj:Object):void {
			//MovieClip(ROOT).output("Edit clicked! "+edit_mode);
			GuiFuncs.clearDeleteFocus();
		
			if (edit_mode == 1)
			{
				GuiFuncs.clearEditHandles();
				
				edit_mode = 0;
				//edit_button.label = "Edit";
				MovieClip(ROOT).edit_button_schnipsel.swapChildren(MovieClip(ROOT).edit_button_schnipsel.edit_button, MovieClip(ROOT).edit_button_schnipsel.play_button);
				//play_button.alpha = 1;
				//edit_button.alpha = 0;
				
				MovieClip(ROOT).borderLayout.setPlayLayoutMode(true);
			}
				
		}
		
		public function clickEdit(eventObj:Object):void {
			//MovieClip(ROOT).output("Edit clicked! "+edit_mode);
			GuiFuncs.clearDeleteFocus();
		
			if (edit_mode == 0)
			{
				zoomTargetX = MovieClip(ROOT).viewport.horizontalScrollPosition;
				zoomTargetY = MovieClip(ROOT).viewport.verticalScrollPosition;
				
				edit_mode = 1;
				//edit_button.label = "Play";
				MovieClip(ROOT).edit_button_schnipsel.swapChildren(MovieClip(ROOT).edit_button_schnipsel.edit_button, MovieClip(ROOT).edit_button_schnipsel.play_button);
				//play_button.alpha = 0;
				//edit_button.alpha = 1;
				
				MovieClip(ROOT).borderLayout.setPlayLayoutMode(false);
			}
			
			/*
			var orderZOrder = zOrder;
			for (var i = 0; i < orderZOrder.length; i++)
			{
				//if ((orderZOrder[i] != -1) && (insertionContainer.getChildByName(orderZOrder[i]) != null))
				{
					MovieClip(ROOT).output("zOrder: "+orderZOrder[i]+" at "+i, 0);
					//MovieClip(ROOT).output(""+orderZOrder[i], 0);
				}
			}
			*/
		}
		
		public function mapEnter(eventObj:Object):void {
			MovieClip(ROOT).playFunctions.play_avatarSay("/cmd teleport "+MovieClip(ROOT).header.label_map.text);
		}
		
		public function clickFullscreen(eventObj:Object):void {
			if (fullscreen_mode == 1)
			{
				fullscreen_mode = 0;
				Stage(STAGE).displayState = StageDisplayState.NORMAL;
			}
			else
			{
				fullscreen_mode = 1;
				Stage(STAGE).displayState = StageDisplayState.FULL_SCREEN;
			}
			MovieClip(ROOT).borderLayout.adjustLayoutSizes();
		}
		
		public function clickMute(eventObj:Object):void {
			MovieClip(ROOT).soundEffects.setMute(!MovieClip(ROOT).soundEffects.muted);
			
			MovieClip(ROOT).header.swapChildren(MovieClip(ROOT).header.mute_button, MovieClip(ROOT).header.sound_button);
		}
		
		public function clickSearch(eventObj:Object):void 
		{
		
			if (MovieClip(ROOT).search.searchDialog != null)
			{
				Stage(STAGE).removeChild(MovieClip(ROOT).search.searchDialog);
				MovieClip(ROOT).search.searchDialog = null;
			}
			
			MovieClip(ROOT).search.searchDialog = new SearchDialog();
			MovieClip(ROOT).search.searchDialog.x = 200;
			MovieClip(ROOT).search.searchDialog.y = 100;
	
			// dragging
			function onPressSearch(eventObj:Object):void {
				MovieClip(ROOT).search.searchDialog.startDrag();
			}
			MovieClip(ROOT).search.searchDialog.title.addEventListener(MouseEvent.MOUSE_DOWN, onPressSearch, false, 0, true);
			function onReleaseSearch(eventObj:Object):void {
				MovieClip(ROOT).search.searchDialog.stopDrag();
			}
			MovieClip(ROOT).search.searchDialog.title.addEventListener(MouseEvent.MOUSE_UP, onReleaseSearch, false, 0, true);
			
			// focus
			function onTouchSearch(eventObj:Object):void {
				MovieClip(ROOT).search.searchDialog.parent.removeChild(MovieClip(ROOT).search.searchDialog);
				Stage(STAGE).addChild(MovieClip(ROOT).search.searchDialog);
			}
			MovieClip(ROOT).search.searchDialog.addEventListener(MouseEvent.MOUSE_DOWN, onTouchSearch, false, 0, true);
			
			// closing
			function clickCloseSearch(eventObj:Object):void {
				Stage(STAGE).removeChild(MovieClip(ROOT).search.searchDialog);
				MovieClip(ROOT).search.searchDialog = null;
			}
			MovieClip(ROOT).search.searchDialog.closeSearchButton.addEventListener("click", clickCloseSearch, false, 0, true);
			
			// searching
			function clickFind(eventObj:Object):void {
				MovieClip(ROOT).search.loadSearchResults(MovieClip(ROOT).search.searchDialog.findText.text, MovieClip(ROOT).search.searchDialog.findCategory.text);
			}
			MovieClip(ROOT).search.searchDialog.findButton.addEventListener("click", clickFind, false, 0, true);
			function enterPressed(event:ComponentEvent)
			{
				MovieClip(ROOT).search.loadSearchResults(MovieClip(ROOT).search.searchDialog.findText.text, MovieClip(ROOT).search.searchDialog.findCategory.text);
			}
			MovieClip(ROOT).search.searchDialog.findText.addEventListener(ComponentEvent.ENTER, enterPressed, false, 0, true); 
			
	
			Stage(STAGE).addChild(MovieClip(ROOT).search.searchDialog); 
			MovieClip(ROOT).search.setupResultsActions();
				
		}
		
		
		public function clickApplyProps(eventObj:Object):void {
			if (GuiFuncs.currSelectedClip != null)
			{
				MovieClip(ROOT).editFunctions.edit_applyObjectProps(GuiFuncs.currSelectedClip.inflObjId, 
																	MovieClip(ROOT).obj_props.props_obj_name.text, 
																	MovieClip(ROOT).obj_props.props_obj_x.text, 
																	MovieClip(ROOT).obj_props.props_obj_y.text, 
																	MovieClip(ROOT).obj_props.props_obj_z.text, 
																	MovieClip(ROOT).obj_props.props_obj_rotZ.text, 
																	MovieClip(ROOT).obj_props.props_obj_sell.selected, 
																	MovieClip(ROOT).obj_props.props_obj_price.text, 
																	MovieClip(ROOT).obj_props.props_obj_solid.selected, 
																	"" /*MovieClip(ROOT).obj_props.props_obj_clickThrough.selected*/, 
																	MovieClip(ROOT).obj_props.props_obj_sizeX.text, 
																	MovieClip(ROOT).obj_props.props_obj_sizeY.text);
			}
		}
		
		// Contents dialog
		public function clickObjContents(eventObj:Object):void {
		
			if (MovieClip(ROOT).objectContents.contentsDialog != null)
			{
				Stage(STAGE).removeChild(MovieClip(ROOT).objectContents.contentsDialog);
				MovieClip(ROOT).objectContents.contentsDialog = null;
			}
			
			if (GuiFuncs.currSelectedClip != null)
			{
				MovieClip(ROOT).objectContents.contentsDialog = new ObjectContentsDialog();
				MovieClip(ROOT).objectContents.contentsDialog.x = 200;
				MovieClip(ROOT).objectContents.contentsDialog.y = 100;
				MovieClip(ROOT).objectContents.contentsDialog.object_id.text = GuiFuncs.currSelectedClip.inflObjId;
		
				// dragging
				function onPressContents(eventObj:Object):void {
					MovieClip(ROOT).objectContents.contentsDialog.startDrag();
				}
				MovieClip(ROOT).objectContents.contentsDialog.title.addEventListener(MouseEvent.MOUSE_DOWN, onPressContents, false, 0, true);
				function onReleaseContents(eventObj:Object):void {
					MovieClip(ROOT).objectContents.contentsDialog.stopDrag();
				}
				MovieClip(ROOT).objectContents.contentsDialog.title.addEventListener(MouseEvent.MOUSE_UP, onReleaseContents, false, 0, true);
				
				// focus
				function onTouchContents(eventObj:Object):void {
					MovieClip(ROOT).objectContents.contentsDialog.parent.removeChild(MovieClip(ROOT).objectContents.contentsDialog);
					Stage(STAGE).addChild(MovieClip(ROOT).objectContents.contentsDialog);
				}
				MovieClip(ROOT).objectContents.contentsDialog.addEventListener(MouseEvent.MOUSE_DOWN, onTouchContents, false, 0, true);
				
				// closing
				function clickCloseContents(eventObj:Object):void {
					Stage(STAGE).removeChild(MovieClip(ROOT).objectContents.contentsDialog);
					MovieClip(ROOT).objectContents.contentsDialog = null;
					
					if (GuiFuncs.deleteFocusPlace == GuiFuncs.SELECTION_FOCUS_CONTENTS)
					{
						GuiFuncs.clearDeleteFocus();
					}
				}
				MovieClip(ROOT).objectContents.contentsDialog.button_close_contents.addEventListener("click", clickCloseContents);
		
				Stage(STAGE).addChild(MovieClip(ROOT).objectContents.contentsDialog);
				
				MovieClip(ROOT).objectContents.loadObjContents(MovieClip(ROOT).objectContents.contentsDialog.list_obj_contents, GuiFuncs.currSelectedClip.inflObjId)
				MovieClip(ROOT).objectContents.contentsDialog.label_object_name.text = GuiFuncs.currSelectedClip.inflObjName;
				
				MovieClip(ROOT).objectContents.setContentsOnReleaseEvent();
			}
		}
		
		// Perms dialog
		public function clickObjPerms(eventObj:Object):void 
		{
			if (permsDialog != null)
			{
				Stage(STAGE).removeChild(permsDialog);
				permsDialog = null;		
			}
			
			//if (GuiFuncs.currSelectedClip != null)
			MovieClip(ROOT).output("deleteFocusObjectId: "+GuiFuncs.deleteFocusObjectId, 0);
			if (GuiFuncs.deleteFocusObjectId != null)
			{
				permsDialog = new PermissionsDialog();
				permsDialog.x = 200;
				permsDialog.y = 100;
				
				permsDialog.object_id.text = GuiFuncs.deleteFocusObjectId;
				if (GuiFuncs.currSelectedClip != null)
				{
					permsDialog.object_name.text = GuiFuncs.deleteFocusObjectName;
					//permsDialog.object_name.text = GuiFuncs.currSelectedClip.inflObjName;
				}
				else
				{
					permsDialog.object_name.text = "Object Name Not Found";
				}
				
				permsDialog.perms_yours_copy.enabled = false;
				permsDialog.perms_yours_mod.enabled = false;
				permsDialog.perms_yours_trans.enabled = false;
				
				function clickSavePerms(eventObj:Object):void {
					MovieClip(ROOT).editFunctions.edit_applyObjectPerms(permsDialog.object_id.text, 
										  permsDialog.perms_nextowners_copy.selected, 
										  permsDialog.perms_nextowners_mod.selected, 
										  permsDialog.perms_nextowners_trans.selected,
										  permsDialog.perms_nextbuyers_copy.selected,
										  permsDialog.perms_nextbuyers_mod.selected,
										  permsDialog.perms_nextbuyers_trans.selected
										  );
				}
				permsDialog.button_apply_perms.addEventListener("click", clickSavePerms, false, 0, true);
		
				// dragging
				function onPressPerms(eventObj:Object):void {
					permsDialog.startDrag();
				}
				permsDialog.title.addEventListener(MouseEvent.MOUSE_DOWN, onPressPerms, false, 0, true);
				function onReleasePerms(eventObj:Object):void {
					permsDialog.stopDrag();
				}
				permsDialog.title.addEventListener(MouseEvent.MOUSE_UP, onReleasePerms, false, 0, true);
				
				// focus
				function onTouchPerms(eventObj:Object):void {
					permsDialog.parent.removeChild(permsDialog);
					Stage(STAGE).addChild(permsDialog);
				}
				permsDialog.addEventListener(MouseEvent.MOUSE_DOWN, onTouchPerms, false, 0, true);
		
				// closing
				function clickCancelPerms(eventObj:Object):void {
					Stage(STAGE).removeChild(permsDialog);
					permsDialog = null;
				}
				permsDialog.button_cancel_perms.addEventListener("click", clickCancelPerms, false, 0, true);
				
				MovieClip(ROOT).editFunctions.edit_requestObjectPerms(permsDialog.object_id.text);	
			
				Stage(STAGE).addChild(permsDialog);
			}
		}
		
		
		public function clickSaveScript(eventObj:Object):void {
			MovieClip(ROOT).output("SAVE", 0);
		}
		
		public function clickScript(eventObj:Object):void {
			var scriptWindow = MovieClip(ROOT).createObject("ScriptWindow", "scriptWindow", MovieClip(ROOT).numChildren, null);
			// window content is set directly as property on window-MC in library
			//MovieClip(ROOT).output("scriptWindow: "+scriptWindow+" "+scriptWindow.content);
			//scriptWindow.contentPath.script_save_button.addEventListener("click", clickSaveScript);
		}
		
		public function showPayDialog(inflObjId, receiverName, username)
		{
			
			var payDialog = new PayDialog();
			payDialog.x = 200;
			payDialog.y = 100;
			payDialog.object_id.text = inflObjId;
			payDialog.object_name.text = receiverName;
			payDialog.username.text = username;
		
			// dragging
			function onPressPay(eventObj:Object):void {
				payDialog.startDrag();
			}
			payDialog.addEventListener(MouseEvent.MOUSE_DOWN, onPressPay, false, 0, true);
			function onReleasePay(eventObj:Object):void {
				payDialog.stopDrag();
			}
			payDialog.addEventListener(MouseEvent.MOUSE_UP, onReleasePay, false, 0, true);
			
			// closing
			function clickClosePay(eventObj:Object):void {
				Stage(STAGE).removeChild(payDialog);
				payDialog = null;
			}
			payDialog.button_close.addEventListener("click", clickClosePay, false, 0, true);
			payDialog.button_no.addEventListener("click", clickClosePay, false, 0, true);
		
			function clickOkPay(eventObj:Object):void {
				if (payDialog.object_id.text != null && payDialog.object_id.text != "")
				{
					MovieClip(ROOT).playFunctions.play_payToObject(payDialog.object_id.text, payDialog.amount.text);
				}
				else if (payDialog.username.text != null && payDialog.username.text != "")
				{
					MovieClip(ROOT).playFunctions.play_payToUser(payDialog.username.text, payDialog.amount.text);
				}
				Stage(STAGE).removeChild(payDialog);
				payDialog = null;
			}
			payDialog.button_pay.addEventListener("click", clickOkPay, false, 0, true);
			
			Stage(STAGE).addChild(payDialog);					
		}
		
		// #####################################
		// ########### VIEWPORT     ############
		// #####################################
		
		public function initCanvas(w, h)
		{
			MovieClip(ROOT).borderLayout.playZoom = 1.0;
			editZoom = 1.0;
			
			zOrder = new Array();
			for (var i = 0; i < 20; i++)
			{
				zOrder[i] = -1;
			}
			
			// delete all objects on canvas
			if (MovieClip(ROOT).viewport.content != null && DisplayObjectContainer(MovieClip(ROOT).viewport.content).getChildByName("mapCanvas") != null)
			{
				for (var i = 0; i < DisplayObjectContainer(DisplayObjectContainer(MovieClip(ROOT).viewport.content).getChildByName("mapCanvas")).numChildren; i++)
				{
					DisplayObjectContainer(DisplayObjectContainer(MovieClip(ROOT).viewport.content).getChildByName("mapCanvas")).removeChildAt(i);
				}
				
				DisplayObjectContainer(MovieClip(ROOT).viewport.content).removeChild(DisplayObjectContainer(MovieClip(ROOT).viewport.content).getChildByName("mapCanvas"));
				//viewport.content = null;
			}
			
			// now do canvas
			var supercanvas = new Sprite();
			var canvas = new MovieClip();
			canvas.name = "mapCanvas";
			supercanvas.addChild(canvas);
			//canvas.opaqueBackground = 0xFF0000;
		
			var canvasBg = new Bitmap(new BitmapData(w, h, true, 0xFFDDDDDD));
			canvas.addChild(canvasBg);
			
			var canvasMask = new Bitmap(new BitmapData(w, h, true, 0xFFDDDDDD));
			supercanvas.addChild(canvasMask);
			canvas.mask = canvasMask;
		
			MovieClip(ROOT).viewport.source = supercanvas;
			viewportContentWidth = MovieClip(ROOT).viewport.content.width;
			viewportContentHeight = MovieClip(ROOT).viewport.content.height;
			
			MovieClip(ROOT).output("setted viewport.source", 0);
			
			canvasBg = null;
			canvas = null;
			supercanvas = null;
			
			MovieClip(ROOT).borderLayout.playZoom = MovieClip(ROOT).viewport.content.scaleX;
		}
		
		public function closeLens(x, y)
		{
			var lensClose = new LensClose();
			
			lensClose.width = fixedViewportWidth*3;
			lensClose.height = fixedViewportHeight*3;
			//MovieClip(ROOT).output("lens size:"+lensClose.width+"/"+lensClose.height, 0);
			lensClose.x = x-(lensClose.width/2);
			lensClose.y = y-(lensClose.height/2);
			//MovieClip(ROOT).output("lens pos:"+lensClose.x+"/"+lensClose.y, 0);
		
			applyBlur(lensClose);
			
			Sprite(MovieClip(ROOT).viewport.content).addChild(lensClose);
		}
		
		public function openLens(x, y)
		{
			var lensOpen = new LensOpen();
			
			lensOpen.width = fixedViewportWidth*3;
			lensOpen.height = fixedViewportHeight*3;
			//MovieClip(ROOT).output("lens size:"+lensClose.width+"/"+lensClose.height, 0);
			lensOpen.x = x-(lensOpen.width/2);
			lensOpen.y = y-(lensOpen.height/2);
			//MovieClip(ROOT).output("lens pos:"+lensClose.x+"/"+lensClose.y, 0);
		
			applyBlur(lensOpen);
			
			Sprite(MovieClip(ROOT).viewport.content).addChild(lensOpen);
		}
		
		public function applyBlur(blurThis)
		{
			var blur:BlurFilter = new BlurFilter();
			blur.blurX = 2;
			blur.blurY = 2;
			blur.quality = BitmapFilterQuality.LOW;
			blurThis.filters = [blur];
			
		}
		
		public function onMouseDownViewport(evt:MouseEvent)
		{
			var hudX = MovieClip(ROOT).viewport.mouseX;
			var hudY = MovieClip(ROOT).viewport.mouseY;
			var currMouseX = MovieClip(ROOT).viewport.content.mouseX;
			var currMouseY = MovieClip(ROOT).viewport.content.mouseY;
			
			var mouseViewportX = currMouseX - MovieClip(ROOT).viewport.horizontalScrollPosition;
			var mouseViewportY = currMouseY - MovieClip(ROOT).viewport.verticalScrollPosition;
			
			//MovieClip(ROOT).output("viewport: "+mouseX+" - "+viewport.x+" - "+viewport.width+" | "+mouseY+" - "+viewport.y+" - "+viewport.height);
			if (mouseX < (MovieClip(ROOT).viewport.x + MovieClip(ROOT).viewport.width+15) // offset of the outest horizPane from left border
				&& mouseY < (MovieClip(ROOT).viewport.y + MovieClip(ROOT).viewport.height+74) // height of the header
				&& (mouseX < (MovieClip(ROOT).viewport.x + MovieClip(ROOT).viewport.width+5-45) || mouseY > (54+60)) // exclude the edit button
				)
			{
				//MovieClip(ROOT).output("MouseDown");
				
				if (edit_mode == 1)
				{
					//var selectionClip = viewport.content["selection"];
				}
				else
				{
					if (MovieClip(ROOT).ajax.loginToken != null && MovieClip(ROOT).ajax.loginToken != "null" && MovieClip(ROOT).ajax.loginToken != "")
					{
						MovieClip(ROOT).playFunctions.play_userClickAt(currMouseX, currMouseY, hudX, hudY);
					}
				}
			}
		}
		
		public function onReleaseViewport(event:Event)
		{
			var disableScripts = Key.isDown(Keyboard.CONTROL);
			var forceNoCopy = Key.isDown(Keyboard.SHIFT);
			
			if (MovieClip(ROOT).treeActions.draggingTreeItem != null)
			{
				var drag_list = GuiFuncs.getSelectedListFromTree(MovieClip(ROOT).inventory_tree, MovieClip(ROOT).treeActions.draggingTreeItemId);
		
				//MovieClip(ROOT).output("put into contents "+draggingTreeItem+" "+draggingTreeItemId+" "+MovieClip(ROOT).objectContents.contentsDialog.object_id.text);
				MovieClip(ROOT).editFunctions.edit_rezObject(drag_list, MovieClip(ROOT).viewport.content.mouseX, MovieClip(ROOT).viewport.content.mouseY, disableScripts, forceNoCopy);
				
				MovieClip(ROOT).treeActions.clearTreeDrag();
			}
			if (MovieClip(ROOT).objectContents.draggingContentsItem != null)
			{
				var drag_list = GuiFuncs.getSelectedListFromTree(MovieClip(ROOT).objectContents.contentsList, MovieClip(ROOT).objectContents.draggingContentsItemId);
		
				MovieClip(ROOT).editFunctions.edit_rezObject(drag_list, MovieClip(ROOT).viewport.content.mouseX, MovieClip(ROOT).viewport.content.mouseY, disableScripts, forceNoCopy);
				MovieClip(ROOT).objectContents.clearContentsDrag();
			}
			
			MovieClip(ROOT).treeActions.scrollIncrement = 0;
		}
		
		public function getObjectFromMap(objId)
		{
			var concernedObject = DisplayObjectContainer(getMapCanvas()).getChildByName(objId);
			if (concernedObject == null && attachedObjects[objId] != null)
			{
				var parentObject = DisplayObjectContainer(getMapCanvas()).getChildByName(attachedObjects[objId]);
				concernedObject = parentObject.getChildByName(objId);
			}
			return concernedObject;
		}
		
		public function getMapCanvas()
		{
			return DisplayObjectContainer(MovieClip(ROOT).viewport.content).getChildByName("mapCanvas");
		}
		
		public function getObjectFromHud(objId)
		{
			return DisplayObjectContainer(getHudCanvas()).getChildByName(objId);
		}
		
		public function getHudCanvas()
		{
			return DisplayObjectContainer(MovieClip(ROOT).viewport).getChildByName("hudCanvas");
		}
		
		public function removeFromZOrder(infilionObject)
		{
			for (var i = 0; i < zOrder.length; i++)
			{
				if (zOrder[i] == infilionObject.inflObjId)
				{
					zOrder[i] = -1;
					//zOrder.splice(i, 1);
					MovieClip(ROOT).output("removed from Z...", 0);
				}
			}
			
		}
		
		public function getZOrderIndexOf(objId)
		{
			var index = -1;
			for (var i = 0; i < zOrder.length; i++)
			{
				if (zOrder[i] == objId)
				{
					index = i;
					break;
				}
			}
			return index;
		}
		
		
		// #####################################
		// ########### HUD          ############
		// #####################################
		
		
		/////////////////////////////////
		////////// KEYS /////////////////
		/////////////////////////////////
		
		
		public function setWatchedKeys(keys)
		{
			var keysList = keys.split(":");
			for (var i = 0; i < keysList.length; i++)
			{
				watchedKeys[keysList[i]] = true;
				//MovieClip(ROOT).output("watching: "+keysList[i], 0);
			}
		}
		
		public function isWatched(key):Boolean {
			return Boolean(key in watchedKeys);
		}
		
		public function isDown(keyCode:uint):Boolean {
			return Boolean(keyCode in keysDown);
		}
		
		public function reportKeyDown(event:KeyboardEvent):void
		{
			if (edit_mode == 0)
			{
				var viewportX = MovieClip(ROOT).viewport.mouseX;
				var viewportY = MovieClip(ROOT).viewport.mouseY;
				//MovieClip(ROOT).output("Key Pressed: " + String.fromCharCode(event.charCode) +         " (character code: " + event.charCode + ")", 0);
					
				if (viewportX >= 0 && viewportX <= MovieClip(ROOT).viewport.width
					&& viewportY >= 0 && viewportY <= MovieClip(ROOT).viewport.height)
				{
					if (isWatched(String.fromCharCode(event.charCode)))
					{
						if (!isDown(event.keyCode)) // only send event if key is not already pressed
						{
							keysDown[event.keyCode] = true;
					
							var currMouseX = MovieClip(ROOT).viewport.content.mouseX;
							var currMouseY = MovieClip(ROOT).viewport.content.mouseY;
						
							MovieClip(ROOT).playFunctions.play_keyPressed(String.fromCharCode(event.charCode), currMouseX, currMouseY, viewportX, viewportY);
							//MovieClip(ROOT).output("Really Pressed!", 0);
						}
					}
				}
			}
		}
		
		public function reportKeyUp(event:KeyboardEvent):void
		{
			if (edit_mode == 0)
			{
				var viewportX = MovieClip(ROOT).viewport.mouseX;
				var viewportY = MovieClip(ROOT).viewport.mouseY;
					
				if (viewportX >= 0 && viewportX <= MovieClip(ROOT).viewport.width
					&& viewportY >= 0 && viewportY <= MovieClip(ROOT).viewport.height)
				{
					if (isWatched(String.fromCharCode(event.charCode)))
					{
						if (isDown(event.keyCode))
						{
							delete keysDown[event.keyCode];
							
							var currMouseX = MovieClip(ROOT).viewport.content.mouseX;
							var currMouseY = MovieClip(ROOT).viewport.content.mouseY;
						
							MovieClip(ROOT).playFunctions.play_keyReleased(String.fromCharCode(event.charCode), currMouseX, currMouseY, viewportX, viewportY);
							//trace("Key Released: " + String.fromCharCode(event.charCode) +         " (character code: " + event.charCode + ")");
						}
					}
				}
			}
		}
		
		public function someKeyUp(event:KeyboardEvent):void
		{
			if (edit_mode == 1)
			{
				if (event.keyCode == Keyboard.DELETE)
				{
					clickDel(event);
				}
			}
		}
	}
}
