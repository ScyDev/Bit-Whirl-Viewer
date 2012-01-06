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

package {
	
public class PathWalker
{
	public var currX:Number = 0;
	public var currY:Number = 0;

	var startX:Number = 0;
	var startY:Number = 0;
	var endX:Number = 0;
	var endY:Number = 0;
	var speed:Number = 0;
	
	var dirX:Number = 1;
	var dirY:Number = 1;
	
	var movementStartTime = 0;
	var projectedDurationMillis = -1;
			
	var travelSpeedX:Number = 0.0;
	var travelSpeedY:Number = 0.0;
	var progressX:Number = 0.0;
	var progressY:Number = 0.0;
	var distanceX:Number = 0.0;
	var distanceY:Number = 0.0;
	var realDistance:Number = 0.0;
	
	public function PathWalker(inStartX:Number, inStartY:Number, inEndX:Number, inEndY:Number, inSpeed:Number, projected_duration_millis:Number)
	{
		currX = inStartX;
		currY = inStartY;

		startX = inStartX;
		startY = inStartY;
		endX = inEndX;
		endY = inEndY;
		speed = inSpeed;
		
		this.movementStartTime = new Date().valueOf();
		this.projectedDurationMillis = projected_duration_millis;
		
		if (endX < startX) dirX = -1;
		if (endY < startY) dirY = -1;
		
		// calc x and y step size
		distanceX = Math.abs(startX - endX);
		distanceY = Math.abs(startY - endY);
		//realDistance = Math.sqrt(Math.pow(distanceX, 2)+Math.pow(distanceY, 2));
		realDistance = distanceX+distanceY;
		
		travelSpeedX = (distanceX/realDistance)*speed;
		if (travelSpeedX < 1)
		{
			travelSpeedX = 1;
		}
		travelSpeedY = (distanceY/realDistance)*speed;
		if (travelSpeedY < 1)
		{
			travelSpeedY = 1;
		}
		
		trace(inStartX+" "+inStartY+" "+endX+" "+endY+" "+speed+" "+distanceX+" "+distanceY+" "+realDistance+" "+travelSpeedX+" "+travelSpeedY);
	}
	
	public function getCurrX():Number 
	{
  		return currX;
	}

	public function getCurrY():Number 
	{
  		return currY;
	}


	
	public function nextStep()
	{
		var distanceLeftX:Number = Math.abs(this.currX - this.endX);
		var distanceLeftY:Number = Math.abs(this.currY - this.endY);
		
		trace("next step "+this.currX+" "+this.currY+" "+distanceLeftX+" "+distanceLeftY);
		
		if (projectedDurationMillis > -1)
		{
			// calc the part of distance that should be travelled by this time
			var timeElapsed = new Date().valueOf() - this.movementStartTime;
			if (timeElapsed > projectedDurationMillis) timeElapsed = projectedDurationMillis;
			var partOfDistByThisTime = timeElapsed/projectedDurationMillis;
			
			// timebased movement
			if (partOfDistByThisTime == 1)
			{
				currX = int(endX);
				currY = int(endY);
			}
			else
			{
				currX = int((startX + (distanceX * partOfDistByThisTime * dirX)));
				currY = int((startY + (distanceY * partOfDistByThisTime * dirY)));
			}
		}
		else
		{
			// framebased movement
			
			// X movement
			if (distanceLeftX < travelSpeedX)
			{
				currX = int(endX);
			}
			else if (currX < endX)
			{
				progressX += travelSpeedX;
				currX = startX+progressX;
			}
			else if (currX > endX)
			{
				progressX -= travelSpeedX;
				currX = startX+progressX;
			}
			
			// Y movement
			if (distanceLeftY < travelSpeedY)
			{
				currY = int(endY);
			}
			else if (currY < endY)
			{
				progressY += travelSpeedY;
				currY = startY+progressY;
			}
			else if (currY > endY)
			{
				progressY -= travelSpeedY;
				currY = startY+progressY;
			}
		}
	}
	
	
}

}
