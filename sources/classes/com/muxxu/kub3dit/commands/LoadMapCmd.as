package com.muxxu.kub3dit.commands {
	import com.muxxu.kub3dit.views.SaveView;
	import com.muxxu.kub3dit.views.MapPasswordView;
	import com.nurun.core.commands.AbstractCommand;
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.mvc.views.ViewLocator;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	/**
	 * The  LoadMapCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to load a map's data
	 *
	 * @author Francois
	 * @date 11 déc. 2011;
	 */
	public class LoadMapCmd extends AbstractCommand implements Command {
		
		private var _loader:URLLoader;
		private var _request:URLRequest;
		private var _editable:Boolean;
		private var _id:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  LoadMapCmd(id:String) {
			_id = id;
			super();
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener( Event.COMPLETE, loadCompleteHandler);
			_loader.addEventListener( IOErrorEvent.IO_ERROR, loadErrorHandler);
			
			_request = new URLRequest(Config.getPath("loadMapPath"));
			_request.method = URLRequestMethod.GET;
			var vars:URLVariables = new URLVariables();
			vars["id"] = id;
			_request.data = vars;
		}

			
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets if the map is editable
		 */
		public function get editable():Boolean { return _editable; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Execute the concrete LoadMapCmd command.
		 * Must dispatch the CommandEvent.COMPLETE event when done.
		 */
		public override function execute():void {
			_loader.load(_request);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */

		private function loadCompleteHandler(event:Event):void {
			var data:ByteArray = _loader.data as ByteArray;
			var passView:MapPasswordView = ViewLocator.getInstance().locateViewByType(MapPasswordView) as MapPasswordView;
			var saveView:SaveView = ViewLocator.getInstance().locateViewByType(SaveView) as SaveView;
			
			//Detect if the "EDIT" tag is specified
			if(data.readUnsignedInt() == 0x45444954) {
				_editable = true;
				var tmp:ByteArray = new ByteArray();
				data.readBytes(tmp);//removes the EDIT tag.
				data = tmp;
				data.position = 0;
			}else{
				data.position = 0;
			}
			
			//if it's not a PNG file
			if(data.readUnsignedInt() != 0x89504e47) {
				data.position = 0;
			
				//Detect if its an XML
				data.position = 0;
				var src:String = data.readUTFBytes(data.length);
				try {
					var xml:XML = new XML(src);
				}catch(error:Error) {
					//Not an XML, fire an unknown error
					dispatchEvent(new CommandEvent(CommandEvent.ERROR));
					return;
				}
				
				//It's an XML, read the details on it
				var code:String = xml.child("result")[0];
				switch(code){
					//Protected
					case "1":
						passView.open(onSetPassword);
						break;
					
					//var missing
					case "2":
						
						break;
					//Invalid password
					case "3":
						passView.error();
						break;
					
					//Map not found
					default:
					case "0":
						dispatchEvent(new CommandEvent(CommandEvent.ERROR));
						break;
				}
				
			}else{
				saveView.mapId = _id;
				saveView.editableMap = _editable;
				passView.close();
				data.position = 0;
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, data));
			}
		}
		
		/**
		 * Called if map's loading fails.
		 */
		private function loadErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, event.text));
		}
		
		/**
		 * Called when user submits the password
		 */
		private function onSetPassword(password:String):void {
			if(password == null) {
				//Dirty but this unlocks the model
				dispatchEvent(new CommandEvent(CommandEvent.ERROR));
			}else{
				URLVariables(_request.data)["pass"] = password;
				execute();
			}
		}
	}
}
