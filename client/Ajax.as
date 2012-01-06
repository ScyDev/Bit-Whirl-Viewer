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

	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.symmetric.NullPad;
	import com.hurlant.crypto.symmetric.PKCS5;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.crypto.symmetric.IPad;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	import flash.utils.*;

	
	
	public class Ajax extends GlobalStage
	{
		public var cmdIntervalId = 0;
		
		public var cmdList = new Array();
		
		private var cryptoKey:String = null;
		public var algorithm:String = "simple-aes-cbc"; // simple-aes-cbc
		public var padding:String = "pkcs5"; // None
		public var cmdsWaitingForSync = new Object();
		
		// try XML Sockets for asynch
		public var paramObj:Object = LoaderInfo(MovieClip(ROOT).loaderInfo).parameters;
		public var username = String(paramObj["username"]);
		public var passwd = String(paramObj["passwd"]);
		public var destination = String(paramObj["destination"]);
		public var loginToken = String(paramObj["loginTokenForExistingPlayer"]);
		public var guest_checkbox = String(paramObj["guest"]);
		public var is_guest = 0;
		public var myXMLSocket:Socket = new Socket;
		public var authLoader;
				
		public var sentCmds:Array = new Array(); 
		public var sentCmdsLag:Array = new Array(); 
		
		public function Ajax()
		{
			MovieClip(ROOT).host = String(paramObj["host"]);
			if (MovieClip(ROOT).host == "null" || MovieClip(ROOT).host == undefined || MovieClip(ROOT).host == "undefined" || MovieClip(ROOT).host == "")
			{
				MovieClip(ROOT).host = null;
			}
			MovieClip(ROOT).output("Ajax: host:"+MovieClip(ROOT).host, 0);
			
			myXMLSocket.addEventListener(DataEvent.DATA, onXmlData);
			myXMLSocket.addEventListener(ProgressEvent.SOCKET_DATA, onXmlData);
			myXMLSocket.addEventListener(Event.CONNECT, onXmlConnect);
			myXMLSocket.addEventListener(Event.CLOSE, onXmlClose);
			if (loginToken != null && loginToken != "null" && loginToken != undefined && loginToken != "undefined" && loginToken != "")
			{
				MovieClip(ROOT).output("Ajax: loginToken", 0);
				sendAuthRequest();
			}
			else if (username != null && username != "null" && username != undefined && username != "undefined" && username != "" 
				&& passwd != null && passwd != "null" && passwd != undefined && passwd != "undefined" && passwd != "")
			{
				MovieClip(ROOT).output("Ajax: username:"+username+" passwd:"+passwd, 0);
				sendAuthRequest();
			}
			else if (guest_checkbox == "true")
			{
				MovieClip(ROOT).output("Ajax: guest_checkbox", 0);
				sendAuthRequest();
			}
			else
			{
				MovieClip(ROOT).output("Ajax: showLoginDialog()", 0);
				showLoginDialog();
			}
			
			MovieClip(ROOT).output("INIT: Ajax has run...", 0);
		}

		public function parseCmds(myXmlData:XML)
		{ 
			var childs = myXmlData.children();
		
			/*
			 // for encrypted input
			for (var i = 0; i < childs.length(); i++)
			{
				var currCmd = childs[i];
				
				MovieClip(ROOT).output(currCmd, 0);
				currCmd = decrypt(currCmd);
				MovieClip(ROOT).output(currCmd, 0);
				
				myXmlData = new XML(currCmd);
			}
			
			childs = myXmlData.children();
			*/
		
			for (var i = 0; i < childs.length(); i++)
			{
				var currCmd = childs[i];
				
				resolveCmd(currCmd);
			}
			
			/*
			if (!busy)
			{
				resolveNextCmd();
			}
			*/
		}
		
		
		public function encrypt(input:String):String {
			//var key = Base64.encodeByteArray(Hex.toArray(AES_KEY));
			var key = cryptoKey;
			
			var kdata:ByteArray = Base64.decodeToByteArray(key);
			var data:ByteArray = Hex.toArray(Hex.fromString(input));
			var pad:IPad = padding == "pkcs5" ? new PKCS5 : new NullPad;
			var mode:ICipher = Crypto.getCipher(algorithm, kdata, pad);
			pad.setBlockSize(mode.getBlockSize());
			mode.encrypt(data);
			
			return Base64.encodeByteArray(data);
		}
		
		public function decrypt(input:String):String {
			//var key = Base64.encodeByteArray(Hex.toArray(AES_KEY));
			var key = cryptoKey;
			
			var kdata:ByteArray = Base64.decodeToByteArray(key);
			var data:ByteArray = Base64.decodeToByteArray(input);
			var pad:IPad = padding == "pkcs5" ? new PKCS5 : new NullPad;
			var mode:ICipher = Crypto.getCipher( algorithm, kdata, pad);
			pad.setBlockSize(mode.getBlockSize());
			mode.decrypt(data);
			
			return Hex.toString(Hex.fromArray(data));
		}
		
		
		public function resolveCmd(textCmd)
		{
			//MovieClip(ROOT).output("COMMAND: "+textCmd);
			//textCmd = cmdList[0];
			//cmdList = cmdList.slice(1, cmdList.length);
			
			var syncWith;
			var syncTrigger;
			if (textCmd.indexOf("SYNCWITH") == 0)
			{
				var firstCP = textCmd.indexOf("[");
				var lastCP = textCmd.indexOf("]");
				var syncWith = textCmd.substring(firstCP+1, lastCP);
				
				textCmd = textCmd.substring(lastCP+1);
				var waitingCmdArray = cmdsWaitingForSync[syncWith];
				if (waitingCmdArray == null)
				{
					waitingCmdArray = new Array();
				}
				waitingCmdArray.push(textCmd);
				//MovieClip(ROOT).output("syncWith:"+syncWith+" cmd:"+textCmd, 0);
				cmdsWaitingForSync[syncWith] = waitingCmdArray;
				//MovieClip(ROOT).output("orig cmd after that:"+textCmd, 0);
				return;
			}
			if (textCmd.indexOf("SYNCTRIGGER") == 0)
			{
				var firstCP = textCmd.indexOf("[");
				var lastCP = textCmd.indexOf("]");
				var syncTrigger = textCmd.substring(firstCP+1, lastCP);
				//MovieClip(ROOT).output("syncTrigger:"+syncTrigger, 0);
				
				textCmd = textCmd.substring(lastCP+1);
				if (cmdsWaitingForSync[syncTrigger] != null)
				{
					var waitingCmdArray = cmdsWaitingForSync[syncTrigger];
					for (var i = 0; i < waitingCmdArray.length; i++)
					{
						//MovieClip(ROOT).output("trigger cmd:"+waitingCmdArray[i], 0);
						resolveCmd(waitingCmdArray[i]);
					}
					
					cmdsWaitingForSync[syncTrigger] = null;
				}
				//MovieClip(ROOT).output("orig cmd after that:"+textCmd, 0);
			}
			
			var firstP = textCmd.indexOf("(");
			var lastP = textCmd.indexOf(")");
			
			var cmdName = textCmd.substring(0, firstP);
			var cmdArgsText = textCmd.substring(firstP+1, lastP);
			var cmdArgs = cmdArgsText.split(", ");
			
			for (var i = 0; i < cmdArgs.length; i++)
			{
				var currParam = cmdArgs[i];
				while (currParam.indexOf("+") >= 0)
				{
					// necessary cause flash wants a space as %20 but java sends a space as +
					currParam = currParam.replace("+", "%20");
				}
				currParam = flash.utils.unescapeMultiByte(currParam);
				
				cmdArgs[i] = currParam;
			}
			
			
			//MovieClip(ROOT).output(cmdName);
			
			// HAHAHAHA!! :D do this with interval!
			//cmdIntervalId = setInterval("output", 01000, "intervaltest!");
			//cmdIntervalId = setInterval(cmdName, 01, cmdArgs);
			
			
			if (cmdName == "update_moveObject")
			{
				MovieClip(ROOT).javaCallableFunctions.update_moveObject(cmdArgs[0], cmdArgs[1], cmdArgs[2], cmdArgs[3], cmdArgs[4], cmdArgs[5]);
			}
			else if (cmdName == "update_rotateObject")
			{
				MovieClip(ROOT).javaCallableFunctions.update_rotateObject(cmdArgs[0], cmdArgs[1], cmdArgs[2], cmdArgs[3], cmdArgs[4]);
			}
			else if (cmdName == "update_moveObjectZ")
			{
				MovieClip(ROOT).javaCallableFunctions.update_moveObjectZ(cmdArgs[0], cmdArgs[1]);
			}
			else if (cmdName == "update_resizeObject")
			{
				MovieClip(ROOT).javaCallableFunctions.update_resizeObject(cmdArgs[0], cmdArgs[1], cmdArgs[2], cmdArgs[3], cmdArgs[4]);
		
			}
			else if (cmdName == "update_createNewObj")
			{
				MovieClip(ROOT).javaCallableFunctions.update_createNewObj(cmdArgs[0], cmdArgs[1], cmdArgs[2], cmdArgs[3], cmdArgs[4], cmdArgs[5], cmdArgs[6], cmdArgs[7], cmdArgs[8], cmdArgs[9], cmdArgs[10], cmdArgs[11], cmdArgs[12], cmdArgs[13], cmdArgs[14], cmdArgs[15]);
			}
			else if (cmdName == "update_warpObject")
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_warpObject(cmdArgs[0], cmdArgs[1], cmdArgs[2]);
			}
			else if (cmdName == "update_removeObject")
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_removeObj(cmdArgs[0]);
			}
			else if (cmdName == "update_scrollView")
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_scrollView(cmdArgs[0], cmdArgs[1], cmdArgs[2]);
			}
			else if (cmdName == "update_viewportFollowObject")
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_viewportFollowObject(cmdArgs[0]);
			}
			else if (cmdName == "update_refreshInventory")
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_refreshInventory();
			}
			else if (cmdName == "update_showLoadingScreen")
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_showLoadingScreen(cmdArgs[0], cmdArgs[1]);
			}
			else if (cmdName == "update_newMap")
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_newMap(cmdArgs[0], cmdArgs[1], cmdArgs[2], cmdArgs[3], cmdArgs[4]);
			}
			else if (cmdName == "update_setObjectsToLoadCount")
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_setObjectsToLoadCount(cmdArgs[0]);
			}
			else if (cmdName == "update_mapLoaded")
			{ 
			MovieClip(ROOT).output("update_mapLoaded:"+cmdName, 0);
				MovieClip(ROOT).javaCallableFunctions.update_mapLoaded();
			}
			else if (cmdName == "update_refreshLayers")
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_refreshLayers();
			}
			else if (cmdName == "update_changeImage") 
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_changeImage(cmdArgs[0], cmdArgs[1], cmdArgs[2], cmdArgs[3], cmdArgs[4], cmdArgs[5], cmdArgs[6], cmdArgs[7]);
			}
			else if (cmdName == "update_displayChat") 
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_displayChat(cmdArgs[0], cmdArgs[1], cmdArgs[2]);
			}
			else if (cmdName == "update_setWatchedKeys") 
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_setWatchedKeys(cmdArgs[0]);
			}
			else if (cmdName == "update_displayCredits") 
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_displayCredits(cmdArgs[0]);
			}
			else if (cmdName == "update_setObjectProps") 
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_setObjectProps(cmdArgs[0], cmdArgs[1], cmdArgs[2], cmdArgs[3], cmdArgs[4], cmdArgs[5], cmdArgs[6], cmdArgs[7], cmdArgs[8], cmdArgs[9]);
			}
			else if (cmdName == "update_playSound") 
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_playSound(cmdArgs[0], cmdArgs[1]);
			}
			else if (cmdName == "update_stopSound") 
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_stopSound(cmdArgs[0]);
			}
			else if (cmdName == "update_displayTextOnObject") 
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_displayTextOnObject(cmdArgs[0], cmdArgs[1], cmdArgs[2], cmdArgs[3]);
			}
			else if (cmdName == "update_goToWebsite") 
			{ 
				MovieClip(ROOT).javaCallableFunctions.update_goToWebsite(cmdArgs[0], cmdArgs[1]);
			}
			else if (cmdName == "update_showObjectPerms")
			{
				MovieClip(ROOT).javaCallableFunctions.update_showObjectPerms(cmdArgs[0], cmdArgs[1], cmdArgs[2], cmdArgs[3], cmdArgs[4], cmdArgs[5], cmdArgs[6], cmdArgs[7], cmdArgs[8], cmdArgs[9]);
			}
			else if (cmdName == "update_refreshObjectContents")
			{
				MovieClip(ROOT).javaCallableFunctions.update_refreshObjectContents();
			}
			else if (cmdName == "update_objectAttachObject")
			{
				MovieClip(ROOT).javaCallableFunctions.update_objectAttachObject(cmdArgs[0], cmdArgs[1], cmdArgs[2], cmdArgs[3]);
			}
			else if (cmdName == "update_objectDetachObject")
			{
				MovieClip(ROOT).javaCallableFunctions.update_objectDetachObject(cmdArgs[0], cmdArgs[1]);
			}
			else if (cmdName == "update_respondLag")
			{
				MovieClip(ROOT).javaCallableFunctions.update_respondLag(cmdArgs[0]);
			}
			else if (cmdName == "update_objectRotFollowMousePointer")
			{
				MovieClip(ROOT).javaCallableFunctions.update_objectRotFollowMousePointer(cmdArgs[0], true);
			}
			else if (cmdName == "update_objectRotStopFollowMousePointer")
			{
				MovieClip(ROOT).javaCallableFunctions.update_objectRotFollowMousePointer(cmdArgs[0], false);
			}
			
			else
			{
				MovieClip(ROOT).output("Func: "+cmdName+" not yet mapped!!!", 0);
			}
		
		}
		
		var unfinishedCmd = "";
		public function onXmlData(event:ProgressEvent):void
		{
			var randId = Math.random()*100000;
			//MovieClip(ROOT).output("got XML! ["+randId+"]"+myXMLSocket.bytesAvailable+" bytes", 0);
			var cmdData = myXMLSocket.readUTFBytes(myXMLSocket.bytesAvailable)
			//MovieClip(ROOT).output("cmd: ["+randId+"]"+cmdData, 0);
			
			unfinishedCmd += cmdData;
			/*
			if (cmdData.indexOf("<nodes>") < 0
				|| (cmdData.indexOf("</nodes>") >= 0 && cmdData.indexOf("</nodes>") < cmdData.indexOf("<nodes>")) )
			{
				
			}*/
			
			var currData = "";
			while (unfinishedCmd.indexOf("<nodes>") >= 0 && unfinishedCmd.indexOf("</nodes>") >= 0)
			{
				currData = unfinishedCmd.substring(unfinishedCmd.indexOf("<nodes>"), unfinishedCmd.indexOf("</nodes>")+8);
				unfinishedCmd = unfinishedCmd.substring(unfinishedCmd.indexOf("</nodes>")+8);
			
				//MovieClip(ROOT).output("parse:"+currData, 0);
				var myXmlData = new XML(currData);
				
				
				parseCmds(myXmlData);
			}
		}
		
		public function onXmlConnect(event:Event):void
		{
			MovieClip(ROOT).output("got Connect! "+event.type, 0);
			MovieClip(ROOT).output("cred "+username+" ", 0);	
			
			// aparently it's necessary to send some data to get the connection going...
			// and for some FUCKING reason, sending an XML object does not work, but sending a string does...
			// var my_xml = new XML("<login username='"+username+"' password='"+passwd+"'/>");
			myXMLSocket.writeUTFBytes("<login username='"+flash.utils.escapeMultiByte(username)+"' loginToken='"+flash.utils.escapeMultiByte(loginToken)+"' destination='"+flash.utils.escapeMultiByte(destination)+"'       />");
			myXMLSocket.flush();
			
			MovieClip(ROOT).treeActions.loadInventoryTree();
		}
		
		
		public function onXmlClose(event:Event)
		{
				MovieClip(ROOT).output("DISCONNECTED! Try reloading the client...", 1);
				MovieClip(ROOT).chat.displayChatBubble("DISCONNECTED! Try reloading the client...");
		}
		
		
		public function connectToXmlPort(port)
		{
			var tmp = myXMLSocket.connect(MovieClip(ROOT).host, port); // null is flash movies original host
			MovieClip(ROOT).output("connected to XML Socket", 0);
		}
		
		
		public function showLoginDialog()
		{
			if (username == "null") username = ""; // cause params read from embedding jsp that are null are translated to "null"
			if (passwd == "null") passwd = "";
			
			var loginDialog = new LoginDialog();
			
			loginDialog.usernameInput.text = username;
			
			//MovieClip(ROOT).output(Stage(STAGE).width+"/"+Stage(STAGE).height+" - "+loginDialog.width+"/"+loginDialog.height, 0);
			loginDialog.x = (MovieClip(ROOT).viewport.width/2)-(loginDialog.width/2);
			loginDialog.y = (MovieClip(ROOT).viewport.height/2)-(loginDialog.height/2);
			MovieClip(ROOT).viewport.addChild(loginDialog);
			
			function onLoginOk(event)
			{
				username = loginDialog.usernameInput.text;
				passwd = loginDialog.passwordInput.text;
				guest_checkbox = loginDialog.checkbox_guest_login.selected;
				
				sendAuthRequest();
				
				loginDialog.parent.removeChild(loginDialog);
			}
			loginDialog.ok_button.addEventListener("click", onLoginOk);
			loginDialog.usernameInput.addEventListener(ComponentEvent.ENTER, onLoginOk);
			loginDialog.passwordInput.addEventListener(ComponentEvent.ENTER, onLoginOk);
			
			function onClickGuestLogin(event)
			{
				if (loginDialog.checkbox_guest_login.selected == true)
				{
					loginDialog.passwordInput.text = "";
					loginDialog.passwordInput.enabled = false;
				}
				else
				{
					loginDialog.passwordInput.enabled = true;		
				}
			}
			loginDialog.checkbox_guest_login.addEventListener("click", onClickGuestLogin);
			
			function onClickReg(event)
			{
				navigateToURL(new URLRequest("/app/user/User_prepareRegister.action"), "_self");
			}
			loginDialog.register_link.addEventListener("click", onClickReg);
			loginDialog.register_link.useHandCursor = true;
			
			function onClickResetPassword(event)
			{
				navigateToURL(new URLRequest("/app/user/request_reset_pw.jsp"), "_blank");
			}
			loginDialog.reset_pw_link.addEventListener("click", onClickResetPassword);
			loginDialog.reset_pw_link.useHandCursor = true;
			
		}
		
		public function sendAuthRequest()
		{
			MovieClip(ROOT).output("sendAuthRequest()", 0);
			if (username == "null") username = ""; // cause params read from embedding jsp that are null are translater to "null"
			if (passwd == "null") passwd = "";
			if (loginToken == "null") loginToken = "";
			if (guest_checkbox == "null") guest_checkbox = "";
			
			MovieClip(ROOT).borderLayout.showLoadingScreen(true);
			
			MovieClip(ROOT).output("sendAuthRequest() host:"+MovieClip(ROOT).host, 0);
			if (MovieClip(ROOT).host != null)
			{
				authLoader = new URLLoader(new URLRequest("https://"+MovieClip(ROOT).host+"/app/client/auth_player.jsp?username="+username+"&passwd="+passwd+"&loginToken="+loginToken+"&guest="+guest_checkbox+"&viewportWidth="+MovieClip(ROOT).viewport.width+"&viewportHeight="+MovieClip(ROOT).viewport.height));
			}
			else
			{
				authLoader = new URLLoader(new URLRequest("../client/auth_player.jsp?username="+username+"&passwd="+passwd+"&loginToken="+loginToken+"&guest="+guest_checkbox+"&viewportWidth="+MovieClip(ROOT).viewport.width+"&viewportHeight="+MovieClip(ROOT).viewport.height));
			}
			MovieClip(ROOT).output("sendAuthRequest() authLoader:"+authLoader, 0);
			authLoader.addEventListener(Event.COMPLETE, onAuthLoaderComplete);
		}
		
		public function onAuthLoaderComplete(event:Event)
		{
			var authResult = authLoader.data;
			authResult = authResult.substring(authResult.indexOf("[[[")+3, authResult.lastIndexOf("]]]"));
			var resultArgs = authResult.split(":");
		
			if (resultArgs[0] == "OK" || resultArgs[0] == "GUEST")
			{
				if (resultArgs[0] == "GUEST")
				{
					is_guest = 1;
					username = String(resultArgs[3]);
					
					var regNoticeButton = new RegNoticeButton();
					regNoticeButton.x = 30;
					regNoticeButton.y = 75;
					regNoticeButton.width = 300;
					regNoticeButton.height = 100;
					Stage(STAGE).addChild(regNoticeButton);			
					
					function clickRegister(eventObj:Object):void {
						navigateToURL(new URLRequest("/app/user/User_prepareRegister.action"), "_self");
					}
					regNoticeButton.addEventListener("click", clickRegister);
								
				}
				
				cryptoKey = resultArgs[4];
				loginToken = resultArgs[2];
				connectToXmlPort(resultArgs[1]);
				
				MovieClip(ROOT).header.label_user.text = username;
			}
			else
			{
				MovieClip(ROOT).borderLayout.showLoadingScreen(false);
				showLoginDialog();
			}
			
			if (resultArgs[0] == "Too many login tries. Wait 3 minutes.")
			{
				MovieClip(ROOT).chat.displayChatBubble(resultArgs[0]);
			}	
		}
		
		public function calcMeanLag()
		{
			var lagCounter = 0;
			var lagTotal = 0;

			if (MovieClip(ROOT).ajax.sentCmdsLag.length >= 5)
			{
				var theLength = MovieClip(ROOT).ajax.sentCmdsLag.length;
				MovieClip(ROOT).ajax.sentCmdsLag = MovieClip(ROOT).ajax.sentCmdsLag.slice(2, theLength-1);
			}
			for each (var lag in MovieClip(ROOT).ajax.sentCmdsLag)
			{
				lagCounter++;
				lagTotal += lag;
				//MovieClip(ROOT).output("lagCounter "+lagCounter+" lagTotal "+lagTotal, 0);
			}
			var meanLag = 0;
			if (lagCounter > 0 && lagTotal > 0) meanLag = lagTotal/lagCounter;
			if (meanLag > 200) meanLag = 200;
			//MovieClip(ROOT).output("meanLag "+meanLag, 0);
		
			return meanLag;
		}
	}
}
