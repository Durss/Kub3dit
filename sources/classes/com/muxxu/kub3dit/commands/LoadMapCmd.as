package com.muxxu.kub3dit.commands {
	import com.nurun.core.commands.AbstractCommand;
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.environnement.configuration.Config;

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
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  LoadMapCmd(id:String) {
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
			if(data.readUnsignedInt() != 0x89504e47) {
				//if it's not a PNG file
				dispatchEvent(new CommandEvent(CommandEvent.ERROR));
			}else{
				data.position = 0;
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, data));
			}
		}

		private function loadErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, event.text));
		}
	}
}
