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
	import flash.display.*;
	import flash.utils.*;

	import com.yahoo.astra.fl.containers.*; 
	import com.yahoo.astra.layout.modes.*;
	import fl.controls.ScrollPolicy;
	
	
	public class BorderLayout extends GlobalStage
	{
		public var userSetInventoryWidth = 265;
		public var userSetChatConsoleHeight = 1;
		public var inventoryWidth = 265;
		public var chatConsoleHeight = 1;
		
		public var scrollBarWidth = 20;
		public var componentPadding = 2;
		public var maxChatHeight = 151;
		public var minChatHeight = 20;
		public var chatMaxWidth = 660;
		public var minInventoryWidth = 10;
		public var minPropsHeight = 210;
		
		public var LOCK_VIEWPORT_TO_CANVAS_SIZE = false;
		
		public var vBoxPaneRightMask:Sprite=new Sprite();
		public var vChatMask:Sprite=new Sprite();
		
		public var playZoom = 0;
		
		public var dragStartWidth = 0;
		public var dragStartHeight = 0;
		
		public function BorderLayout()
		{
			Stage(STAGE).scaleMode = StageScaleMode.NO_SCALE;
			Stage(STAGE).align = StageAlign.TOP_LEFT;
			Stage(STAGE).addEventListener(flash.events.Event.RESIZE, onStageResize);
			
			MovieClip(ROOT).vBoxPaneRight.horizontalScrollPolicy = ScrollPolicy.OFF;
			MovieClip(ROOT).vBoxPaneTop.horizontalScrollPolicy = ScrollPolicy.OFF;
			MovieClip(ROOT).vBoxPaneTop.verticalScrollPolicy = ScrollPolicy.OFF;
			MovieClip(ROOT).hBoxPane.horizontalScrollPolicy = ScrollPolicy.OFF;
			MovieClip(ROOT).hBoxPane.verticalScrollPolicy = ScrollPolicy.OFF;
			
			// setup masks
			Stage(STAGE).addChild(vBoxPaneRightMask);
			vBoxPaneRightMask.x = MovieClip(ROOT).vBoxPaneRight.x;
			vBoxPaneRightMask.y = MovieClip(ROOT).vBoxPaneRight.y;
			vBoxPaneRightMask.graphics.clear();
			vBoxPaneRightMask.graphics.beginFill(0xFFFFFF,1);
			vBoxPaneRightMask.graphics.drawRect(0,0,100,100);
			vBoxPaneRightMask.graphics.endFill();
			vBoxPaneRightMask.width = MovieClip(ROOT).vBoxPaneRight.width;
			MovieClip(ROOT).vBoxPaneRight.mask = vBoxPaneRightMask;
			
			Stage(STAGE).addChild(vChatMask);
			vChatMask.x = MovieClip(ROOT).chatConsole.x;
			vChatMask.y = MovieClip(ROOT).chatConsole.y;
			vChatMask.graphics.clear();
			vChatMask.graphics.beginFill(0xFFFFFF,1);
			vChatMask.graphics.drawRect(0,0,100,100);
			vChatMask.graphics.endFill();
			vChatMask.width = MovieClip(ROOT).chatConsole.width;
			vChatMask.height = MovieClip(ROOT).chatConsole.height;
			MovieClip(ROOT).chatConsole.mask = vChatMask;
			
			MovieClip(ROOT).viewport.addChild(MovieClip(ROOT).shadow_n);
			MovieClip(ROOT).shadow_n.mouseEnabled = false;
			MovieClip(ROOT).shadow_n.mouseChildren = false;
			MovieClip(ROOT).viewport.addChild(MovieClip(ROOT).shadow_e);
			MovieClip(ROOT).shadow_e.mouseEnabled = false;
			MovieClip(ROOT).shadow_e.mouseChildren = false;
			MovieClip(ROOT).viewport.addChild(MovieClip(ROOT).shadow_s);
			MovieClip(ROOT).shadow_s.mouseEnabled = false;
			MovieClip(ROOT).shadow_s.mouseChildren = false;
			MovieClip(ROOT).viewport.addChild(MovieClip(ROOT).shadow_w);
			MovieClip(ROOT).shadow_w.mouseEnabled = false;
			MovieClip(ROOT).shadow_w.mouseChildren = false;
						
						
			chatConsoleHeight = minChatHeight+1; // to make it go down with clickChatHandleHandler() command that follows
			
			// resize handle viewport
			MovieClip(ROOT).viewport.addChild(MovieClip(ROOT).edit_button_schnipsel); // take it from top stage and put it into viewport
			var resizeHandleVBoxLeft = new GenericDragButton();
			resizeHandleVBoxLeft.direction = "horizontal";
			//this.resizeHandleViewport.setIcon("InventoryResizeHandle", 10, 30);
			resizeHandleVBoxLeft.addEventListener(DragEvent.DRAG_START, resizeVBoxLeftDragStartHandler);
			resizeHandleVBoxLeft.addEventListener(DragEvent.DRAG_UPDATE, resizeVBoxLeftDragUpdateHandler);
			
			
			// resize handle viewport
			var resizeHandleViewport = new GenericDragButton();
			resizeHandleViewport.direction = "vertical";
			resizeHandleViewport.setIcon("ChatResizeHandle", 80, 5);  // width/height finetuned for the especially big chat button
			//this.resizeHandleViewport.x = 50;
			//this.resizeHandleViewport.y = -50;
			//this.resizeHandleViewport.addEventListener(DragEvent.DRAG_START, resizeViewportDragStartHandler);
			//this.resizeHandleViewport.addEventListener(DragEvent.DRAG_UPDATE, resizeViewportDragUpdateHandler);
			resizeHandleViewport.addEventListener("click", clickChatHandleHandler);
			ToolTip.attach(resizeHandleViewport, 'Chat');
			// resize handle inventory
			var resizeHandleInventory = new ResizeHandle();
			resizeHandleInventory.direction = "vertical";
			resizeHandleInventory.addEventListener(DragEvent.DRAG_START, resizeInventoryDragStartHandler);
			resizeHandleInventory.addEventListener(DragEvent.DRAG_UPDATE, resizeInventoryDragUpdateHandler);
			
			// resize handle layers
			var resizeHandleLayers = new ResizeHandle();
			resizeHandleLayers.direction = "vertical";
			resizeHandleLayers.addEventListener(DragEvent.DRAG_START, resizeLayersDragStartHandler);
			resizeHandleLayers.addEventListener(DragEvent.DRAG_UPDATE, resizeLayersDragUpdateHandler);
			
			// config the panes
			var vBoxLeftConfig:Array =   
			[  
			 
				{target: MovieClip(ROOT).viewport}, //, percentHeight: 100},  
				{target: resizeHandleViewport},
				{target: MovieClip(ROOT).chatConsole}, //, percentHeight: 1}
			
			];   
			MovieClip(ROOT).vBoxPaneLeft.configuration = vBoxLeftConfig;
			
			var vBoxRightConfig:Array =   
			[  
			 
				{target: MovieClip(ROOT).edit_tools}, //, percentHeight: 47},  
				{target: MovieClip(ROOT).inventory_tree}, //, percentHeight: 47},  
				{target: resizeHandleInventory},
				{target: MovieClip(ROOT).layer_list}, //, percentHeight: 20},  
				{target: resizeHandleLayers},
				{target: MovieClip(ROOT).obj_props}, //, percentHeight: 33}
			
			];   
			MovieClip(ROOT).vBoxPaneRight.configuration = vBoxRightConfig;
			
			var hBoxPaneConfig:Array =   
			[  
				{target: MovieClip(ROOT).vBoxPaneLeft}, //, percentWidth: 80},  
				{target: resizeHandleVBoxLeft},  
				{target: MovieClip(ROOT).vBoxPaneRight}, //, percentWidth: 20},  
			];   
			MovieClip(ROOT).hBoxPane.configuration = hBoxPaneConfig;
			
			var vBoxPaneTopConfig:Array =   
			[  
				{target: MovieClip(ROOT).header},  
				{target: MovieClip(ROOT).hBoxPane},  
			];   
			MovieClip(ROOT).vBoxPaneTop.configuration = vBoxPaneTopConfig;

			
			MovieClip(ROOT).output("INIT: BorderLayout has run...", 0);
		}

		public function onStageResize(event)
		{
			//MovieClip(ROOT).output("Stage(STAGE).stageWidth: "+Stage(STAGE).stageWidth, 0);
			//MovieClip(ROOT).output("this.width: "+this.width, 0);
			adjustLayoutSizes();
		}
		
		public function setPlayLayoutMode(active)
		{
			if (active)
			{
				MovieClip(ROOT).guiEvents.editScrollPosX = MovieClip(ROOT).viewport.horizontalScrollPosition;
				MovieClip(ROOT).guiEvents.editScrollPosY = MovieClip(ROOT).viewport.verticalScrollPosition;
				//editZoom = viewport.content.scaleX;
				//zoomViewport(playZoom, playZoom);
				MovieClip(ROOT).viewport.scrollTo(MovieClip(ROOT).guiEvents.playScrollPosX, MovieClip(ROOT).guiEvents.playScrollPosY, 500);
		
				inventoryWidth = 10;	
				MovieClip(ROOT).viewport.verticalScrollPolicy = ScrollPolicy.OFF;
				MovieClip(ROOT).viewport.horizontalScrollPolicy = ScrollPolicy.OFF;
				MovieClip(ROOT).vBoxPaneRight.verticalScrollPolicy = ScrollPolicy.OFF;
				
				adjustLayoutSizes();
				
				MovieClip(ROOT).playFunctions.play_sendViewportDimensions();
			}
			else
			{
				playZoom = MovieClip(ROOT).viewport.content.scaleX;
				MovieClip(ROOT).guiEvents.playScrollPosX = MovieClip(ROOT).viewport.horizontalScrollPosition;
				MovieClip(ROOT).guiEvents.playScrollPosY = MovieClip(ROOT).viewport.verticalScrollPosition;
				//zoomViewport(editZoom, editZoom);
				//MovieClip(ROOT).viewport.scrollTo(editScrollPosX, editScrollPosY, 500);
		
				inventoryWidth = userSetInventoryWidth;	
				MovieClip(ROOT).viewport.verticalScrollPolicy = ScrollPolicy.AUTO;
				MovieClip(ROOT).viewport.horizontalScrollPolicy = ScrollPolicy.AUTO;
				if (MovieClip(ROOT).vBoxPaneRight.width > minInventoryWidth + scrollBarWidth)
				{
					MovieClip(ROOT).vBoxPaneRight.verticalScrollPolicy = ScrollPolicy.AUTO;
				}
				
				adjustLayoutSizes();
			}
		}
		
		public function showLoadingScreen(showSpinner)
		{
			var viewport = MovieClip(ROOT).viewport;
			
			// display loading screen
			
			var loadingScreen = new MovieClip();
			
			var loadingScreenBitmap = new Bitmap(new BitmapData(viewport.width, viewport.height+2, true, 0xFF000000));
			loadingScreen.addChild(loadingScreenBitmap);
		
			if (showSpinner)
			{
				var loadingScreenAnim = new LoadingScreen();
				loadingScreenAnim.x = (viewport.width/2)-(loadingScreenAnim.width/2);
				loadingScreenAnim.y = (viewport.height/2)-(loadingScreenAnim.height/2);
				loadingScreen.addChild(loadingScreenAnim);
			}
			
			loadingScreen.name = "loadingScreen";
		
			viewport.addChild(loadingScreen);
			
		}
		
		public function hideLoadingScreen()
		{
			var viewport = MovieClip(ROOT).viewport;
			
			var timer:Timer = new Timer(1000, 1);
			timer.addEventListener(TimerEvent.TIMER, onTick);
			timer.start();
			
			function onTick(event:TimerEvent):void 
			{
				while (viewport.getChildByName("loadingScreen") != null)
				{
					viewport.removeChild(viewport.getChildByName("loadingScreen"));
				}
				timer.stop();
			}
		}
		
		var heightsInitialized = 0;
		
		public function adjustLayoutSizes()
		{
			MovieClip(ROOT).vBoxPaneTop.x=5;
			MovieClip(ROOT).vBoxPaneTop.y=0;
			MovieClip(ROOT).vBoxPaneTop.width=Stage(STAGE).stageWidth-5;
			MovieClip(ROOT).vBoxPaneTop.height=Stage(STAGE).stageHeight;
			MovieClip(ROOT).vBoxPaneTop.verticalGap = 3;
		
			MovieClip(ROOT).hBoxPane.width=MovieClip(ROOT).vBoxPaneTop.width;
			MovieClip(ROOT).hBoxPane.height=MovieClip(ROOT).vBoxPaneTop.height - 54;
			MovieClip(ROOT).hBoxPane.paddingLeft = 10;
			MovieClip(ROOT).hBoxPane.paddingRight = 10; // no effect ?
			
			/*
			if (LOCK_VIEWPORT_TO_CANVAS_SIZE)
			{
				var canvas_width = MovieClip(getMapCanvas()).width;
				if (this.hBoxPane.width - inventoryWidth - 2*scrollBarWidth > canvas_width)
				{
					inventoryWidth = this.hBoxPane.width - canvas_width - 2*scrollBarWidth;
				}
				var canvas_height = MovieClip(getMapCanvas()).height;
				if (this.hBoxPane.height - chatConsoleHeight - 2*scrollBarWidth > canvas_height)
				{
					chatConsoleHeight = this.hBoxPane.height - canvas_height - 2*scrollBarWidth;
				}
			}
			*/
			
			// heights
			MovieClip(ROOT).chatConsole.height = chatConsoleHeight;
			MovieClip(ROOT).vBoxPaneRight.height=MovieClip(ROOT).hBoxPane.height;
			//MovieClip(ROOT).obj_props.height = minPropsHeight;
			MovieClip(ROOT).vBoxPaneLeft.height=MovieClip(ROOT).hBoxPane.height;
			MovieClip(ROOT).viewport.height = MovieClip(ROOT).vBoxPaneLeft.height - MovieClip(ROOT).chatConsole.height - scrollBarWidth;
			if (heightsInitialized == 0)
			{
			MovieClip(ROOT).inventory_tree.height = (MovieClip(ROOT).vBoxPaneRight.height-minPropsHeight)*0.60 - scrollBarWidth;
			MovieClip(ROOT).layer_list.height = (MovieClip(ROOT).vBoxPaneRight.height-minPropsHeight)*0.25 - scrollBarWidth;
			
			heightsInitialized = 1;
			}
		
			// width
			MovieClip(ROOT).vBoxPaneRight.width = inventoryWidth;
			MovieClip(ROOT).inventory_tree.width = MovieClip(ROOT).vBoxPaneRight.width - scrollBarWidth;
			MovieClip(ROOT).layer_list.width = MovieClip(ROOT).vBoxPaneRight.width - scrollBarWidth;
			MovieClip(ROOT).vBoxPaneLeft.width=MovieClip(ROOT).hBoxPane.width - MovieClip(ROOT).vBoxPaneRight.width - scrollBarWidth;
			MovieClip(ROOT).viewport.width=MovieClip(ROOT).vBoxPaneLeft.width - componentPadding;
			MovieClip(ROOT).chatConsole.width = MovieClip(ROOT).vBoxPaneLeft.width - componentPadding;
			if (MovieClip(ROOT).chatConsole.width > chatMaxWidth) MovieClip(ROOT).chatConsole.width = chatMaxWidth;
			
			// adjust masks
			vBoxPaneRightMask.x = MovieClip(ROOT).viewport.width + 20;
			vBoxPaneRightMask.y = MovieClip(ROOT).vBoxPaneRight.y;
			vBoxPaneRightMask.width = inventoryWidth - 10;
			vBoxPaneRightMask.height = MovieClip(ROOT).vBoxPaneRight.height + 40;
			vChatMask.x = 0;
			vChatMask.y = MovieClip(ROOT).viewport.height + 74 - 10; // 74 is header height
			vChatMask.width = 2000; //MovieClip(ROOT).chatConsole.width;
			
			// design graphics
			MovieClip(ROOT).edit_button_schnipsel.x = MovieClip(ROOT).viewport.width-MovieClip(ROOT).edit_button_schnipsel.width;
			MovieClip(ROOT).edit_button_schnipsel.y = 0;
			
			MovieClip(ROOT).inventory_bg_left.x = MovieClip(ROOT).viewport.width + 15; // was + 7
			MovieClip(ROOT).inventory_bg_left.height = MovieClip(ROOT).vBoxPaneRight.height - 23;
			
			MovieClip(ROOT).inventory_bg_right.x = MovieClip(ROOT).viewport.width + MovieClip(ROOT).vBoxPaneRight.width + 13;
			MovieClip(ROOT).inventory_bg_right.height = MovieClip(ROOT).vBoxPaneRight.height - 23;
			
			MovieClip(ROOT).inventory_bg.x = MovieClip(ROOT).viewport.width + 15 + 8; // 8 is width of left bg border
			MovieClip(ROOT).inventory_bg.width = MovieClip(ROOT).hBoxPane.width - MovieClip(ROOT).viewport.width - 2 - 8 - 13 - 9;
			MovieClip(ROOT).inventory_bg.height = MovieClip(ROOT).vBoxPaneRight.height - 23;
			if (MovieClip(ROOT).inventory_bg.height < 600) MovieClip(ROOT).inventory_bg.height = 600;
			
			MovieClip(ROOT).viewport_border_left.height = MovieClip(ROOT).viewport.height + 3;
			MovieClip(ROOT).shadow_n.x = 0;
			MovieClip(ROOT).shadow_n.y = 0;
			MovieClip(ROOT).shadow_n.width = MovieClip(ROOT).viewport.width;
			MovieClip(ROOT).shadow_e.x = MovieClip(ROOT).viewport.width - MovieClip(ROOT).shadow_e.width;
			MovieClip(ROOT).shadow_e.y = 0;
			MovieClip(ROOT).shadow_e.height = MovieClip(ROOT).viewport.height;
			MovieClip(ROOT).shadow_w.x = 0;
			MovieClip(ROOT).shadow_w.y = 0;
			MovieClip(ROOT).shadow_w.height = MovieClip(ROOT).viewport.height;
			MovieClip(ROOT).shadow_s.x = 0;
			MovieClip(ROOT).shadow_s.y = MovieClip(ROOT).viewport.height - MovieClip(ROOT).shadow_s.height+1;
			MovieClip(ROOT).shadow_s.width = MovieClip(ROOT).viewport.width;
			
			MovieClip(ROOT).chat_bg.y = MovieClip(ROOT).viewport.height + 74 + 3; // header height
			MovieClip(ROOT).chat_bg.width = MovieClip(ROOT).viewport.width + 3;
			MovieClip(ROOT).chat_bg_left.y = MovieClip(ROOT).viewport.height + 74 + 3; // header height
			MovieClip(ROOT).chat_bg_bottom.width = MovieClip(ROOT).viewport.width + 3;
			MovieClip(ROOT).chat_bg_bottom.y = Stage(STAGE).stageHeight - MovieClip(ROOT).chat_bg_bottom.height + 1;
			MovieClip(ROOT).chat_bg_cornerSW.y = Stage(STAGE).stageHeight - MovieClip(ROOT).chat_bg_bottom.height + 0.5;
			
			MovieClip(ROOT).header_bg_right.x = Stage(STAGE).stageWidth - MovieClip(ROOT).header_bg_right.width;
			MovieClip(ROOT).header.fullscreen_button.x = MovieClip(ROOT).header_bg_right.x + 30;
			MovieClip(ROOT).header.search_button.x = MovieClip(ROOT).header.fullscreen_button.x + 30;
			MovieClip(ROOT).header.mute_button.x = MovieClip(ROOT).header.search_button.x + 30;
			MovieClip(ROOT).header.sound_button.x = MovieClip(ROOT).header.search_button.x + 30;
			MovieClip(ROOT).header_bg_middle.width = Stage(STAGE).stageWidth - MovieClip(ROOT).header_bg_left.width - MovieClip(ROOT).header_bg_right.width;
			
			// viewport zoom
			if (MovieClip(ROOT).guiEvents.edit_mode == 0)
			{
				//MovieClip(ROOT).output(MovieClip(ROOT).viewport.width+"/"+fixedViewportWidth);
				
				//viewport.content.scaleX = MovieClip(ROOT).viewport.width/fixedViewportWidth;
				//getMapCanvas().scaleX = MovieClip(ROOT).viewport.width/fixedViewportWidth;
				
				// directly changing w/h on viewport.content will NOT adjust scrollpane scrollbars
				// but by re-setting the viewport-source it will work
				zoomViewport(MovieClip(ROOT).viewport.width/MovieClip(ROOT).guiEvents.fixedViewportWidth, MovieClip(ROOT).viewport.height/MovieClip(ROOT).guiEvents.fixedViewportHeight);
			}
			else
			{
				zoomViewport(MovieClip(ROOT).guiEvents.editZoom, MovieClip(ROOT).guiEvents.editZoom);
			}
		}
		
		public function zoomViewport(factorX, factorY)
		{
			//MovieClip(ROOT).output("zoom to factor: "+viewportContentWidth+"*"+factorX+"="+(viewportContentWidth*factorX)
								//+"  /  "+viewportContentHeight+"*"+factorX+"="+(viewportContentHeight*factorX), 0);
			var bleh = MovieClip(ROOT).viewport.content;
			bleh.scaleX = 1.0;
			bleh.scaleY = 1.0;
			bleh.height = MovieClip(ROOT).guiEvents.viewportContentHeight*factorX;
			bleh.width = MovieClip(ROOT).guiEvents.viewportContentWidth*factorX;
			MovieClip(ROOT).viewport.source = bleh;
		}
		
		public function resizeVBoxLeftDragStartHandler(event:DragEvent):void
		{
			dragStartWidth = MovieClip(ROOT).vBoxPaneRight.width;
		}
		public function resizeVBoxLeftDragUpdateHandler(event:DragEvent):void
		{
			/*
			MovieClip(ROOT).vBoxPaneLeft.width = Math.min(MovieClip(ROOT).vBoxPaneTop.width - 10, Math.max(0, this.dragStartWidth + event.delta));
			MovieClip(ROOT).viewport.width = MovieClip(ROOT).vBoxPaneLeft.width - 10;
			//MovieClip(ROOT).viewport.width = Math.max(0, this.dragStartWidth + event.delta);
			MovieClip(ROOT).vBoxPaneRight.width = MovieClip(ROOT).vBoxPaneTop.width - MovieClip(ROOT).viewport.width - 20;
			MovieClip(ROOT).inventory_tree.width = MovieClip(ROOT).vBoxPaneRight.width -20;
			MovieClip(ROOT).layer_list.width = MovieClip(ROOT).vBoxPaneRight.width -20;
			*/
			var pane_right_width = Math.min(MovieClip(ROOT).vBoxPaneTop.width - 20, Math.max(minInventoryWidth, this.dragStartWidth - event.delta));
			
			if (pane_right_width <= minInventoryWidth + scrollBarWidth)
			{
				MovieClip(ROOT).vBoxPaneRight.verticalScrollPolicy = ScrollPolicy.OFF;
			}
			else
			{
				MovieClip(ROOT).vBoxPaneRight.verticalScrollPolicy = ScrollPolicy.AUTO;
			}
			userSetInventoryWidth = inventoryWidth = pane_right_width;
			adjustLayoutSizes();
		}
		
		public function resizeViewportDragStartHandler(event:DragEvent):void
		{
			this.dragStartWidth = MovieClip(ROOT).chatConsole.height;
		}
		public function resizeViewportDragUpdateHandler(event:DragEvent):void
		{
			var chat_height = Math.min(maxChatHeight, Math.max(minChatHeight, this.dragStartWidth - event.delta));
			//MovieClip(ROOT).chatConsole.height = MovieClip(ROOT).vBoxPaneLeft.height - MovieClip(ROOT).viewport.height - 10;
			
			if (chat_height == maxChatHeight)
			{
				MovieClip(ROOT).chat.hideChatBubble();
			}
			else
			{
				MovieClip(ROOT).chat.showChatBubble();
			}
			
			userSetChatConsoleHeight = chatConsoleHeight = chat_height;
			adjustLayoutSizes();
		}
		public function clickChatHandleHandler(event:MouseEvent):void
		{
			if (chatConsoleHeight > minChatHeight)
			{
				userSetChatConsoleHeight = chatConsoleHeight = minChatHeight;
				vChatMask.height = 0;
				MovieClip(ROOT).chat_bg.visible = false;
				MovieClip(ROOT).chat_bg_left.visible = false;
		
				MovieClip(ROOT).chat.showChatBubble();
			}
			else
			{
				userSetChatConsoleHeight = chatConsoleHeight = maxChatHeight;
				vChatMask.height = maxChatHeight+20;
				MovieClip(ROOT).chat_bg.visible = true;
				MovieClip(ROOT).chat_bg_left.visible = true;
				MovieClip(ROOT).chatConsole.chat_send_button.label = "Send";
				
				MovieClip(ROOT).chat.hideChatBubble();
			}
			
			adjustLayoutSizes();
		}
		
		public function resizeInventoryDragStartHandler(event:DragEvent):void
		{
			dragStartHeight = MovieClip(ROOT).inventory_tree.height;
		}
		public function resizeInventoryDragUpdateHandler(event:DragEvent):void
		{
			MovieClip(ROOT).inventory_tree.height = Math.min(MovieClip(ROOT).vBoxPaneRight.height-114, Math.max(0, this.dragStartHeight + event.delta));
		}
		
		public function resizeLayersDragStartHandler(event:DragEvent):void
		{
			this.dragStartHeight = MovieClip(ROOT).layer_list.height;
		}
		public function resizeLayersDragUpdateHandler(event:DragEvent):void
		{
			MovieClip(ROOT).layer_list.height = Math.min(MovieClip(ROOT).vBoxPaneRight.height-114-MovieClip(ROOT).inventory_tree.height, Math.max(0, this.dragStartHeight + event.delta));
		}


	}
}
