package com.muxxu.kub3dit.utils {
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class MtLibParser {
		private var _loader:URLLoader;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MtLibParser</code>.
		 */
		public function MtLibParser() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			_loader.load(new URLRequest("http://xml.kubegb.fr/xml/muxxu.kube.inventory.xml"));
		}
	
		private function loadCompleteHandler(event:Event):void {
			var xml:XML = new XML(_loader.data);
			var nodes:XMLList = xml.child("kube");
			var i:int, len:int;
			len = nodes.length();
			var ret:String = "";
			for(i = 1; i < len; ++i) {
				ret += "\t\t<label code=\"kube"+nodes[i].@id+"\"><![CDATA["+nodes[i].@name+"]]></label>\n";
			}
			trace(ret);
		}
		
	}
}