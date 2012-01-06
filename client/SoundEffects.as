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
	import flash.media.*;
	
	
	public class SoundEffects extends GlobalStage
	{
		public var loadedSounds = new Object();
		public var playingSounds = new Object();
		
		public var muted = false;
		public var volumeSoundTransform = new SoundTransform(1.0);
		
		
		public function SoundEffects()
		{
			
			
			MovieClip(ROOT).output("INIT: SoundEffects has run...", 0);
		}

		public function setMute(mute)
		{
			muted = mute;
			
			
			if (mute != true)
			{
				volumeSoundTransform = new SoundTransform(1.0);
			}				
			else
			{
				volumeSoundTransform = new SoundTransform(0.0);
			}
			
			for each (var channel:SoundChannel in playingSounds)
			{
					if (channel != null)
					{
						channel.soundTransform = volumeSoundTransform;
					}
			}
		}

	}
}
