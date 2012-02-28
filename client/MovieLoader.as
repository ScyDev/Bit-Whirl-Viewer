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
	import flash.system.*;
	
	
	public class MovieLoader extends GlobalStage
	{
		public var loadedGfx = new Object();
		public var objectsToLoad = 10000000000; // extra high, so it will really only get down to 0 after being initialized with proper object count from server
		
		
		public function MovieLoader()
		{
			
			
			MovieClip(ROOT).output("INIT: MovieLoader has run...", 0);
		}

		
		public function loadImage(concernedClip, objUrl, subObjName)
		{
			// caching only works for bitmaps, for we can copy the bitmap data.
			// cloning MovieClips is not naturally supported in AS3
			// possible solution: http://www.dannyburbol.com/2009/01/movieclip-clone-flash-as3/
			MovieClip(ROOT).output("loadedGfx[objUrl]: "+objUrl+" -> "+loadedGfx[objUrl], 1);
				
			if (loadedGfx[objUrl] != null && loadedGfx[objUrl] is Bitmap)
			{			
				var existingGfx:Bitmap = loadedGfx[objUrl] as Bitmap;
				
				var date = new Date();
				MovieClip(ROOT).output("YEAH FOUND LOADED: "+objUrl+" - "+existingGfx.bitmapData+"  "+date.getMinutes()+":"+date.getSeconds()+"."+date.getMilliseconds(), 1);
				
				var copyGfx = new Bitmap(existingGfx.bitmapData, "auto", true);
				copyGfx.visible = true;
				//copyGfx.width = existingGfx.width; // necessary?
				//copyGfx.height = existingGfx.height;
				
				copyGfx.name = subObjName;
				concernedClip.addChild(copyGfx); // should happen in setThatImage(), but dont work down there
				setThatImage(concernedClip, copyGfx);
				copyGfx = null;
				existingGfx = null;
				
				// necessary? this lead to image having different scale when copy is put on
				//concernedClip.resizeMyself(concernedClip.desiredWidth, concernedClip.desiredHeight, concernedClip.x, concernedClip.y);
				
				MovieClip(ROOT).output(concernedClip.desiredWidth+"/"+concernedClip.desiredHeight+" - "+concernedClip.width+"/"+concernedClip.height+" - "+concernedClip.x+"/"+concernedClip.y, 0);
			} /*
			else if (loadedGfx[objUrl] != null && loadedGfx[objUrl] is MovieClip) // MainTimeline = a loaded swf
			{
				MovieClip(ROOT).output("olo", 1);
				var existingSwf = loadedGfx[objUrl];
				MovieClip(ROOT).output("Dafuq!?", 1);
				
				var date = new Date();
				MovieClip(ROOT).output("YEAH FOUND SWF: "+objUrl+" - "+existingSwf+"  "+date.getMinutes()+":"+date.getSeconds()+"."+date.getMilliseconds(), 1);

				var sourceClass:Class = Object(existingSwf).constructor;
				var copySwf = new sourceClass();				
				copySwf.visible = true;
				copySwf.width = existingSwf.width;
				copySwf.height = existingSwf.height;
				
    copySwf.transform = existingSwf.transform;
    copySwf.filters = existingSwf.filters;
    copySwf.cacheAsBitmap = existingSwf.cacheAsBitmap;
    copySwf.opaqueBackground = existingSwf.opaqueBackground;
				
				copySwf.name = subObjName;
				concernedClip.addChild(copySwf); // should happen in setThatImage(), but dont work down there
				//copySwf.prevScene();
				copySwf.gotoAndPlay(1);
				setThatImage(concernedClip, copySwf);
				copySwf = null;
				existingSwf = null;
				
				concernedClip.resizeMyself(concernedClip.desiredWidth, concernedClip.desiredHeight, concernedClip.x, concernedClip.y);
			}			*/
			else
			{
				var date = new Date();
				MovieClip(ROOT).output(":( FOUND no cached: "+objUrl+" - "+existingGfx+"  "+date.getMinutes()+":"+date.getSeconds()+"."+date.getMilliseconds(), 1);
				
				var currMcl = new Loader();
				currMcl.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderOnLoadComplete, false, 0, true);
				currMcl.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
				var loaderContext = new LoaderContext();
				loaderContext.checkPolicyFile = true;
				currMcl.load(new URLRequest(objUrl), loaderContext);
				currMcl.name = subObjName;
				concernedClip.addChild(currMcl);
				
				loaderContext = null;
				currMcl = null;
			}
	
		}
		
		public function loaderOnLoadComplete(event:Event) 
		{
			var date = new Date();
			MovieClip(ROOT).output("IMG LOADED! "+date.getMinutes()+":"+date.getSeconds()+"."+date.getMilliseconds(), 0);
			
			if (!event.target.childAllowsParent)
			{
				MovieClip(ROOT).output("ERROR: no valid policy file for image lodaing found ("+event.target.childAllowsParent+")", 0);
			}
			
			var loaded_mc = event.target.content;
			loaded_mc.smoothing = true;
			
			//MovieClip(ROOT).output("typeof "+(typeof loaded_mc)+" "+loaded_mc+" dimensions: "+loaded_mc.width+"/"+loaded_mc.height, 1);
			
			//MovieClip(ROOT).output("putting to cache: "+loaded_mc+": "+loaded_mc.parent.contentLoaderInfo.url+" obj("+InfilionMovieClip(loaded_mc.parent.parent).inflObjId+")", 0);
			loadedGfx[loaded_mc.parent.contentLoaderInfo.url] = loaded_mc;
				
			if (loaded_mc.parent != null && loaded_mc.parent.parent != null)
			{
				var concernedClip:InfilionMovieClip = InfilionMovieClip(loaded_mc.parent.parent);
				//var mcl = loaded_mc.parent;
				
				//MovieClip(ROOT).output(concernedClip.inflObjName+" / "+loaded_mc.parent.contentLoaderInfo.url+" -> orig dimensions: "+loaded_mc.width+"/"+loaded_mc.height, 1);
				setThatImage(concernedClip, loaded_mc);
				concernedClip = null;
				
				//mcl.parent.removeChild(mcl); // this breaks loading images.. why? atfers its already been added as child?		
				//loaded_mc.parent.parent.removeChild(loaded_mc.parent);
			}
			
			objectsToLoad--;
			//MovieClip(ROOT).output("objectsToLoad "+objectsToLoad, 0);
			if (objectsToLoad <= 0)
			{
				//update_mapLoaded();
			}
			
			loaded_mc = null;
		}
		
		public function setThatImage(concernedClip, loaded_mc)
		{
			// clean up to prevent memory leak.. seems to work a bit.. at least for garbage collector in debug plugin..
			// NO DON?T WORK
			/*
			if (concernedClip.bitmapSprite != null)
			{
				concernedClip.bitmapSprite.theSource = null;
				concernedClip.bitmapSprite.theTarget = null;
				delete concernedClip.bitmapSprite;
				concernedClip.bitmapSprite = null;
			}
			if (concernedClip.getChildByName("spriteRepresentation") != null)
			{
				concernedClip.removeChild(concernedClip.getChildByName("spriteRepresentation"));
			} 
			*/
			/////////////
			
			//MovieClip(ROOT).output(concernedClip+" _ "+loaded_mc+" _ sprite:"+concernedClip.isSprite, 0);
			
			if (concernedClip.isSprite == 0)
			{
	
				//MovieClip(ROOT).output("setting img as normal", 0);
				//concernedClip.addChild(loaded_mc); // DONT WORK HERE.... no clue why. have to do it before setThatImage() call
				
				concernedClip.scaleX = 1.0; // important for when the new image has another resolution than the old
				concernedClip.scaleY = 1.0;
				loaded_mc.width = concernedClip.desiredWidth;
				loaded_mc.height = concernedClip.desiredHeight;
	
			}
			else if (concernedClip.isSprite == 1)
			{
				//MovieClip(ROOT).output("setting img as sprite", 0);
				var spriteW = loaded_mc.width/concernedClip.tileX;
				var spriteH = loaded_mc.height/concernedClip.tileY;
				
				// i'd think that it's enough to add the Sprite, that it's draw() public function will be called automagically...
				// but aparently not so. so we give it a target BitmapData to draw to.
				if (concernedClip.getChildByName("spriteRepresentation") != null)
				{
					//MovieClip(ROOT).output("renaming current sprite rep", 0);
					concernedClip.getChildByName("spriteRepresentation").name = "spriteRepresentation_old";
				} 
	
				var spriteMc:Bitmap = new Bitmap(new BitmapData(spriteW, spriteH, true, 0x00FFFFFF));
				spriteMc.name = "spriteRepresentation";
				spriteMc.smoothing = true;
				
				//MovieClip(ROOT).output("mc and imc: "+loaded_mc+" "+concernedClip+" / "+concernedClip.tileX+" "+concernedClip.tileY+" "+concernedClip.framesCount);
				var sprite:BitmapSprite = new BitmapSprite(Stage(STAGE), MovieClip(ROOT).output);
				sprite.initBitmapSprite(loaded_mc, spriteMc, spriteW, spriteH, concernedClip.tileX, concernedClip.tileY, concernedClip.startFrame, concernedClip.endFrame, concernedClip.fps);
				//MovieClip(ROOT).output("done: "+concernedClip.tileX+" "+concernedClip.tileY+" "+concernedClip.framesCount);
				concernedClip.addChild(spriteMc);
				
				concernedClip.scaleX = 1.0; // important for when the new image has another resolution than the old
				concernedClip.scaleY = 1.0;
				sprite.scaleX = 1.0; // important for when the new image has another resolution than the old
				sprite.scaleY = 1.0;
				spriteMc.scaleX = 1.0; // important for when the new image has another resolution than the old
				spriteMc.scaleY = 1.0;
				spriteMc.width = concernedClip.desiredWidth;
				spriteMc.height = concernedClip.desiredHeight;
				
				concernedClip.bitmapSprite = sprite;
	
				while (concernedClip.getChildByName("spriteRepresentation_old") != null)
				{
					//MovieClip(ROOT).output("removing old sprite", 0);
					concernedClip.removeChild(concernedClip.getChildByName("spriteRepresentation_old"));
				}
				while (concernedClip.getChildByName("representation") != null)
				{
					//MovieClip(ROOT).output("removing non-sprite rep", 0);
					concernedClip.removeChild(concernedClip.getChildByName("representation"));
				}
				
				var date = new Date();
				MovieClip(ROOT).output("set sprite now: "+date.getMinutes()+":"+date.getSeconds()+"."+date.getMilliseconds(), 0);
				
	
				spriteMc = null;
				sprite = null;
				loaded_mc = null;
				
			}
			
			//MovieClip(ROOT).output("ON LOAD concerned: "+concernedClip);
			var curr_width = concernedClip.desiredWidth;
			var curr_height = concernedClip.desiredHeight;
			var curr_x = concernedClip.x;
			var curr_y = concernedClip.y;
			//concernedClip.resizeMyself(curr_width, curr_height, curr_x, curr_y);
		
			// apply rotation, now that we have the representation
			var desiredRotZ = concernedClip.rotZ;
			concernedClip.rotZ = 0;
			if (desiredRotZ != 0)
			{
				//MovieClip(ROOT).output(concernedClip.inflObjName+": changeImage add rot: "+desiredRotZ, 1);
				concernedClip.addRotation(desiredRotZ);			
			}		
			
			concernedClip = null;
		}
		
		public function ioErrorHandler(event:IOErrorEvent):void 
		{
			
				objectsToLoad--;
				//MovieClip(ROOT).output("objectsToLoad "+objectsToLoad, 0);
				if (objectsToLoad <= 0)
				{
					MovieClip(ROOT).javaCallableFunctions.update_mapLoaded();
				}
				MovieClip(ROOT).output("ioErrorHandler: " + event, 0);
		}

	}
}
