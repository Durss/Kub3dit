package com.muxxu.kub3dit.model {
	import by.blooddy.crypto.image.PNGEncoder;

	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import com.muxxu.kub3dit.commands.AddKubeCmd;
	import com.muxxu.kub3dit.commands.BrowseForFileCmd;
	import com.muxxu.kub3dit.commands.GenerateRadarAndLevelsCmd;
	import com.muxxu.kub3dit.commands.InitTexturesCmd;
	import com.muxxu.kub3dit.commands.LoadMapCmd;
	import com.muxxu.kub3dit.commands.ReplaceKubeCmd;
	import com.muxxu.kub3dit.commands.UploadMapCmd;
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.exceptions.Kub3ditException;
	import com.muxxu.kub3dit.exceptions.Kub3ditExceptionSeverity;
	import com.muxxu.kub3dit.views.MapPasswordView;
	import com.muxxu.kub3dit.views.SaveView;
	import com.muxxu.kub3dit.vo.Constants;
	import com.muxxu.kub3dit.vo.MapDataParser;
	import com.nurun.core.commands.ProgressiveCommand;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.commands.events.ProgressiveCommandEvent;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;

	import flash.display.BitmapData;
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
		private var _saveCmd:GenerateRadarAndLevelsCmd;
		private var _saveData:ByteArray;
		private var _uploadCmd:UploadMapCmd;
		private var _loadMapCmd:LoadMapCmd;
		private var _ignoreLoadId:String;
		private var _ignoreNextURLChange:Boolean;
		private var _replaceCmd:ReplaceKubeCmd;
		private var _chunksManager:ChunksManager;
		private var _lastLoadedMapID:String;
		
		
		
		
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
		
		/**
		 * Sets the chuncks manager's reference
		 */
		public function set chunksManager(value:ChunksManager):void {
			_chunksManager = value;
		}



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
			if(_saveCmd != null) {
				_saveCmd.removeEventListener(CommandEvent.COMPLETE, saveGenerationCompleteHandler);
				_saveCmd.removeEventListener(CommandEvent.ERROR, saveGenerationErrorHandler);
			}
			_saveCmd = new GenerateRadarAndLevelsCmd(_map.data, _map.mapSizeX, _map.mapSizeY, _map.mapSizeZ);
			_saveCmd.addEventListener(CommandEvent.COMPLETE, saveGenerationCompleteHandler);
			_saveCmd.addEventListener(CommandEvent.ERROR, saveGenerationErrorHandler);
			_saveCmd.addEventListener(ProgressiveCommandEvent.PROGRESS, commandProgressHandler);
			_saveCmd.execute();
			lock();
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
			if(_map == null) _map = new Map();
			_map.generateEmptyMap(sizeX * 32, sizeY * 32, sizeZ);
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
		
		/**
		 * Downloads the map's levels
		 */
//		public function downloadMapLevels():void {
//			var i:int, len:int;
//			len = _saveCmd.levelsData.length;
//			var zipOut:ZipOutput = new ZipOutput();
//			for(i = 0; i < len; ++i) {
//				var fileName:String = (i+1)+".png";
//				var ze:ZipEntry = new ZipEntry(fileName);
//				zipOut.putNextEntry(ze);
//				zipOut.write( _saveCmd.levelsData[i] );
//				zipOut.closeEntry();
//			}
//			zipOut.finish();
//			var fr:FileReference = new FileReference();
//			fr.save(zipOut.byteArray, "kub3dit-map.zip");
//		}
		
		/**
		 * Downloads the map
		 */
		public function downloadMap():void {
			var fr:FileReference = new FileReference();
			fr.save(_saveData, "kub3dit-map.png");
		}
		
		/**
		 * Downloads the map
		 */
		public function uploadMap(modify:Boolean, pass:String):void {
			lock();
			_uploadCmd = new UploadMapCmd(_saveData, modify, pass);
			_uploadCmd.addEventListener(CommandEvent.COMPLETE, uploadCompleteHandler);
			_uploadCmd.addEventListener(CommandEvent.ERROR, uploadErrorHandler);
			_uploadCmd.execute();
		}
		
		/**
		 * Updates the uploaded map
		 */
		public function updateUploadedMap(id:String):void {
			lock();
			_uploadCmd = new UploadMapCmd(_saveData, false, "", id);
			_uploadCmd.addEventListener(CommandEvent.COMPLETE, uploadCompleteHandler);
			_uploadCmd.addEventListener(CommandEvent.ERROR, uploadErrorHandler);
			_uploadCmd.execute();
		}
		
		/**
		 * Exports a selection
		 */
		public function exportSelection(data:ByteArray, width:int, height:int, depth:int):void {
			if(_saveCmd != null) {
				_saveCmd.removeEventListener(CommandEvent.COMPLETE, saveGenerationCompleteHandler);
				_saveCmd.removeEventListener(CommandEvent.ERROR, saveGenerationErrorHandler);
			}
			_saveCmd = new GenerateRadarAndLevelsCmd(data, width, height, depth);
			_saveCmd.addEventListener(CommandEvent.COMPLETE, saveGenerationCompleteHandler);
			_saveCmd.addEventListener(CommandEvent.ERROR, saveGenerationErrorHandler);
			_saveCmd.addEventListener(ProgressiveCommandEvent.PROGRESS, commandProgressHandler);
			_saveCmd.execute();
			lock();
		}
		
		/**
		 * Replaces a kube by an other one in the whole map.
		 */
		public function replaceKubes(replacer:int, replaced:int):void {
			_replaceCmd.replacerID = replacer;
			_replaceCmd.replacedID = replaced;
			_replaceCmd.map = _map;
			_replaceCmd.chunksManager = _chunksManager;
			_replaceCmd.execute();
		}
		
		/**
		 * Undo the last action
		 */
		public function undo():void {
			_chunksManager.undo();
		}
		
		/**
		 * Redo the last action
		 */
		public function redo():void {
			_chunksManager.redo();
		}
		
		/**
		 * Saves the current modification history
		 */
		public function saveHistory():void {
			_chunksManager.saveCurrentHistory();
		}
		
		/**
		 * Plays a path by its ID.
		 */
		public function playPathByID(id:String):void {
			var mapId:String = (_lastLoadedMapID == null)? "--" : _lastLoadedMapID;
			var value:String = mapId+"/"+id;
			var currentValue:String = SWFAddress.getValue();
			while(currentValue.charAt(0) == "/") currentValue = currentValue.slice(1);
			
			if(value != currentValue) {
				SWFAddress.setValue(value);
			}else{
				_map.followPathById(parseInt(id));
			}
		}
		
		/**
		 * Shows up the progress bar and locks the UI
		 */
		public function showProgress(percent:Number):void {
			dispatchEvent(new LightModelEvent(LightModelEvent.PROGRESS, percent));
			if(percent < 1) {
				lock();
			}else{
				unlock();
			}
		}
		

		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_currentKubeId = "3";//Defaulty selected kube
			_replaceCmd = new ReplaceKubeCmd();
//			_replaceCmd.addEventListener(CommandEvent.COMPLETE, replaceCompleteHandler);
//			_replaceCmd.addEventListener(CommandEvent.ERROR, replaceErrorHandler);
			_replaceCmd.addEventListener(ProgressiveCommandEvent.PROGRESS, commandProgressHandler);
		}
		
		/**
		 * Called when textures are ready
		 */
		private function initCompleteHandler(event:CommandEvent):void {
			update();
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, changeAddressHandler);
		}
		
		/**
		 * Called when URL changes
		 */
		private function changeAddressHandler(event:SWFAddressEvent):void {
			if(_ignoreNextURLChange) {
				_ignoreNextURLChange = false;
				return;
			}
			var value:String = SWFAddress.getValue();
			while(value.charAt(0) == "/") value = value.slice(1);

			var chunks:Array = value.split("/");
//			chunks[0] = "z";
//			chunks[0] = "e8";
//			chunks[1] = "4";
			
			var id:String = String(chunks[0]).replace(/[^A-Za-z0-9]/g, "");
			if(id.length > 0 && _ignoreLoadId != id && id != _lastLoadedMapID) {
//				lock();
				_lastLoadedMapID = id;
				var passView:MapPasswordView = ViewLocator.getInstance().locateViewByType(MapPasswordView) as MapPasswordView;
				var saveView:SaveView = ViewLocator.getInstance().locateViewByType(SaveView) as SaveView;
				_loadMapCmd = new LoadMapCmd(id, passView, saveView, chunks[1]);
				_loadMapCmd.addEventListener(CommandEvent.COMPLETE, loadMapCompleteHandler);
				_loadMapCmd.addEventListener(CommandEvent.ERROR, loadMapErrorHandler);
				_loadMapCmd.execute();
			}else{
				if(chunks[1] != null) {
					if(_map != null) {
						_map.followPathById(parseInt(chunks[1]));
					}else{
						_loadMapCmd.updateCamPath(chunks[1]);
					}
				}
			}
			_ignoreLoadId = null;
		}
		
		/**
		 * Fire an update to the views
		 */
		private function update():void {
			dispatchEvent(new ModelEvent(ModelEvent.UPDATE, this));
		}
		
		/**
		 * Called during a progression
		 */
		private function commandProgressHandler(event:ProgressiveCommandEvent):void {
			dispatchEvent(new LightModelEvent(LightModelEvent.PROGRESS, ProgressiveCommand(event.target).progress));
		}
		
		/**
		 * Locks the UI
		 */
		private function lock():void {
			dispatchEvent(new LightModelEvent(LightModelEvent.LOCK));
		}

		/**
		 * Unlocks the UI
		 */
		private function unlock():void {
			dispatchEvent(new LightModelEvent(LightModelEvent.UNLOCK));
		}

		
		
		
		
		//__________________________________________________________ MAP LOADING
		
		/**
		 * Called when a map's loading completes
		 */
		private function loadMapCompleteHandler(event:CommandEvent):void {
			unlock();
			
			if(event.currentTarget is LoadMapCmd) {
				LoadMapCmd(event.currentTarget).editable;
			}
			Textures.getInstance().removeCustomKubes();
			_map = MapDataParser.parse(event.data as ByteArray, true, true, _map);
			
			
			if(event.currentTarget is LoadMapCmd) {
				var id:String = LoadMapCmd(event.currentTarget).camPathToLoad;
				if(id != null) {
//					setTimeout(_map.followPathById, 1500, id);
					_map.followPathById(parseInt(id));
				}
			}
			
			update();
			dispatchEvent(new LightModelEvent(LightModelEvent.NEW_MAP_LOADED));
		}
		
		/**
		 * Called if map loading fails
		 */
		private function loadMapErrorHandler(event:CommandEvent):void {
			unlock();
			
			//Ignore loading fired by URL change
			if(event.currentTarget is LoadMapCmd) return;
			
			throw new Kub3ditException(event.data as String, Kub3ditExceptionSeverity.MINOR);
		}
		
		
		
		
		//__________________________________________________________ CUSTOM KUBES
		
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
		
		
		
		
		
		
		//__________________________________________________________ MAP SAVE
		
		/**
		 * Called when save generation completes
		 */
		private function saveGenerationCompleteHandler(event:CommandEvent):void {
			var bmd:BitmapData = _saveCmd.bitmapData;
			var cmd:GenerateRadarAndLevelsCmd = event.currentTarget as GenerateRadarAndLevelsCmd;
			
			var ba:ByteArray = new ByteArray();
			//============FILE TYPE============
			ba.writeByte(Constants.MAP_FILE_TYPE_3);
			
			//============CUSTOM CUBES============
			var i:int, len:int;
			len = Textures.getInstance().customKubes.length;
			ba.writeByte(len);
			for(i = 0; i < len; ++i) {
				//No need to store the string's length before it because writeUTF already does that \o/
				ba.writeUTF( Textures.getInstance().customKubes[i].rawData.toXMLString() );
			}
			
			//============CAMERA CONF============
			ba.writeShort(Camera3D.locX);
			ba.writeShort(Camera3D.locY);
			ba.writeShort(Camera3D.locZ);
			ba.writeUnsignedInt(Camera3D.rotationX);
			ba.writeInt(Camera3D.rotationY);
			
			//============CAMERA PATHS============
			ba.writeObject(_map.cameraPaths);
			
			//============MAP SIZES============
			ba.writeShort(cmd.width);
			ba.writeShort(cmd.height);
			ba.writeShort(cmd.depth);
			
			//============MAP DATA============
			cmd.data.position = 0;
			cmd.data.readBytes(ba,ba.length);
			
			
			//Compression and save
			ba.compress();
			ba.position = 0;
			_saveData = PNGEncoder.encode(bmd);
			_saveData.position = _saveData.length;
			_saveData.writeBytes(ba);
			_saveData.writeUnsignedInt(ba.length);
			_saveData.writeUnsignedInt(0x2e4b3344);// write ".K3D" tag
			_saveData.position = 0 ;
			
			dispatchEvent(new LightModelEvent(LightModelEvent.SAVE_MAP_GENERATION_COMPLETE, _saveData));
			
			unlock();
		}
		
		/**
		 * Called if saving failed
		 */
		private function saveGenerationErrorHandler(event:CommandEvent):void {
			//TODO display error
			unlock();
		}
		
		
		
		
		//__________________________________________________________ MAP UPLOAD
		
		/**
		 * Called when map's upload completes
		 */
		private function uploadCompleteHandler(event:CommandEvent):void {
			unlock();
			_ignoreLoadId = event.data as String;
			dispatchEvent(new LightModelEvent(LightModelEvent.MAP_UPLOAD_COMPLETE, _ignoreLoadId));
			SWFAddress.setValue(_ignoreLoadId);//let this at last! SWFAddress callback sets this var to null
			_ignoreNextURLChange = true;
		}

		/**
		 * Called if map's upload fails
		 */
		private function uploadErrorHandler(event:CommandEvent):void {
			unlock();
			dispatchEvent(new LightModelEvent(LightModelEvent.MAP_UPLOAD_ERROR));
			throw new Kub3ditException(Label.getLabel("uploadMapError"), Kub3ditExceptionSeverity.MINOR);
		}
		
	}
}