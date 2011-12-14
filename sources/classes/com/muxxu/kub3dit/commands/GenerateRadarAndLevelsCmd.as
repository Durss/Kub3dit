package com.muxxu.kub3dit.commands {
	import com.nurun.utils.commands.DummyCommand;
	import com.nurun.core.commands.SequentialCommand;
	import flash.utils.ByteArray;
	import com.nurun.core.commands.events.ProgressiveCommandEvent;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.nurun.core.commands.AbstractCommand;
	import com.nurun.core.commands.ProgressiveCommand;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.environnement.configuration.Config;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	/**
	 * The  GenerateRadarCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to generate the radar view for map save and the levels
	 * for levels export.
	 *
	 * @author Francois
	 * @date 11 déc. 2011;
	 */
	public class GenerateRadarAndLevelsCmd extends AbstractCommand implements ProgressiveCommand {
		
		private var _efTarget:Shape;
		private var _map:Map;
		private var _colors:Array;
		private var _i:int;
		private var _bmd:BitmapData;
		private var _levels:Vector.<BitmapData>;
		private var _levelsData:Vector.<ByteArray>;
		private var _encodeSpool:SequentialCommand;
		private var _encoded:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  GenerateRadarAndLevelsCmd(map:Map) {
			_map = map;
			_efTarget = new Shape();
			_colors = Textures.getInstance().levelColors;
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		/**
		 * Gets the image
		 */
		public function get bitmapData():BitmapData { return _bmd; }
		
		/**
		 * @inheritDoc
		 */
		public function get done():Number { return _i/(_map.mapSizeX * _map.mapSizeY) * .5 + (_encoded/_levels.length) * .5; }

		/**
		 * @inheritDoc
		 */
		public function get progress():Number { return done; }

		/**
		 * @inheritDoc
		 */
		public function get total():Number { return 1; }
		
		/**
		 * Gets the levels bitmapDatas
		 */
		public function get levelsData():Vector.<ByteArray> { return _levelsData; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Execute the concrete GenerateRadarCmd command.
		 * Must dispatch the CommandEvent.COMPLETE event when done.
		 */
		public override function execute():void {
			// Command Execution
			_i = 0;
			_bmd = new BitmapData(_map.mapSizeX, _map.mapSizeY, false, 0xff47A9D1);
			var i:int, len:int;
			len = Config.getNumVariable("mapSizeHeight");
			_levels = new Vector.<BitmapData>(len, true);
			_levelsData = new Vector.<ByteArray>(len, true);
			for(i = 0; i < len; ++i) {
				_levels[i] = _bmd.clone();
			}
			
			_efTarget.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called on enter frame to render a batch of pixels
		 */
		private function enterFrameHandler(event:Event):void {
			var px:int, py:int, pz:int, tile:int, upperTile:int, upperTileZ:int;
			var s:int = getTimer();
			var h:int = Config.getNumVariable("mapSizeHeight");
			var length:int = _map.mapSizeX * _map.mapSizeY;
			do{
				px = _i % _map.mapSizeX;
				py = Math.floor(_i/_map.mapSizeX);
				pz = h;
				upperTile = 0;
				upperTileZ = pz;
				do {
					tile = _map.getTile(px, py, pz);
					if(tile > 0) {
						_levels[pz].setPixel32(px, py, 0xff000000 + _colors[tile][pz]);
					}
					if(upperTile == 0 && tile > 0) {
						upperTile = tile;
						upperTileZ = pz;
					}
					pz --;
				}while(pz > -1);
				
				if(upperTile > 0) {
					_bmd.setPixel32(px, py, 0xff000000 + _colors[upperTile][upperTileZ]);
				}
				_i++;
			}while(_i<length && getTimer()-s < 40);
			
			if(_i > length-1) {
				_encodeSpool = new SequentialCommand();
				var i:int, len:int, cmd:BitmapDataToByteArrayCmd;
				len = _levels.length;
				_encoded = 0;
				//Encode all the bitmapDatas to ByteArrays
				for(i = 0; i < len; ++i) {
					cmd = new BitmapDataToByteArrayCmd(_levels[i]);
					cmd.addEventListener(CommandEvent.COMPLETE, encodeImageCompleteHandler);
					_encodeSpool.addCommand(cmd);
					_encodeSpool.addCommand(new DummyCommand(100));
				}
				_encodeSpool.addEventListener(CommandEvent.COMPLETE, encodeCompleteHandler);
				_encodeSpool.execute();
				_efTarget.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
			dispatchEvent(new ProgressiveCommandEvent(ProgressiveCommandEvent.PROGRESS));
		}
		
		/**
		 * Called when one image's encoding completes
		 */
		private function encodeImageCompleteHandler(event:CommandEvent):void {
			_levelsData[_encoded] = BitmapDataToByteArrayCmd(event.target).data;
			_encoded ++;
			dispatchEvent(new ProgressiveCommandEvent(ProgressiveCommandEvent.PROGRESS));
		}
		
		/**
		 * Called when image's encoding completes
		 */
		private function encodeCompleteHandler(event:CommandEvent):void {
			dispatchEvent(new ProgressiveCommandEvent(ProgressiveCommandEvent.PROGRESS));
			dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
		}
	}
}
