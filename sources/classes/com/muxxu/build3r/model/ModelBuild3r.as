package com.muxxu.build3r.model {
	import com.muxxu.build3r.views.LoadView;
	import com.muxxu.kub3dit.commands.BrowseForFileCmd;
	import com.muxxu.kub3dit.commands.LoadMapCmd;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.mvc.model.IModel;
	import com.nurun.structure.mvc.model.events.ModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;

	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	/**
	 * 
	 * @author Francois
	 * @date 19 févr. 2012;
	 */
	public class ModelBuild3r extends EventDispatcher implements IModel {
		
		private var _timer:Timer;
		private var _lastText:String;
		private var _postion:Point3D;
		private var _browseCmd:BrowseForFileCmd;
		private var _loadMapCmd:LoadMapCmd;
		private var _currentMap:Object;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ModelBuild3r</code>.
		 */
		public function ModelBuild3r() {
			
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the last forum's position.
		 */
		public function get postion():Point3D { return _postion; }
		
		/**
		 * Gets the map's data
		 */
		public function get currentMap():Object { return _currentMap; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Starts the application
		 */
		public function start():void {
			initialize();
		}
		
		/**
		 * Browses for an external map's file
		 */
		public function browseForMap():void {
			_browseCmd.execute();
		}
		
		/**
		 * Loads a map by its ID
		 */
		public function loadMapById(id:String, password:String):void {
			_loadMapCmd.id = id;
			_loadMapCmd.password = password;
			_loadMapCmd.execute();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_timer = new Timer(70);
			_timer.addEventListener(TimerEvent.TIMER, ticTimerHandler);
			_timer.start();
			
			_browseCmd = new BrowseForFileCmd("Kub3dit map", "*.map;");
			_browseCmd.addEventListener(CommandEvent.COMPLETE, loadMapCompleteHandler);
			_browseCmd.addEventListener(CommandEvent.ERROR, loadMapErrorHandler);
			
			_loadMapCmd = new LoadMapCmd(null, ViewLocator.getInstance().locateViewByType(LoadView) as LoadView);
			_loadMapCmd.addEventListener(CommandEvent.COMPLETE, loadMapCompleteHandler);
			_loadMapCmd.addEventListener(CommandEvent.ERROR, loadMapErrorHandler);
		}
		
		/**
		 * Fires an update to the views
		 */
		private function update():void {
			dispatchEvent(new ModelEvent(ModelEvent.UPDATE, this));
		}
		
		
		/**
		 * Called on timer's tic to get the zone coordinates.
		 */
		private function ticTimerHandler(event:TimerEvent):void {
			if(!ExternalInterface.available) return;
			
			var getZoneInfos:XML = 
		    <script><![CDATA[
		            function(){ return document.getElementById('infos').innerHTML; }
					setInterval(function(){showText();document.getElementById("text").innerHTML = "";}, 10)
		        ]]></script>;
		    
	        var text:String = ExternalInterface.call(getZoneInfos.toString()); 
		    
			//check if getting a forum
			if(text != _lastText && /return removeKube\(-?[0-9]+,-?[0-9]+,-?[0-9]+\)/.test(text)) {
				_lastText = text;
				var matches:Array = text.match(/-?[0-9]+/gi);
				_postion = new Point3D(parseInt(matches[1]), parseInt(matches[2]), parseInt(matches[3]));
				update();
			}
		}
		
		/**
		 * Called when map's loading completes
		 */
		private function loadMapCompleteHandler(event:CommandEvent):void {
			if(event.target == _loadMapCmd) {
				_currentMap = event.data;
			}else{
				_currentMap = event.data;
			}
			update();
		}
		
		/**
		 * Called if map's loading fails
		 */
		private function loadMapErrorHandler(event:CommandEvent):void {
			trace(event.data);
		}
	}
}