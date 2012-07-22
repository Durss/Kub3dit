package com.muxxu.kub3dit {
	import com.asual.swfaddress.SWFAddress;
	import gs.plugins.BezierThroughPlugin;
	import com.nurun.structure.environnement.label.Label;
	import com.muxxu.kub3dit.exceptions.Kub3ditExceptionSeverity;
	import com.muxxu.kub3dit.exceptions.Kub3ditException;
	import flash.external.ExternalInterface;
	import gs.plugins.RemoveChildPlugin;
	import gs.plugins.TweenPlugin;

	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.model.Model;
	import com.muxxu.kub3dit.views.Build3rView;
	import com.muxxu.kub3dit.views.EditorView;
	import com.muxxu.kub3dit.views.ExceptionView;
	import com.muxxu.kub3dit.views.LockView;
	import com.muxxu.kub3dit.views.MapPasswordView;
	import com.muxxu.kub3dit.views.ProgressView;
	import com.muxxu.kub3dit.views.SaveView;
	import com.muxxu.kub3dit.views.SplashScreenView;
	import com.muxxu.kub3dit.views.Stage3DView;
	import com.muxxu.kub3dit.views.StatsView;
	import com.muxxu.kub3dit.views.ToolTipView;
	import com.nurun.structure.mvc.views.ViewLocator;

	import org.libspark.ui.SWFWheel;

	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

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
			TweenPlugin.activate([RemoveChildPlugin, BezierThroughPlugin]);
			FrontControler.getInstance().initialize(_model);
			ViewLocator.getInstance().initialise(_model);

			addChild(new Stage3DView());
			addChild(new EditorView());
			addChild(new SplashScreenView());
			addChild(new SaveView());
			addChild(new MapPasswordView());
			addChild(new StatsView());
			addChild(new Build3rView());
			addChild(new LockView());
			addChild(new ProgressView());
			addChild(new ExceptionView());
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
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			computePositions();
		}
		
		/**
		 * Called when a key is released
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.Z && event.ctrlKey) {
				FrontControler.getInstance().undo();
			}else
			if(event.keyCode == Keyboard.Y && event.ctrlKey) {
				FrontControler.getInstance().redo();
			}else
			if(event.keyCode == Keyboard.S && event.ctrlKey) {
				FrontControler.getInstance().saveMap();
			}else
			if(event.keyCode == Keyboard.PAGE_DOWN && event.ctrlKey) {
				FrontControler.getInstance().nextMap();
			}else
			if(event.keyCode == Keyboard.PAGE_UP && event.ctrlKey) {
				FrontControler.getInstance().prevMap();
			}else
			if(event.keyCode == Keyboard.F && event.ctrlKey) {
				if(StageDisplayState["FULL_SCREEN_INTERACTIVE"] != undefined) {
					stage.displayState = stage.displayState == StageDisplayState.NORMAL? StageDisplayState["FULL_SCREEN_INTERACTIVE"] : StageDisplayState.NORMAL;
				}
			}
		}
				
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			if(ExternalInterface.available) {
				var js:XML = 
			 	   <script><![CDATA[
			            function(){ return DetectZoom.ratios().zoom; }
			        ]]></script>;
			    
		        var value:Number = parseFloat(ExternalInterface.call(js.toString())); 
				if(value > 1) {
					throw new Kub3ditException(Label.getLabel("zoomLevelError").replace(/\{ZOOM\}/gi, value), Kub3ditExceptionSeverity.INFO);
				}
			}
			
		}
		
	}
}