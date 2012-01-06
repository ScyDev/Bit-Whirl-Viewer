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
	 import flash.events.Event;	
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	public class BitmapSprite extends Sprite
	{
		private var BitmapDataTile:BitmapData;
		private var BitmapDataArray:Array;
		
		private var copyRectangle:Rectangle;
		private var copyPoint:Point;
		private var transformMatrix:Matrix;
		
		private var _w:Number;
		private var _h:Number;
		private var _frames:Number;
		private var _fps:Number;
		private var _frameStep:Number;
		private var _frameSkipCounter:Number;
		private var xScale:Number;
		private var yScale:Number;
		private var rotScale:Number;
		
		public var internFrameCounter:Number = 0;
		
		public var theSource:Bitmap;
		public var theTarget:Bitmap;
		
		private var stepX:Number;
		private var stepY:Number;
		private var stepRot:Number;
		
		private var outputChan;
		private var theStage;
		
		/*
		public function BitmapSprite(mc:MovieClip)
		{
			MovieClip(mc.root).output("bleeeee!!");
		}*/
	
		public function BitmapSprite(stageRef, outputRef)
		{
			outputChan = outputRef;
			theStage = stageRef;
		}
		
		public function initBitmapSprite(sourceMc, target, w, h, tileX, tileY, startFrame, endFrame, fps)
		{
			//outputChan("0");
		
			theSource = sourceMc;
			theTarget = target;
			_fps = fps;
			if (theStage.frameRate > fps)
			{
				_frameStep = Math.ceil(theStage.frameRate / fps);
			}
			else
			{
				_frameStep = 1;
			}
			_frameSkipCounter = _frameStep; // so first frame is drawn immediately
			
			_frames = endFrame-startFrame;
			if (_frames < 1)
			{
				_frames = 1;
			}
			_w = w
			_h = h
			BitmapDataArray = []
			
			copyRectangle = new Rectangle(0,0,_w,_h)
			var tileCount = 0;
		
			for (var e=0; e<tileY; e++)
			{
			for (var i=0; i<tileX; i++)
			{
				if (tileCount >= startFrame && tileCount <= endFrame)
				{
					BitmapDataTile = new BitmapData(w, h, true, 0x00FFFFFF);
	
					BitmapDataTile.copyPixels(sourceMc.bitmapData, new Rectangle(i*w, e*h, w, h), new Point(0, 0), null, null, false);
					BitmapDataArray.push(BitmapDataTile);
					
					BitmapDataTile = null;
				}
				tileCount++;
			}
			}
			
			theStage.addEventListener(Event.ENTER_FRAME, drawMyself, false, 0, true);
			
			drawMyself(null);
		}
		
		public function removeEnterFrameEvent()
		{
			outputChan("removing sprite event listener", 0);
			theStage.removeEventListener(Event.ENTER_FRAME, drawMyself);
		}
		
		public function getFrames():int
		{
			return _frames
		}
		
		public function getBitmap(position:Number)
		{
			if (position < 0) position = 0
			if (position >= BitmapDataArray.length) position = BitmapDataArray.length-1
			
			return BitmapDataArray[position]

		}
		
		public function getWidth():Number
		{
			return _w
		}
		public function getHeight():Number
		{
			return _h
		}
		
		public function drawMyself(event:Event)
		{
			if (_frameSkipCounter >= _frameStep)
			{
				internFrameCounter++;
				if (internFrameCounter >= BitmapDataArray.length) 
				{
					internFrameCounter = 0
				}
				
				//MovieClip(theTarget.parent.root).output("draw Myself.... frame:"+internFrameCounter);
				draw(theTarget.bitmapData, 0, 0, internFrameCounter);
				
				_frameSkipCounter = 0;
			}
			else
			{
				_frameSkipCounter++;
			}
		}
		
		public function draw(target:BitmapData, x:Number, y:Number, position:int)
		{
			if (position < 0) position = 0;
			if (position >= BitmapDataArray.length) position = BitmapDataArray.length-1;
			
			//MovieClip(theMc.parent.root).output("draw "+getBitmap(position)+" to ...."+target);
			
			copyPoint = new Point(x, y);
			var newBitmapData = getBitmap(position);
			
			if (newBitmapData != null)
			{
				//var targetData = target.bitmapData;
				target.fillRect(copyRectangle, 0x00FFFFFF);
				target.copyPixels(getBitmap(position), copyRectangle, copyPoint, null, null, true);
				//target.bitmapData = targetData;
			}
			else
			{
				target.fillRect(copyRectangle, 0xFFFFFFFF);
				outputChan("Invalid animation frame settings on object!", 1);
			}
			newBitmapData = null;
			
			//target.floodFill(10, 10, 0x000000FF);
			//MovieClip(theMc.parent.root).output("drawed! "+getBitmap(position).toString()+" rect:"+copyRectangle.width+"x"+copyRectangle.height);
			return;
		}
		
	}
}
