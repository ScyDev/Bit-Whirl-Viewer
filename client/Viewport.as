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
	
    import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.MovieClip;
    import flash.events.Event;
	import fl.containers.ScrollPane;
	
	public class Viewport extends fl.containers.ScrollPane
	{
		public var activeTarget:Number = 0;
		public var targetX:Number = 0;
		public var targetY:Number = 0;
		var pathwalker:PathWalker;
		
		var objCleanupStepCounter = 0;
		var objCleanupStepInterval = 100; // roughly every 4 seconds 100/24

		private static var initialized:Boolean = false;  // marks whether or not the class has been initialized
		
		public function Viewport()
		{
			stage.addEventListener(Event.ENTER_FRAME, checkObjectsInViewportBoundary);
		}

		public static function initialize(stage:Stage) {
            if (!initialized) {
                // assign listeners 
               
                
                // mark initialization as true so redundant
                // calls do not reassign the event handlers
                initialized = true;
            }
        }
		
	
		public function scrollTo(new_x, new_y, new_speed)
		{
			this.activeTarget = 1;
		
			this.targetX = new_x;
			if (this.targetX > this.maxHorizontalScrollPosition)
			{
				this.targetX = this.maxHorizontalScrollPosition;
			}
			if (this.targetX < 0) this.targetX = 0;
			this.targetX = Math.floor(this.targetX);
			
			this.targetY = new_y;
			if (this.targetY > this.maxVerticalScrollPosition)
			{
				this.targetY = this.maxVerticalScrollPosition;
			}
			if (this.targetY < 0) this.targetY = 0;
			this.targetY = Math.floor(this.targetY);
			
			pathwalker = new PathWalker(this.horizontalScrollPosition, this.verticalScrollPosition, this.targetX, this.targetY, new_speed, -1);
			//output("scrollTo called!");
			
			stage.removeEventListener(Event.ENTER_FRAME, onEveryFrame);
			stage.addEventListener(Event.ENTER_FRAME, onEveryFrame);
		}
		
		public function onEveryFrame(event:Event) 
		{
			// MOVEMENT
			if (this.activeTarget == 1)
			{
				pathwalker.nextStep();
				
				//output(pathwalker.currX+" "+pathwalker.currY);
				
				this.horizontalScrollPosition = pathwalker.currX;
				this.verticalScrollPosition = pathwalker.currY;
				
				//MovieClip(root).output("scrolling...", 0);
				//checkObjectsInViewportBoundary();
				
				// remove event handler if at target (must be made more sensoble in the future, if more things than movement happen)
				// MovieClip(root).output(this.horizontalScrollPosition+" -> "+this.targetX+" / "+this.verticalScrollPosition+" -> "+this.targetY, 0);
				if (this.horizontalScrollPosition == this.targetX && this.verticalScrollPosition == this.targetY)
				{
					//this.onEnterFrame = null;
					this.activeTarget = 0;
					//MovieClip(root).output("SCROLLED!!", 0);
					stage.removeEventListener(Event.ENTER_FRAME, onEveryFrame);
				}
			}
		
		}		
		
		public function checkObjectsInViewportBoundary(event:Event)
		{
			this.objCleanupStepCounter++;
			//MovieClip(root).output("viewport step counter "+this.objCleanupStepCounter+"/"+this.objCleanupStepInterval, 0);
			if (MovieClip(root).guiEvents.autoUnloadObjects == true && this.objCleanupStepCounter >= this.objCleanupStepInterval)
			{
				//MovieClip(root).output("check for far away objects...", 0);
				this.objCleanupStepCounter = 0;
					
				var viewDistance = Math.max(this.width, this.height);
				var relToX = this.horizontalScrollPosition + (this.width/2);
				var relToY = this.verticalScrollPosition + (this.height/2);
				//MovieClip(root).output("out of bounds rel to: "+relToX+"/"+relToY, 0);

				var mapCanvas = DisplayObjectContainer(this.content).getChildByName("mapCanvas");
				///////////////
/*
				var border = 0;
				mapCanvas.graphics.clear();
				mapCanvas.graphics.lineStyle(2, 0xFF0000, 100);
				mapCanvas.graphics.beginFill(0xFF0000, 0.1);
				mapCanvas.graphics.moveTo(0+border, 0+border);
				mapCanvas.graphics.drawCircle(relToX, relToY, viewDistance);
				*/
				////////////////
				
				if (mapCanvas != null)
				{
					var numObjects = mapCanvas.numChildren;
					var objsToRemove = new Array();
					
					for (var i = 0; i < numObjects; i++)
					{
						var currObj = mapCanvas.getChildAt(i);
						if (currObj is InfilionMovieClip && currObj.asAvatar == 0 
							&& ((new Date().getTime())-currObj.refreshedTime > 30*1000)
							)
						{
							/*
							// find nearest corner of obj
							var xCandidate = currObj.x;
							var yCandidate = currObj.y;
							var currDistance = Math.abs(xCandidate-relToX) + Math.abs(yCandidate-relToY);
							
							if (Math.abs(currObj.x-relToX) + Math.abs(currObj.y+currObj.height-relToY) < currDistance)
							{
								xCandidate = currObj.x;
								yCandidate = currObj.y+currObj.height;
								currDistance = Math.abs(xCandidate-relToX) + Math.abs(yCandidate-relToY);
							}
							
							if (Math.abs(currObj.x+currObj.width-relToX) + Math.abs(currObj.y-relToY) < currDistance)
							{
								xCandidate = currObj.x+currObj.width;
								yCandidate = currObj.y;
								currDistance = Math.abs(xCandidate-relToX) + Math.abs(yCandidate-relToY);
							}
							
							if (Math.abs(currObj.x+currObj.width-relToX) + Math.abs(currObj.y+currObj.height-relToY) < currDistance)
							{
								xCandidate = currObj.x+currObj.width;
								yCandidate = currObj.y+currObj.height;
								currDistance = Math.abs(xCandidate-relToX) + Math.abs(yCandidate-relToY);
							}
							*/
							
							// check if it is too far away
							var xDistance = Math.abs(currObj.x-relToX);
							var yDistance = Math.abs(currObj.y-relToY);
							var straightDistance = Math.sqrt(Math.pow(xDistance, 2) + Math.pow(yDistance, 2));
							
							//MovieClip(root).output("out of bounds check: "+currObj.inflObjName+" ("+currObj.inflObjId+") "+currObj.x+"/"+currObj.y, 0);
							//MovieClip(root).output("straightDistance:"+straightDistance+" viewDistance:"+viewDistance, 0);
							
							if (straightDistance > viewDistance)
							{
								//MovieClip(root).output("is bigga!", 0);
								if (currObj.outOfBoundsTime > -1 && (new Date().getTime())-currObj.outOfBoundsTime > 10*1000)
								{
									//MovieClip(root).output("remove: "+currObj.inflObjId, 0);
									// queue for removal
									objsToRemove.push(currObj.inflObjId);
								}
								else if (currObj.outOfBoundsTime == -1) // the moment that the object went out of bounds
								{
									//((MovieClip(root).output("set out of bounds: "+currObj.inflObjId, 0);
									currObj.outOfBoundsTime = new Date().getTime();
								}
							}
						}
						
						currObj = null;
					}
					
					// remove them for real
					for (var i = 0; i < objsToRemove.length; i++)
					{
						//MovieClip(root).output("del cuz far away "+InfilionMovieClip(currObj).inflObjName, 0);
						//MovieClip(root).output("RLY remove: "+objsToRemove[i], 0);
						//MovieClip(root).removeFromZOrder(currObj);
						//mapCanvas.removeChild(currObj);
						MovieClip(root).javaCallableFunctions.update_removeObj(objsToRemove[i]);
									
						//MovieClip(root).output("removed!", 0);
					}
					objsToRemove = null;
					
					//MovieClip(root).output("+-----------------------------------------------+", 0);
					
				}
				mapCanvas = null;
			}
		}
				
	}
}
