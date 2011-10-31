package com.muxxu.kub3dit.commands {
	import com.muxxu.kub3dit.exceptions.Kub3ditExceptionSeverity;
	import com.muxxu.kub3dit.exceptions.Kub3ditException;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import flash.display.BitmapData;
	import com.nurun.utils.commands.LoadBitmapFileCmd;
	import com.nurun.core.commands.SequentialCommand;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.commands.LoadFileCmd;
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.AbstractCommand;
	import com.nurun.core.commands.events.CommandEvent;

	/**
	 * The  InitTexturesCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to initialize the textures
	 *
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class InitTexturesCmd extends AbstractCommand implements Command {
		private var _spool:SequentialCommand;
		private var _spriteSheetCmd:LoadBitmapFileCmd;
		private var _spriteMapCmd:LoadFileCmd;
		private var _spriteAddsCmd:LoadFileCmd;
		private var _bmd:BitmapData;
		private var _map:*;
		private var _adds:*;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  InitTexturesCmd() {
			super();
			_spool = new SequentialCommand();
			_spool.addEventListener(CommandEvent.COMPLETE, spoolCompleteHandler);
			_spool.addEventListener(CommandEvent.ERROR, spoolErrorHandler);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Execute the concrete InitTexturesCmd command.
		 * Must dispatch the CommandEvent.COMPLETE event when done.
		 */
		public override function execute():void {
			_spriteSheetCmd = new LoadBitmapFileCmd(Config.getPath("spritesheet"));
			_spriteMapCmd = new LoadFileCmd(Config.getPath("spritemap"));
			_spriteAddsCmd = new LoadFileCmd(Config.getPath("spriteadditionals"));
			
			_spriteSheetCmd.addEventListener(CommandEvent.COMPLETE, cmdCompleteHandler);
			_spriteMapCmd.addEventListener(CommandEvent.COMPLETE, cmdCompleteHandler);
			_spriteAddsCmd.addEventListener(CommandEvent.COMPLETE, cmdCompleteHandler);
			
			_spool.addCommand(_spriteSheetCmd);
			_spool.addCommand(_spriteMapCmd);
			_spool.addCommand(_spriteAddsCmd);
			_spool.execute();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called when all the loadings are complete.
		 * Initalizes the textures
		 */
		private function spoolCompleteHandler(event:CommandEvent):void {
			Textures.getInstance().initialize(_map, _adds, _bmd);
			dispatchEvent(event);
		}
		
		/**
		 * Called if a loading fails
		 */
		private function spoolErrorHandler(event:CommandEvent):void {
			throw new Kub3ditException(event.data as String, Kub3ditExceptionSeverity.FATAL);
		}
		
		/**
		 * Called when a loading completes
		 */
		private function cmdCompleteHandler(event:CommandEvent):void {
			if(event.target == _spriteSheetCmd) {
				_bmd = _spriteSheetCmd.bitmap.bitmapData.clone();
			}
			if(event.target == _spriteMapCmd) {
				_map = _spriteMapCmd.loader.data;
			}
			if(event.target == _spriteAddsCmd) {
				_adds = _spriteAddsCmd.loader.data;
			}
		}
	}
}
