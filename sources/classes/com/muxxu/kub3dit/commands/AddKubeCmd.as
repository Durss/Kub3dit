package com.muxxu.kub3dit.commands {
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.vo.CubeData;
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	/**
	 * The  AddKubeCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to load a kube form the KubeBuilder app and add it
	 * to the available textures.
	 *
	 * @author Francois
	 * @date 13 nov. 2011;
	 */
	public class AddKubeCmd extends EventDispatcher implements Command {
		private var _loader:URLLoader;
		private var _kubeId:String;
		private var _data:CubeData;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  AddKubeCmd(kubeId:String) {
			_kubeId = kubeId;
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, loadFileCompleteHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, loadFileErrorHandler);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Execute the concrete AddKubeCmd command.
		 * Must dispatch the CommandEvent.COMPLETE event when done.
		 */
		public function execute():void {
			var request:URLRequest = new URLRequest("http://fevermap.org/kubebuilder/php/ws/getKubes.php");
			var urlVars:URLVariables = new URLVariables();
			urlVars.kubeId = _kubeId;
			urlVars.start = 0;
			urlVars.length = 1;
			request.data = urlVars;
			request.method = URLRequestMethod.POST;
			_loader.load(request);
		}
		
		/**
		 * @inheritDoc
		 */
		public function halt():void {
			
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */

		private function loadFileErrorHandler(event:IOErrorEvent):void {
//			throw new Kub3ditException(Label.getLabel("loadKubeError"), Kub3ditExceptionSeverity.MINOR);
			dispatchEvent(new CommandEvent(CommandEvent.ERROR));
		}

		private function loadFileCompleteHandler(event:Event):void {
			var xml:XML;
			try {
				xml = new XML(_loader.data);
			}catch(error:Error) {
				loadFileErrorHandler(null);
				return;
			}
			if(xml.child("result")[0] == "0") {
				_data = new CubeData();
				_data.populate(xml.child("kubes")[0].child("kube")[0]);
				
				Textures.getInstance().addKube(_data);
				
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
			}else{
				loadFileErrorHandler(null);
			}
		}
	}
}
