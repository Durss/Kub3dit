package com.muxxu.kub3dit.commands {
	import flash.events.IOErrorEvent;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.commands.Command;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	
	/**
	 * The  LoadMapCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to browse for a file and load it
	 *
	 * @author Francois
	 * @date 10 nov. 2011;
	 */
	public class BrowseForFileCmd extends EventDispatcher implements Command {
		
		private var _fr:FileReference;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  BrowseForFileCmd() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function execute():void {
			_fr.browse();
		}
		
		/**
		 * @inheritDoc
		 */
		public function halt():void {
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		private function initialize():void {
			_fr = new FileReference();
			_fr.addEventListener(Event.COMPLETE, loadCompleteHandler);
			_fr.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_fr.addEventListener(Event.SELECT, selectFileHandler);
		}
		
		/**
		 * Called if file's loading fails
		 */
		private function loadErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, event.text));
		}
		
		/**
		 * Called when file loading completes
		 */
		private function loadCompleteHandler(event:Event):void {
			dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, _fr.data));
		}
		
		/**
		 * Called when a file is selected
		 */
		private function selectFileHandler(event:Event):void {
			_fr.load();
		}
	}
}
