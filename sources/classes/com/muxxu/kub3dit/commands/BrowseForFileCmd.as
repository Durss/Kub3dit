package com.muxxu.kub3dit.commands {
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.net.FileFilter;
	import flash.events.IOErrorEvent;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.commands.Command;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	
	[Event(name="onCommandComplete", type="com.nurun.core.commands.events.CommandEvent")]
	[Event(name="onCommandError", type="com.nurun.core.commands.events.CommandEvent")]
	
	/**
	 * The  LoadMapCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to browse for a file and load it
	 *
	 * @author Francois
	 * @date 10 nov. 2011;
	 */
	public class BrowseForFileCmd extends EventDispatcher implements Command {
		
		private var _fr:FileReference;
		private var _validExtensions:String;
		private var _filterLabel:String;
		private var _bitmapType:Boolean;
		private var _loader:Loader;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  BrowseForFileCmd(filterLabel:String = null, validExtensions:String = null, bitmapType:Boolean = false) {
			_bitmapType = bitmapType;
			_filterLabel = filterLabel;
			_validExtensions = validExtensions;
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
			var extensions:Array;
			if(_validExtensions != null) {
				extensions = [new FileFilter(_filterLabel, _validExtensions)];
			}
			_fr.browse(extensions);
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
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBitmapCompleteHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadBitmapErrorHandler);
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
			if(_bitmapType) {
				_loader.loadBytes(_fr.data);
			}else{
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, _fr.data));
			}
		}
		
		/**
		 * Called when a file is selected
		 */
		private function selectFileHandler(event:Event):void {
			_fr.load();
		}
		
		/**
		 * Called when bitmap loading completes.
		 */
		private function loadBitmapCompleteHandler(event:Event):void {
			dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, Bitmap(_loader.content).bitmapData.clone()));
		}
		
		/**
		 * Called if bitmap loading fails
		 */
		private function loadBitmapErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, event.text));
		}
	}
}
