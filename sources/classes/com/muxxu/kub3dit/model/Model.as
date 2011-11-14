package com.muxxu.kub3dit.model {
	import com.muxxu.kub3dit.commands.AddKubeCmd;
	import com.muxxu.kub3dit.commands.BrowseForFileCmd;
	import com.muxxu.kub3dit.commands.InitTexturesCmd;
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.exceptions.Kub3ditException;
	import com.muxxu.kub3dit.exceptions.Kub3ditExceptionSeverity;
	import com.muxxu.kub3dit.vo.Constants;
	import com.muxxu.kub3dit.vo.CubeData;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;

	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class Model extends EventDispatcher implements IModel {
		
		private var _initTexturesCmd:InitTexturesCmd;
		private var _currentKubeId:String;
		private var _view3DReady:Boolean;
		private var _map:Map;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Model</code>.
		 */
		public function Model() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the currently selected kube.
		 */
		public function get currentKubeId():String { return _currentKubeId; }
		
		/**
		 * Gets the map's reference.
		 */
		public function get map():Map { return _map; }
		
		/**
		 * Gets if the 3D view is ready
		 */
		public function get view3DReady():Boolean { return _view3DReady; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Starts the application
		 */
		public function start():void {
			_initTexturesCmd = new InitTexturesCmd();
			_initTexturesCmd.addEventListener(CommandEvent.COMPLETE, initCompleteHandler);
			_initTexturesCmd.execute();
		}
		
		/**
		 * Cahnges the currently selected kube's ID
		 */
		public function changeKubeId(id:String):void {
			_currentKubeId = id;
			ViewLocator.getInstance().dispatchToViews(new LightModelEvent(LightModelEvent.KUBE_SELECTION_CHANGE, _currentKubeId));
		}
		
		/**
		 * Saves the currentMap
		 */
		public function saveMap():void {
			var ba:ByteArray = new ByteArray();
			//============FILE TYPE============
			ba.writeByte(Constants.MAP_FILE_TYPE_2);
			
			//============CUSTOM CUBES============
			var i:int, len:int;
			len = Textures.getInstance().customKubes.length;
			ba.writeByte(len);
			for(i = 0; i < len; ++i) {
				//No need to store the string's length before it because writeUTF already does that
				ba.writeUTF( Textures.getInstance().customKubes[i].rawData.toXMLString() );
			}
			
			//============CAMERA CONF============
			ba.writeShort(Camera3D.locX);
			ba.writeShort(Camera3D.locY);
			ba.writeShort(Camera3D.locZ);
			ba.writeUnsignedInt(Camera3D.rotationX);
			ba.writeInt(Camera3D.rotationY);
			
			//============MAP SIZES============
			ba.writeShort(_map.mapSizeX);
			ba.writeShort(_map.mapSizeY);
			ba.writeShort(_map.mapSizeZ);
			
			//============MAP DATA============
			_map.data.position = 0;
			_map.data.readBytes(ba,ba.length);
			ba.compress();
			ba.position = 0;
			
			var fr:FileReference = new FileReference();
			fr.save(ba, "kub3dit.map");
		}
		
		/**
		 * Loads a map
		 */
		public function loadMap():void {
			var cmd:BrowseForFileCmd = new BrowseForFileCmd();
			cmd.addEventListener(CommandEvent.COMPLETE, loadMapCompleteHandler);
			cmd.addEventListener(CommandEvent.ERROR, loadMapErrorHandler);
			cmd.execute();
		}
		
		/**
		 * Creates a map
		 */
		public function createMap(sizeX:int, sizeY:int, sizeZ:int):void {
			_map = new Map(sizeX * 32, sizeY * 32, sizeZ);
			update();
		}
		
		/**
		 * Tells the model that the 3D view is ready
		 */
		public function setView3DReady():void {
			_view3DReady = true;
			update();
		}
		
		/**
		 * Adds a kube from kube-builder to the textures
		 */
		public function addKube(kubeId:String):void {
			var cmd:AddKubeCmd = new AddKubeCmd(kubeId);
			cmd.addEventListener(CommandEvent.COMPLETE, addKubeCompleteHandler);
			cmd.addEventListener(CommandEvent.ERROR, addKubeErrorHandler);
			cmd.execute();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_currentKubeId = "3";//Defaulty selected kube
		}
		
		/**
		 * Called when textures are ready
		 */
		private function initCompleteHandler(event:CommandEvent):void {
			update();
		}
		
		/**
		 * Fire an update to the views
		 */
		private function update():void {
			dispatchEvent(new ModelEvent(ModelEvent.UPDATE, this));
		}
		
		
		
		
		//__________________________________________________________ MAP LOADING
		
		/**
		 * Called when a map's loading completes
		 */
		private function loadMapCompleteHandler(event:CommandEvent):void {
			var data:ByteArray = event.data as ByteArray;
			try {
				data.uncompress();
				data.position = 0;
			}catch(error:Error) {
				throw new Kub3ditException(Label.getLabel("unkownSaveFileType"), Kub3ditExceptionSeverity.MINOR);
				return;
			}
			var fileVersion:int = data.readByte();
			switch(fileVersion){
					
				case Constants.MAP_FILE_TYPE_1:
					_map = new Map(0,0,0);
					_map.load(data);
					update();
					break;
				
				case Constants.MAP_FILE_TYPE_2:
					var customs:uint = data.readUnsignedByte();
					var i:int, len:int, cube:CubeData;
					for(i = 0; i < customs; ++i) {
						len = data.readShort();
						cube = new CubeData();
						cube.populate(new XML(data.readUTFBytes(len)));
						Textures.getInstance().addKube(cube);
					}
					
					Camera3D.configure(data);
					
					_map = new Map(0,0,0);
					_map.load(data);
					update();
					break;
				
				default:
					throw new Kub3ditException(Label.getLabel("unkownSaveFileType"), Kub3ditExceptionSeverity.MINOR);
			}
		}
		
		/**
		 * Called if map loading fails
		 */
		private function loadMapErrorHandler(event:CommandEvent):void {
			throw new Kub3ditException(event.data as String, Kub3ditExceptionSeverity.MINOR);
		}
		
		/**
		 * Called when custom kube add completes
		 */
		private function addKubeCompleteHandler(event:CommandEvent):void {
			ViewLocator.getInstance().dispatchToViews(new LightModelEvent(LightModelEvent.KUBE_ADD_COMPLETE, null));
		}
		
		/**
		 * Called if custom kube add fails
		 */
		private function addKubeErrorHandler(event:CommandEvent):void {
			ViewLocator.getInstance().dispatchToViews(new LightModelEvent(LightModelEvent.KUBE_ADD_ERROR, null));
		}
		
	}
}