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
	import fl.data.*;
	import flash.net.*;
	import fl.controls.listClasses.CellRenderer;
	
	public class Search extends GlobalStage
	{
		public var searchUrlLoader;
		public var searchDialog = null;
		
		public function Search()
		{
			MovieClip(ROOT).output("INIT: Search has run...", 0);
		}

		public function loadSearchResults(searchText, category)
		{
			searchUrlLoader = new URLLoader(new URLRequest("../server/search.jsp?text="+searchText+"&category="+category));
			searchUrlLoader.addEventListener(Event.COMPLETE, onResultsLoaded);
		}
		
		
		public function onResultsLoaded(event:Event)
		{
			var myResultsProvider = new XML(searchUrlLoader.data);
			
			myResultsProvider.ignoreWhite = true;
			
			if (searchDialog != null)
			{
				searchDialog.searchResults.dataProvider = new DataProvider( myResultsProvider );  
			}
		}
		
		public function setupResultsActions()
		{
			searchDialog.addEventListener(MouseEvent.DOUBLE_CLICK, handleResultsDoubleClick);
		}
		
		public function handleResultsDoubleClick(event:MouseEvent)
		{
			
			if (event.target is CellRenderer)
			{
				
				if (event.target.data.Name != null && event.target.data.Name != "")
				{
					showUserProfile(event.target.data.Name, "");
				}
			}
			
		}
		
		public function showUserProfile(username, objId)
		{
			var profileDialog = new PersonDialog();
			profileDialog.x = 400;
			profileDialog.y = 200;
			Stage(STAGE).addChild(profileDialog);
			
			var profileUrlLoader = new URLLoader(new URLRequest("../server/userprofile.jsp?username="+username+"&objId="+objId));
			profileUrlLoader.addEventListener(Event.COMPLETE, onProfileLoaded);
		
			// loading
			function onProfileLoaded(event:Event)
			{
				var myProfileProvider = new XML(profileUrlLoader.data); 
				MovieClip(ROOT).output(profileUrlLoader.data, 0);
				
				myProfileProvider.ignoreWhite = true;
				
				if (profileDialog != null)
				{
					profileDialog.personName.text = myProfileProvider.username;
				}
			}
		
			// dragging
			function onPressProfile(eventObj:Object):void {
				profileDialog.startDrag();
			}
			profileDialog.title.addEventListener(MouseEvent.MOUSE_DOWN, onPressProfile);
			
			function onReleaseProfile(eventObj:Object):void {
				profileDialog.stopDrag();
			}
			profileDialog.title.addEventListener(MouseEvent.MOUSE_UP, onReleaseProfile);	
			
			// focus
			function onTouchProfile(eventObj:Object):void {
				profileDialog.parent.removeChild(profileDialog);
				Stage(STAGE).addChild(profileDialog);
			}
			profileDialog.addEventListener(MouseEvent.MOUSE_DOWN, onTouchProfile);
			
			// closing 
			function handleClickCloseProfile()
			{
				if (profileDialog != null)
				{
					Stage(STAGE).removeChild(profileDialog);
					profileDialog = null;
				}
			}
			profileDialog.closePersonButton.addEventListener(MouseEvent.CLICK, handleClickCloseProfile);	
			
			// paying
			function handleClickPay()
			{
				MovieClip(ROOT).guiEvents.showPayDialog("", username, username);
			}
			profileDialog.personPayButton.addEventListener(MouseEvent.CLICK, handleClickPay);	
			
			function onReleaseItemOnProfile(event:Event)
			{
				if (MovieClip(ROOT).treeActions.draggingTreeItem != null && MovieClip(ROOT).treeActions.treeDragPic != null)
				{
					var drag_list = GuiFuncs.getSelectedListFromTree(MovieClip(ROOT).inventory_tree, MovieClip(ROOT).treeActions.draggingTreeItemId);
		
					//MovieClip(ROOT).output("put into contents "+draggingTreeItem+" "+draggingTreeItemId+" "+contentsDialog.object_id.text);
					MovieClip(ROOT).editFunctions.edit_giveInventoryToUser(drag_list, profileDialog.personName.text);
				}
				MovieClip(ROOT).treeActions.clearTreeDrag();
				
				if (MovieClip(ROOT).objectContents.draggingContentsItem != null && MovieClip(ROOT).objectContents.contentsDragPic != null)
				{
					
				}
				MovieClip(ROOT).objectContents.clearContentsDrag();
				
			}
			profileDialog.personDroptarget.addEventListener(MouseEvent.MOUSE_UP, onReleaseItemOnProfile);
			
		}
	}
}
