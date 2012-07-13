package com.muxxu.kub3dit.components.editor.toolpanels.terragen {
	import flash.events.Event;
	import com.muxxu.build3r.components.Build3rSlider;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.components.text.CssTextField;
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 1 juil. 2012;
	 */
	public class GroundRatioStep extends Sprite {
		private var _label:CssTextField;
		private var _heigtValues:Array;
		private var _maxheight:int;
		private var _slider:Build3rSlider;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>GroundRatioStep</code>.
		 */
		public function GroundRatioStep() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the ground's ratio
		 */
		public function get ratio():Number {
			return _slider.value/_slider.maxValue;
		}



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
			_label = addChild(new CssTextField("tool-label")) as CssTextField;
			_label.text = Label.getLabel("toolConfig-terragen-ratios");
			_slider = addChild(new Build3rSlider(1, 31)) as Build3rSlider;
			
			_slider.value = 20;
			_slider.addEventListener(Event.CHANGE, renderGraph);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			_heigtValues = [];
			var i:int, len:int, rand:Number, endRand:Number;
			_maxheight = 31*5;
			rand = endRand = 0;
			len = 60;
			for(i = 0; i < len; ++i) {
				//ease the random to get smoother random hollows
				rand += (endRand - rand) * .5;
				if(Math.random() > .8 || i == 0) {
					endRand = (Math.random() - Math.random()) * .5;
				}
				
				_heigtValues.push( Math.min(_maxheight, Math.max(0, Math.sin(i/len*Math.PI + rand)*_maxheight) ) );
			}
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_label.width = 300;
			_slider.width = 300;
			_slider.y = _label.height;
			renderGraph();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function renderGraph(event:Event = null):void {
			graphics.clear();
			var i:int, len:int, py:int;
			py = _slider.y + _slider.height + 5;
			len = _heigtValues.length;
			graphics.lineStyle(0, 0, 1);
			graphics.beginFill(0xffffff, 1);
			graphics.moveTo(0, py + _maxheight);
			for(i = 0; i < len; ++i) {
				graphics.lineTo(300*i/len, py + _maxheight - _heigtValues[i] * (_slider.value/_slider.maxValue));
			}
			graphics.lineTo(300, py + _maxheight);
			graphics.lineTo(0, py + _maxheight);
		}
		
	}
}