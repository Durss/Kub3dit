package com.muxxu.kub3dit.commands {
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.nurun.core.commands.AbstractCommand;
	import com.nurun.core.commands.ProgressiveCommand;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.commands.events.ProgressiveCommandEvent;

	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	/**
	 * The  ReplaceKubeCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to replace a kube by an other one in the whole map
	 *
	 * @author Francois
	 * @date 11 mai 2012;
	 */
	public class ReplaceKubeCmd extends AbstractCommand implements ProgressiveCommand {
		private var _replacer:int;
		private var _replaced:int;
		private var _efTarget:Shape;
		private var _map:Map;
		private var _width:int;
		private var _height:int;
		private var _depth:int;
		private var _i:int;
		private var _chunksManager:ChunksManager;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  ReplaceKubeCmd() {
			super();
			_efTarget = new Shape();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the kube's ID to be replaced
		 */
		public function set replacerID(value:int):void {
			_replacer = value;
		}
		
		/**
		 * Sets the kube's ID to be replaced by
		 */
		public function set replacedID(value:int):void {
			_replaced = value;
		}
		
		/**
		 * Sets the map's refference
		 */
		public function set map(value:Map):void {
			_map = value;
			_width = _map.mapSizeX;
			_height = _map.mapSizeY;
			_depth = _map.mapSizeZ;
		}
		
		/**
		 * Sets the chuncks manager's refference
		 */
		public function set chunksManager(value:ChunksManager):void {
			_chunksManager = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get done():Number { return _i/(_width * _height); }

		/**
		 * @inheritDoc
		 */
		public function get progress():Number { return done; }

		/**
		 * @inheritDoc
		 */
		public function get total():Number { return 1; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Execute the concrete ReplaceKubeCmd command.
		 * Must dispatch the CommandEvent.COMPLETE event when done.
		 */
		public override function execute():void {
			// Command Execution
			_i = 0;
			_efTarget.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * 
		 */
		private function enterFrameHandler(event:Event):void {
			var px:int, py:int, pz:int, tile:int, upperTile:int, upperTileZ:int;
			var s:int = getTimer();
			var length:int = _width * _height;
			//Draw col by col
			do{
				px = _i % _width;
				py = Math.floor(_i/_width);
				pz = _depth - 1;
				upperTile = 0;
				upperTileZ = pz;
				do {
					tile = _map.getTile(px, py, pz);
					if(tile == _replaced) {
						_chunksManager.addInvalidableCube(px, py, pz, _replacer);
					}
					pz --;
				}while(pz > -1);
				_i++;
			}while(_i<length && getTimer()-s < 25);
			
			_chunksManager.invalidate();
			
			if(_i > length-1) {
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
				_efTarget.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
			
			dispatchEvent(new ProgressiveCommandEvent(ProgressiveCommandEvent.PROGRESS));
		}
	}
}
