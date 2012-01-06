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
	import fl.data.*;
	import flash.text.*;
	import flash.display.*;

	import fl.controls.listClasses.CellRenderer;
	
	
	public class LayerList extends GlobalStage
	{
		public var layerUrlLoader;
		
		public var draggingLayerListItem = null;
		public var lastSelectedLayerListItem = null;

		
		public function LayerList()
		{
						
			Key.initialize(Stage(STAGE));
			
			MovieClip(ROOT).layer_list.addEventListener(Event.CHANGE, listListenerChange);
			MovieClip(ROOT).layer_list.addEventListener(MouseEvent.MOUSE_DOWN, onPressItem);
			MovieClip(ROOT).layer_list.addEventListener(MouseEvent.MOUSE_UP, onReleaseItem);
			
			MovieClip(ROOT).output("INIT: LayerList has run...", 0);
		}
		
		public function loadLayerList()
		{
			if (MovieClip(ROOT).host != null)
			{
				layerUrlLoader = new URLLoader(new URLRequest("https://"+MovieClip(ROOT).host+"/app/server/layer_list.jsp"));
			}
			else
			{
				layerUrlLoader = new URLLoader(new URLRequest("../server/layer_list.jsp"));
			}
			layerUrlLoader.addEventListener(Event.COMPLETE, onLayerLoaded);
		}
		
		
		
		public function onLayerLoaded(event:Event)
		{
			var myLayerProvider = new XML(layerUrlLoader.data); 
			
			myLayerProvider.ignoreWhite = true;
			
			MovieClip(ROOT).layer_list.dataProvider = new DataProvider( myLayerProvider );  
		
			/*
			var orderZOrder = zOrder;
			
			// fill zOrder from layerlist
			MovieClip(ROOT).output("layer_list: "+layer_list, 0);
			if (layer_list != null)
			{
				orderZOrder = new Array();
				for (var i = layer_list.length-1; i >= 0; i--)
				{
					var llItem = layer_list.getItemAt(i);
					//MovieClip(ROOT).output("llItem: "+llItem, 0);
					//MovieClip(ROOT).output("llItem: "+llItem+" llItem.data: "+llItem.data, 0);
					MovieClip(ROOT).output("llItem: "+llItem+" llItem.id: "+llItem.id, 0);
					//MovieClip(ROOT).output("itemToCellRenderer: "+layer_list.itemToCellRenderer(llItem), 0);
					if (llItem.id != null)
					{
						var objId = llItem.id;
						orderZOrder.push(objId);
					}
				}
			}
			*/
		}
		
		// LIST EVENTS
		public function listListenerChange(eventObject:Event)
		{
			var concernedMC = MovieClip(ROOT).guiEvents.getObjectFromMap(eventObject.target.selectedItem.id);
			//concernedMC = eventObject.target.selectedItem;
			
			//MovieClip(ROOT).output("list: "+concernedMC);
			GuiFuncs.deleteFocusObjectId = eventObject.target.selectedItem.id;
			if (concernedMC != null)
			{
				MovieClip(ROOT).javaCallableFunctions.update_scrollView(concernedMC.x-200, concernedMC.y-200, 100);
				GuiFuncs.drawEditHandles(concernedMC);
				GuiFuncs.currSelectedClip = concernedMC;
				
				GuiFuncs.updateObjProps(concernedMC);
			}
		
		}
		
		
		public function onPressItem(event:Event)
		{
			draggingLayerListItem = event.target;
			if (draggingLayerListItem instanceof CellRenderer)
			{
				Sprite(draggingLayerListItem).startDrag();
			}
			
		}
		
		public function onReleaseItem(event:Event)
		{
			if (draggingLayerListItem != null)
			{
				draggingLayerListItem.stopDrag();
		
				
				if (draggingLayerListItem.dropTarget instanceof TextField && draggingLayerListItem.dropTarget.parent instanceof CellRenderer)
				{
					var listDropTarget = draggingLayerListItem.dropTarget.parent;
					
					if (listDropTarget.data.id != draggingLayerListItem.data.id)
					{
						MovieClip(ROOT).editFunctions.edit_changeObjectZ(draggingLayerListItem.data.id, 1, listDropTarget.data.id);
					}
				}
		
					/*var droppedOn:Sprite = draggingLayerListItem.dropTarget as Sprite;
				var mousePoint:Point = new Point(layer_list.mouseX, layer_list.mouseY);
				mousePoint = layer_list.localToGlobal(mousePoint);
				var objs = layer_list.getObjectsUnderPoint(mousePoint);
				
				for (var i = 0; i < objs.length; i++)
				{
					//MovieClip(ROOT).output(i+":"+objs[i]);
					
					if (objs[i] instanceof TextField)
					{
						
						var label = objs[i].text;
						var id_from_label = label.substring(label.indexOf(":")+1, label.length);
						//MovieClip(ROOT).output("id_from_label: "+id_from_label);
						if (id_from_label != draggingLayerListItem.data.id)
						{
							edit_changeObjectZ(draggingLayerListItem.data.id, 1, id_from_label);
						}
					}
		
				}*/
				
			}
		}
		
		public function setSelectedLayer(selected)
		{
			MovieClip(ROOT).layer_list.selectedItem = selected;
		}
		

	}
}
