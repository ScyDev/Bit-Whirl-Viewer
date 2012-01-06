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
	import flash.text.*;

	import flash.utils.*;
	
	
	public class Chat extends GlobalStage
	{
		
		public var chatBubble;
		public var chatBubbleBackground;
		public var MIN_BG_WIDTH = 400;
		public var myTimer:Timer;
		public var showChat = true;
		
		
		public function Chat()
		{
			
			
			MovieClip(ROOT).output("INIT: Chat has run...", 0);
		}

		public function displayChatBubble(theText:String)
		{
			if (chatBubble == null)
			{
				chatBubble = new TextField();
				chatBubble.name = "chatBubble";
				
				chatBubble.x = 50;
				chatBubble.y = 100;
				chatBubble.autoSize = TextFieldAutoSize.LEFT;
				chatBubble.opaqueBackground = null;//0xFF00FF;
				chatBubble.background = false;
				//chatBubble.backgroundColor = 0xFF00FF;
		
		
				var format:TextFormat = new TextFormat();
				format.font = "Verdana";
				format.color = 0x000000;
				format.size = 16;
				//format.underline = true;
				chatBubble.defaultTextFormat = format;
				
				// Create a new Timer object with a delay of 500 ms
				myTimer = new Timer(3000);
				myTimer.addEventListener("timer", onChatBubbleTimer);
				
				//chatBubbleBackground = new ChatBubbleBackground();
				chatBubbleBackground = new MovieClip();
				chatBubbleBackground.x = chatBubble.x-10;
				chatBubbleBackground.y = chatBubble.y-10;
				
				// Start the timer
				myTimer.start();		
				
				if (showChat)
				{
					MovieClip(ROOT).addChild(chatBubbleBackground);
					MovieClip(ROOT).addChild(chatBubble);
				}
			}
			chatBubble.text += "\n"+theText;
			
			adjustChatBubbleBackground();
			
		}
		
		public function showChatBubble()
		{
			showChat = true;
			if (chatBubble != null)
			{
				adjustChatBubbleBackground();
				
				MovieClip(ROOT).addChild(chatBubbleBackground);
				MovieClip(ROOT).addChild(chatBubble);
			}
		}
		
		public function hideChatBubble()
		{
			showChat = false;
			if (chatBubble != null)
			{
				chatBubble.parent.removeChild(chatBubbleBackground);
				chatBubble.parent.removeChild(chatBubble);
				
			}
		}
		
		public function onChatBubbleTimer(eventArgs:TimerEvent)
		{
			if (chatBubble != null)
			{
				var theText = chatBubble.text;
				var theIndex = theText.indexOf("\r");
				
				myTimer.delay = 1000;
				
				if (theIndex >= 0)
				{
					chatBubble.text = theText.substring(theIndex+1, theText.length);
		
					adjustChatBubbleBackground();
				}
				else
				{
					//chatBubble.text = "";
					if (chatBubble.parent != null)
					{
						chatBubble.parent.removeChild(chatBubbleBackground);
						chatBubble.parent.removeChild(chatBubble);
						
					}
					chatBubble = null;
					myTimer.stop();
				}
				
			}
		}
		
		public function adjustChatBubbleBackground()
		{
			var w = chatBubble.width + 20;
			if (w < MIN_BG_WIDTH) w = MIN_BG_WIDTH;
			var h = chatBubble.height + 20;
		
			drawRoundedRectangle(chatBubbleBackground, w, h, 15, 0x888888, 0.7);
		}
		
		public function drawRoundedRectangle(target_mc:MovieClip, boxWidth:Number, boxHeight:Number, cornerRadius:Number, fillColor:Number, fillAlpha:Number) {
		
			target_mc.graphics.clear();
			
				target_mc.graphics.beginFill(fillColor, fillAlpha);
				target_mc.graphics.moveTo(cornerRadius, 0);
				target_mc.graphics.lineTo(boxWidth - cornerRadius, 0);
				target_mc.graphics.curveTo(boxWidth, 0, boxWidth, cornerRadius);
				target_mc.graphics.lineTo(boxWidth, cornerRadius);
				target_mc.graphics.lineTo(boxWidth, boxHeight - cornerRadius);
				target_mc.graphics.curveTo(boxWidth, boxHeight, boxWidth - cornerRadius, boxHeight);
				target_mc.graphics.lineTo(boxWidth - cornerRadius, boxHeight);
				target_mc.graphics.lineTo(cornerRadius, boxHeight);
				target_mc.graphics.curveTo(0, boxHeight, 0, boxHeight - cornerRadius);
				target_mc.graphics.lineTo(0, boxHeight - cornerRadius);
				target_mc.graphics.lineTo(0, cornerRadius);
				target_mc.graphics.curveTo(0, 0, cornerRadius, 0);
				target_mc.graphics.lineTo(cornerRadius, 0);
				target_mc.graphics.endFill();
		
		}


	}
}
