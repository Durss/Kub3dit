package com.muxxu.kub3dit.commands {
	/**
	 * @author Francois
	 */
	public interface IPassView {
		
		/**
		 * Opens the password ask view.
		 * 
		 * @param args[0]	function to call to proceed loading
		 */
		function open(...args):void;
		
		/**
		 * Called if password is wrong
		 */
		function error():void;
		
		/**
		 * Closes the view
		 */
		function close():void;
		
	}
}
