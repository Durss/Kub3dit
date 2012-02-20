package com.muxxu.build3r {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;

	/**
	 * 
	 * @author Francois
	 * @date 19 févr. 2012;
	 */
	public class Build3rLoader extends MovieClip {
	
		private var _backColor:Number;
		private var _barColor:Number;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Build3rLoader</code>.
		 */
		public function Build3rLoader() {
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
			stop();
			stage.align		= StageAlign.TOP_LEFT;
			stage.scaleMode	= StageScaleMode.NO_SCALE;
			stage.showDefaultContextMenu = false;
			
			_backColor		= parseInt(getFV("bgColor", "44526f"), 16);
			_barColor		= parseInt(getFV("loaderColor", "000000"), 16);
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Called on ENTER_FRAME event to update the progress bar.
		 */
		private function enterFrameHandler(event:Event):void {
			graphics.clear();
			if( (framesLoaded == totalFrames
					&& loaderInfo.bytesLoaded == loaderInfo.bytesTotal
					&& loaderInfo.bytesTotal > 1)) {
				
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				stage.addEventListener(Event.RESIZE, resizeHandler);
				resizeHandler();
				nextFrame();
				launch();
			} else {
				var w:int = 300; 
				var h:int = 6; 
				var percent:Number = (root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal);
				if(isNaN(percent)) percent = 0;
				var rect:Rectangle = new Rectangle(0,0,0,0);
				rect.x	= Math.round((stage.stageWidth - w) * .5);
				rect.y	= Math.round((stage.stageHeight - h) * .5);
				
				graphics.beginFill(_backColor, 1);
				graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
				graphics.endFill();
				
				graphics.lineStyle(1, _barColor, 1, true);
				graphics.drawRect(rect.x, rect.y, w, h);
				
				graphics.lineStyle(0, _barColor, 0);
				graphics.beginFill(_barColor, .5);
				graphics.drawRect(rect.x + 2, rect.y + 2, Math.round((w - 3) * percent), h - 3);
				graphics.endFill();
			}
		}
		
		/**
		 * Called when the stage is resized.
		 */
		private function resizeHandler(event:Event = null):void {
			//Drawing the background prevents from possible color override by
			//a profiler defined on the mm.cfg
			graphics.clear();
			graphics.beginFill(_backColor, 1);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
		}
		
		/**
		 * Launch the application
		 */
		private function launch():void {
			// on frame 2
			var mainClass:Class = Class(getDefinitionByName("com.muxxu.build3r.Build3r"));
			if(mainClass) {
				var app:Object = new mainClass();
				addChild(app as DisplayObject);
			}
		}
		
		/**
		 * Quick access to a flashvar with a default value.
		 */
		private function getFV(id:String, defaultValue:String):String {
			return (stage.loaderInfo.parameters[id] == undefined) ? defaultValue : stage.loaderInfo.parameters[id];
		}
	}
}