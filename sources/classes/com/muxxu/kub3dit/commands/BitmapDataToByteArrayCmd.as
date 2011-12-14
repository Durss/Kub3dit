package com.muxxu.kub3dit.commands {
	import by.blooddy.crypto.image.PNGEncoder;

	import com.nurun.core.commands.AbstractCommand;
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;

	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * The  BitmapDataToByteArrayCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to convert a BitmapData to a ByteArray
	 *
	 * @author Francois
	 * @date 12 déc. 2011;
	 */
	public class BitmapDataToByteArrayCmd extends AbstractCommand implements Command {
		
		private var _bmd:BitmapData;
		private var _data:ByteArray;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  BitmapDataToByteArrayCmd(bmd:BitmapData) {
			_bmd = bmd;
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		/**
		 * Gets the encoded data
		 */
		public function get data():ByteArray { return _data; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Execute the concrete BitmapDataToByteArrayCmd command.
		 * Must dispatch the CommandEvent.COMPLETE event when done.
		 */
		public override function execute():void {
			_data = PNGEncoder.encode(_bmd);
			dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
		}
	}
}
