package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.editor.toolpanels.terragen.GenerateTerrainStep;
	import com.muxxu.kub3dit.components.editor.toolpanels.terragen.GroundRatioStep;
	import com.muxxu.kub3dit.components.editor.toolpanels.terragen.PerlinNoiseMapStep;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.roundPos;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Francois
	 * @date 1 juil. 2012;
	 */
	public class TerragenPanel extends Sprite implements IToolPanel {
		private var _step1:PerlinNoiseMapStep;
		private var _step2:GroundRatioStep;
		private var _nextBt:ButtonKube;
		private var _prevBt:ButtonKube;
		private var _currentStep:int;
		private var _steps:Array;
		private var _step3:GenerateTerrainStep;
		private var _landMark:Shape;
		private var _chunksManager:ChunksManager;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TerragenPanel</code>.
		 */
		public function TerragenPanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		/**
		 * @inheritDoc
		 */
		public function set eraseMode(value:Boolean):void {
		}

		/**
		 * @inheritDoc
		 */
		public function get eraseMode():Boolean {
			return false;
		}

		/**
		 * @inheritDoc
		 */
		public function set level(value:int):void {
		}

		/**
		 * @inheritDoc
		 */
		public function get fixedLandmark():Boolean {
			return false;
		}

		/**
		 * @inheritDoc
		 */
		public function set chunksManager(value:ChunksManager):void {
			_chunksManager = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get landmark():Shape {
			return _landMark;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void {
		}

		/**
		 * @inheritDoc
		 */
		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
			if(_currentStep == _steps.length-1) {
				_step3.generate(ox, oy, oz, kubeID, gridOffset, _chunksManager);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function onNewMapLoaded():void {
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_landMark = new Shape();
			var contrast:ColorMatrixFilter = setContrast(70);
			
			_step1 = addChild(new PerlinNoiseMapStep(contrast)) as PerlinNoiseMapStep;
			_step2 = new GroundRatioStep();
			_step3 = new GenerateTerrainStep(_step1, _step2, _landMark, contrast);
			_nextBt = addChild(new ButtonKube(Label.getLabel("toolConfig-terragen-nextStep"))) as ButtonKube;
			_prevBt = addChild(new ButtonKube(Label.getLabel("toolConfig-terragen-prevStep"))) as ButtonKube;
			
			_step1.addEventListener(Event.RESIZE, computePositions);
			_step2.addEventListener(Event.RESIZE, computePositions);
			_step3.addEventListener(Event.RESIZE, computePositions);
			
			_steps = [];
			_steps.push(_step1);
			_steps.push(_step2);
			_steps.push(_step3);
			
			_prevBt.enabled = false;
			
			computePositions();
			_nextBt.addEventListener(MouseEvent.CLICK, nextPrevHandler);
			_prevBt.addEventListener(MouseEvent.CLICK, nextPrevHandler);
		}
		
		/**
		 * sets contrast value available are -100 ~ 100 @default is 0
		 * @param 		value:int	contrast value
		 * @return		ColorMatrixFilter
		 */
		public static function setContrast(value:Number):ColorMatrixFilter {
			value /= 100;
			var s: Number = value + 1;
    		var o : Number = 128 * (1 - s);

			var m:Array = new Array();
			m = m.concat([s, 0, 0, 0, o]);	// red
			m = m.concat([0, s, 0, 0, o]);	// green
			m = m.concat([0, 0, s, 0, o]);	// blue
			m = m.concat([0, 0, 0, 1, 0]);	// alpha

			return new ColorMatrixFilter(m);
		}
		
		/**
		 * Called when prev/next button is clicked
		 */
		private function nextPrevHandler(event:MouseEvent):void {
			_currentStep += (event.currentTarget == _nextBt)? 1 : -1;
			_prevBt.enabled = _currentStep > 0;
			_nextBt.enabled = _currentStep < _steps.length-1;
			
			var i:int, len:int;
			len = _steps.length;
			for(i = 0; i < len; ++i) {
				if(i != _currentStep) {
					if(contains(_steps[i])) {
						removeChild(_steps[i]);
					}
				}else{
					addChild(_steps[i]);
				}
			}
			computePositions();
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/**
		 * Resizes and replaces the elements
		 */
		private function computePositions(event:Event = null):void {
			var currentStepTarget:Sprite = _steps[_currentStep];
			_prevBt.y = _nextBt.y = currentStepTarget.height + 10;
			_nextBt.x = currentStepTarget.width - _nextBt.width;
			
			roundPos(_nextBt, _prevBt);
		}
		
	}
}