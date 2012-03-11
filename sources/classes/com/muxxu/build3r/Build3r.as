package com.muxxu.build3r {
	import com.muxxu.build3r.controler.FrontControlerBuild3r;
	import com.muxxu.build3r.model.ModelBuild3r;
	import com.muxxu.build3r.views.BuildView;
	import com.muxxu.build3r.views.CloseView;
	import com.muxxu.build3r.views.LoadView;
	import com.muxxu.build3r.views.SynchView;
	import com.muxxu.kub3dit.views.ToolTipView;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.text.CssManager;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.ByteArray;

	/**
	 * Bootstrap class of the application.
	 * Must be set as the main class for the flex sdk compiler
	 * but actually the real bootstrap class will be the factoryClass
	 * designated in the metadata instruction.
	 * 
	 * @author Francois
	 * @date 19 févr. 2012;
	 */
	 
	[SWF(width="191", height="271", backgroundColor="0xFFFFFF", frameRate="31")]
	[Frame(factoryClass="com.muxxu.build3r.Build3rLoader")]
	public class Build3r extends MovieClip {
		
		private var _model:ModelBuild3r;
		[Embed(source="../../../../../deploy/css/flashstyles.css", mimeType="application/octet-stream")]
		private var _styles:Class;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Application</code>.
		 */
		public function Build3r() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			CssTextField.EMBED_FONT = false;
			var ba:ByteArray = new _styles() as ByteArray;
			CssManager.getInstance().setCss(ba.readUTFBytes(ba.length));
			Config.addPath("loadMapPath", "http://fevermap.org/kub3dit/php/loadMap.php");
			
			_model = new ModelBuild3r();
			
			FrontControlerBuild3r.getInstance().initialize(_model);
			ViewLocator.getInstance().initialise(_model);
			
			addChild(new LoadView());
			addChild(new SynchView());
			addChild(new BuildView());
			addChild(new CloseView());
			addChild(new ToolTipView(true));
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available
		 */
		private function addedToStageHandler(event:Event):void {
			_model.start();
		}
		
	}
}