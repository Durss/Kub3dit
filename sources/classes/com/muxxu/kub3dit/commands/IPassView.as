package com.muxxu.kub3dit.commands {
	/**
	 * @author Francois
	 */
	public interface IPassView {
		
		/**
		 * Opens the password ask view.
		 * 
		 * @param passwordCallback	function to call to proceed loading
		 */
		function open(passwordCallback:Function):void;
		
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
