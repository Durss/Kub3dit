package com.muxxu.build3r.model {
	import flash.net.SharedObject;
	import com.muxxu.build3r.views.LoadView;
	import com.muxxu.build3r.vo.LightMapData;
	import com.muxxu.kub3dit.commands.BrowseForFileCmd;
	import com.muxxu.kub3dit.commands.LoadMapCmd;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.kub3dit.vo.Constants;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.math.MathUtils;

	import flash.display.Bitmap;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	/**
	 * 
	 * @author Francois
	 * @date 19 févr. 2012;
	 */
	public class ModelBuild3r extends EventDispatcher implements IModel {
		
		[Embed(source="../../../../../../deploy/kubes/additionals.txt", mimeType="application/octet-stream")]
		private var _additionnals:Class;
		[Embed(source="../../../../../../deploy/kubes/levelColors.png")]
		private var _colors:Class;
		[Embed(source="../../../../../../deploy/kubes/spritesheet.png")]
		private var _textures:Class;
		[Embed(source="../../../../../../deploy/kubes/spritesheet.txt", mimeType="application/octet-stream")]
		private var _spritesheet:Class;
		
		private var _timer:Timer;
		private var _position:Point3D;
		private var _browseCmd:BrowseForFileCmd;
		private var _loadMapCmd:LoadMapCmd;
		private var _map:LightMapData;
		private var _mapReferencePoint:Point3D;
		private var _positionReference:Point3D;
		private var _so:SharedObject;
		private var _autoLoading:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ModelBuild3r</code>.
		 */
		public function ModelBuild3r() {
			
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets iff a map is auto loading
		 */
		public function get autoLoading():Boolean { return _autoLoading; }
		
		/**
		 * Gets the last forum's position.
		 */
		public function get position():Point3D { return _position == null? null : _position.clone(); }
		
		/**
		 * Gets the map's data.
		 */
		public function get map():LightMapData { return _map; }
		
		/**
		 * Gets the map's reference point.
		 */
		public function get mapReferencePoint():Point3D { return _mapReferencePoint == null? null : _mapReferencePoint.clone(); }
		
		/**
		 * Gets the in game's position reference
		 */
		public function get positionReference():Point3D { return _positionReference == null? null : _positionReference.clone(); }
		



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Starts the application
		 */
		public function start():void {
			initialize();
			if(_so.data["id"] != undefined && _so.data["pass"] != undefined
			&& _so.data["worldRef"] != undefined && _so.data["mapRef"] != undefined && _so.data["position"] != undefined) {
				_positionReference = new Point3D(_so.data["worldRef"]["x"], _so.data["worldRef"]["y"], _so.data["worldRef"]["z"]);
				_mapReferencePoint = new Point3D(_so.data["mapRef"]["x"], _so.data["mapRef"]["y"], _so.data["mapRef"]["z"]);
				_position = new Point3D(_so.data["position"]["x"], _so.data["position"]["y"], _so.data["position"]["z"]);
				loadMapById(_so.data["id"], _so.data["pass"]);
				_autoLoading = true;
			}
			update();
		}
		
		/**
		 * Browses for an external map's file
		 */
		public function browseForMap():void {
			_browseCmd.execute();
		}
		
		/**
		 * Loads a map by its ID
		 */
		public function loadMapById(id:String, password:String):void {
			_loadMapCmd.id = id;
			_loadMapCmd.password = password;
			_loadMapCmd.execute();
			_so.data["id"] = id;
			_so.data["pass"] = password;
		}
		
		/**
		 * Sets the map's reference point.
		 */
		public function setReferencePoint(reference:Point3D):void {
			_positionReference = _position.clone();
			_mapReferencePoint = reference;
			_so.data["worldRef"] = {x:_positionReference.x, y:_positionReference.y, z:_positionReference.z};
			_so.data["mapRef"] = {x:reference.x, y:reference.y, z:reference.z};
			update();
		}
		
		/**
		 * Simulates a forum touch.
		 * Used only for debug purpose.
		 */
		public function touchForum(pos:Point3D):void {
			_position = pos.clone();
			update();
		}
		
		/**
		 * Moves the la position.
		 * For debug purpose
		 */
		public function move(x:int, y:int, z:int):void {
			_position.x += x;
			_position.y += y;
			_position.z += z;
			_position.z = MathUtils.restrict(_position.z, 0, 31);
			update();
		}
		
		/**
		 * Closes the application's window
		 */
		public function closeWindow():void {
			if(ExternalInterface.available) {
				var closeApp:XML = 
			    <script><![CDATA[
			            function(){ 
							document.getElementById("build3rApp").getElementsByTagName("embed")[0].style.width = "0px";
							document.getElementById("build3rApp").getElementsByTagName("embed")[0].style.height = "0px";
							document.getElementById('swf_minimap').style.visibility = '';
						}
			        ]]></script>;
				ExternalInterface.call(closeApp.toString());
			}
		}
		
		/**
		 * Picks up the kube forum
		 */
		public function pickUpKube():void {
			if(ExternalInterface.available) {
				ExternalInterface.call("removeKube", _position.x, _position.y, _position.z+1);
			}
		}
		
		/**
		 * Clears the current map and goes back to load view
		 */
		public function clearMap():void {
			_map = null;
			_position = null;
			_positionReference = null;
			_mapReferencePoint = null;
			_autoLoading = false;
			delete _so.data["id"];
			delete _so.data["pass"];
			delete _so.data["worldRef"];
			delete _so.data["mapRef"];
			if(!ExternalInterface.available) {
				_position = new Point3D(0,0,0);
			}
			update();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_timer = new Timer(70);
			_timer.addEventListener(TimerEvent.TIMER, ticTimerHandler);
			_timer.start();
			
			_so = SharedObject.getLocal("build3r", "/");
			
			_browseCmd = new BrowseForFileCmd("Kub3dit map", "*.png;*.map;");
			_browseCmd.addEventListener(CommandEvent.COMPLETE, loadMapCompleteHandler);
			_browseCmd.addEventListener(CommandEvent.ERROR, loadMapErrorHandler);
			
			_loadMapCmd = new LoadMapCmd(null, ViewLocator.getInstance().locateViewByType(LoadView) as LoadView);
			_loadMapCmd.addEventListener(CommandEvent.COMPLETE, loadMapCompleteHandler);
			_loadMapCmd.addEventListener(CommandEvent.ERROR, loadMapErrorHandler);

			var map:ByteArray = new _spritesheet();
			var add:ByteArray = new _additionnals();
			Textures.getInstance().initialize(map.readUTFBytes(map.length), add.readUTFBytes(add.length), (new _textures() as Bitmap).bitmapData, (new _colors() as Bitmap).bitmapData);
			
			if(!ExternalInterface.available) {
				_position = new Point3D(0,0,8);
			}
		}
		
		/**
		 * Fires an update to the views
		 */
		private function update():void {
			dispatchEvent(new ModelEvent(ModelEvent.UPDATE, this));
		}
		
		
		/**
		 * Called on timer's tic to get the zone coordinates.
		 */
		private function ticTimerHandler(event:TimerEvent):void {
			if(!ExternalInterface.available) return;
			
			var getZoneInfos:XML = 
		 	   <script><![CDATA[
		            function(){ return document.getElementById('infos').innerHTML; }
		        ]]></script>;
		    
	        var text:String = ExternalInterface.call(getZoneInfos.toString()); 
		    
			//check if picking up a forum
//			return removeKube(43215,-148226,2);
			if(/return removeKube\(-?[0-9]+,-?[0-9]+,-?[0-9]+\)/gi.test(text)) {
				text = text.replace(/.*(removeKube\(.*?\)).*/gi, "$1");
				var matches:Array = text.match(/-?[0-9]+/gi);
				var p:Point3D = new Point3D(parseInt(matches[0]), parseInt(matches[1]), parseInt(matches[2])-1);
				if(_position == null || !p.equals(_position)) {
					_position = p;
					_so.data["position"] = {x:_position.x, y:_position.y, z:_position.z};
					update();
				}
			}
		}
		
		/**
		 * Called when map's loading completes
		 */
		private function loadMapCompleteHandler(event:CommandEvent):void {
			var loadView:LoadView = ViewLocator.getInstance().locateViewByType(LoadView) as LoadView;
			var data:ByteArray = event.data as ByteArray;
			data.position = 0;
			//Search for PNG signature
			if(data.readUnsignedInt() == 0x89504e47) {
				data.position = data.length - 4;
				//search for ".K3D" signature at the end
				if(data.readUnsignedInt() == 0x2e4b3344) {
					data.position = data.length - 4 - 4;
					var dataLen:Number = data.readUnsignedInt();
					data.position = data.length - 4 - 4 - dataLen;
					var tmp:ByteArray = new ByteArray();
					tmp.writeBytes(data, data.position, dataLen);
					data = tmp;
					data.position = 0;
				}
			}else{
				data.position == 0;
			}
			try {
				data.uncompress();
				data.position = 0;
			}catch(error:Error) {
				loadView.typeError();
				return;
			}
			var fileVersion:int = data.readByte();
			switch(fileVersion){
					
				case Constants.MAP_FILE_TYPE_1:
					_map = new LightMapData(data.readShort(), data.readShort(), data.readShort(), data);
					break;
				
				case Constants.MAP_FILE_TYPE_2:
					var customsLen:uint = data.readUnsignedByte();
					for(var i:int = 0; i < customsLen; ++i) data.readUTFBytes(data.readShort());
					data.position += 2+2+2+4+4;
					_map = new LightMapData(data.readShort(), data.readShort(), data.readShort(), data);
					break;
				
				default:
					loadView.typeError();
			}
			
			update();
		}
		
		/**
		 * Called if map's loading fails
		 */
		private function loadMapErrorHandler(event:CommandEvent):void {
			var loadView:LoadView = ViewLocator.getInstance().locateViewByType(LoadView) as LoadView;
			loadView.mapNotFound();
		}
	}
}