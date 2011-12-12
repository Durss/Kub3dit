package com.muxxu.kub3dit {
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.model.Model;
	import com.muxxu.kub3dit.views.DownloadView;
	import com.muxxu.kub3dit.views.EditorView;
	import com.muxxu.kub3dit.views.LockView;
	import com.muxxu.kub3dit.views.MainMenuView;
	import com.muxxu.kub3dit.views.ProgressView;
	import com.muxxu.kub3dit.views.SplashScreenView;
	import com.muxxu.kub3dit.views.Stage3DView;
	import com.muxxu.kub3dit.views.ToolTipView;
	import com.nurun.structure.mvc.views.ViewLocator;

	import org.libspark.ui.SWFWheel;

	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	/**
	 * Bootstrap class of the application.
	 * Must be set as the main class for the flex sdk compiler
	 * but actually the real bootstrap class will be the factoryClass
	 * designated in the metadata instruction.
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	 
	[SWF(width="1024", height="768", backgroundColor="0xFFFFFF", frameRate="31")]
	[Frame(factoryClass="com.muxxu.kub3dit.ApplicationLoader")]
	public class Application extends MovieClip {
		
		private var _model:Model;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Application</code>.
		 */
		public function Application() {
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
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
			_model = new Model();
			FrontControler.getInstance().initialize(_model);
			ViewLocator.getInstance().initialise(_model);

			addChild(new Stage3DView());
			addChild(new EditorView());
			addChild(new MainMenuView());
			addChild(new SplashScreenView());
			addChild(new LockView());
			addChild(new ProgressView());
			addChild(new DownloadView());
			addChild(new ToolTipView());
//			addChild(new Stats()).y = 50;
			
			_model.start();
		}

		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			initialize();
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			SWFWheel.initialize(stage);
			
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
				
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			
		}
		
	}
}