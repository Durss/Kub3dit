package com.muxxu.kub3dit.commands {
	import com.nurun.core.commands.AbstractCommand;
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.environnement.configuration.Config;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	/**
	 * The  UploadMapCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to upload a map to the server.
	 *
	 * @author Francois
	 * @date 11 déc. 2011;
	 */
	public class UploadMapCmd extends AbstractCommand implements Command {
		private var _loader:URLLoader;
		private var _request:URLRequest;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  UploadMapCmd(data:ByteArray) {
			super();
			_loader = new URLLoader();
			_loader.addEventListener( Event.COMPLETE, uploadCompleteHandler);
			_loader.addEventListener( IOErrorEvent.IO_ERROR, uploadErrorHandler);
			
			var header:URLRequestHeader = new URLRequestHeader ("Content-type", "application/octet-stream");
			
			_request = new URLRequest(Config.getPath("uploadMapPath"));
			_request.requestHeaders.push(header);
			_request.method = URLRequestMethod.POST;
			_request.data = data;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Execute the concrete UploadMapCmd command.
		 * Must dispatch the CommandEvent.COMPLETE event when done.
		 */
		public override function execute():void {
			_loader.load(_request);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */

		private function uploadCompleteHandler(event:Event):void {
			try {
				var xml:XML = new XML(_loader.data);
			}catch(error:Error) {
				dispatchEvent(new CommandEvent(CommandEvent.ERROR, "Invalid returned data."));
				return;
			}
			
			if(xml.child("result")[0] == "0"){
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, String(xml.child("fileName")[0])));
			}else{
				dispatchEvent(new CommandEvent(CommandEvent.ERROR, "Missing request data."));
			}
		}

		private function uploadErrorHandler(event:IOErrorEvent):void {
				dispatchEvent(new CommandEvent(CommandEvent.ERROR, event.text));
		}
	}
}
