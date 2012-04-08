package com.muxxu.kub3dit.vo {
	import by.blooddy.crypto.Base64;
	import com.nurun.core.lang.vo.XMLValueObject;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * Fired when data is updated
	 */
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * Stores the informations about a cube.
	 * 
	 * @author Francois
	 */
	public class CubeData extends EventDispatcher {
		
		private var _id:Number;
		private var _uid:Number;
		private var _name:String;
		private var _file:String;
		private var _pseudo:String;
		private var _date:Number;
		private var _kub:KUBData;
		private var _rawData:XML;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CubeData</code>.
		 */
		public function CubeData() { }

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get rawData():XML { return _rawData; }

		public function get id():Number { return _id; }

		public function get uid():Number { return _uid; }

		public function get name():String { return _name; }

		public function get file():String { return _file; }

		public function get userName():String { return _pseudo; }

		public function get date():Number { return _date; }

		public function get kub():KUBData { return _kub; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function populate(xml:XML, ...optionnals:Array):CubeData {
			_rawData = xml;
			_id = parseInt(xml.@id);
			_uid = parseInt(xml.@uid);
			_name = String(xml.@name).replace("<", "&lt;").replace(">", "&gt;");
			_file = xml.@file;
			_pseudo = xml.@pseudo;
			_date = parseInt(xml.@date);
			_kub = new KUBData();
			_kub.fromByteArray(Base64.decode(xml[0]));
			
			dispatchEvent(new Event(Event.CHANGE));
			return this;
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			_kub.dispose();
			_kub = null;
		}
		
		/**
		 * Gets a string representation of the value object.
		 */
		override public function toString():String {
			return "[CubeData :: name=" + name + "]";
		}
		
		/**
		 * Gets a clone of the object
		 */
		public function clone():CubeData {
			var ret:CubeData = new CubeData();
			ret.populate(_rawData);
			return ret;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}