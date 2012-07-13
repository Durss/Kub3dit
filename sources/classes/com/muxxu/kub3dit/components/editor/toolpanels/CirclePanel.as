package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.components.form.AxisSelector;
	import com.muxxu.kub3dit.components.form.CheckBoxKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class CirclePanel extends Sprite implements IToolPanel {
		
		private var _eraseMode:Boolean;
		private var _inputRadiusLabel:CssTextField;
		private var _inputRadius:InputKube;
		private var _inputThicknessLabel:CssTextField;
		private var _inputThickness:InputKube;
		private var _landmark:Shape;
		private var _fillCb:CheckBoxKube;
		private var _axisSelector:AxisSelector;
		private var _drawToLandmark:Boolean;
		private var _chunksManager:ChunksManager;
		private var _lastDrawGUID:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CirclePanel</code>.
		 */
		public function CirclePanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function set eraseMode(value:Boolean):void {
			_eraseMode = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get eraseMode():Boolean {
			return _eraseMode;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get landmark():Shape {
			return _landmark;
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
		public function get fixedLandmark():Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set level(value:int):void { }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
		}
		
		/**
		 * Method that will be used to draw with the tool
		 */
		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
			var drawGUID:String = ox + "" + oy + "" + oz + "" + kubeID + "" + eraseMode;
			if(!_drawToLandmark && drawGUID == _lastDrawGUID) return;
			_lastDrawGUID = drawGUID;
			
			var i:int, len:int, radius:int, diameter:int, radiusMin:int, px:int, py:int, pz:int, d:Number, c:uint;
			radius = parseInt(_inputRadius.text);
			diameter = radius * 2;
			radiusMin = _fillCb.selected? 0 : radius - parseInt(_inputThickness.text);
			
			if(_drawToLandmark) {
				_landmark.graphics.clear();
			}
			var axis:String = _axisSelector.value;
			if(axis == "y" || !_drawToLandmark) {
				len = diameter*diameter;
				for(i = 0; i < len; ++i) {
					if(axis == "y") {
						px = (ox - radius) + (i % diameter)+1;
						py = (oy - radius) + Math.floor(i/diameter)+1;
						pz = oz;
						d = Math.round(Math.sqrt( Math.pow(px - ox, 2) + Math.pow(py - oy, 2) ));
						
					}else if(axis == "x") {
						px = ox;
						py = (oy - radius) + (i % diameter);
						pz = oz + Math.floor(i/diameter);
						d = Math.round(Math.sqrt( Math.pow(py - oy, 2) + Math.pow(pz - (oz + radius-1), 2) ));
						
					}else if(axis == "z") {
						px = (ox - radius) + (i % diameter);
						py = oy;
						pz = oz + Math.floor(i/diameter);
						d = Math.round(Math.sqrt( Math.pow(px - ox, 2) + Math.pow(pz - (oz + radius-1), 2) ));
					}
					
					if(d < radius && d >=radiusMin) {
						if(_drawToLandmark) {
							px = i % diameter;
							py = i/diameter;
							c = (px+py)%2 == 0? 0xffffff : 0;
							_landmark.graphics.beginFill(c, .2);
							_landmark.graphics.drawRect(px, py, 1, 1);
						}else{
							_chunksManager.update(px, py, pz, _eraseMode? 0 : kubeID);
						}
					}
				}
			
			//Faster landmark generation for X and Z axis
			}else{
				len = diameter;
				var isZ:Boolean = axis == "z";
				for(i = 0; i < len-1; ++i) {
					if(_drawToLandmark) {
						c = i%2 == 0? 0xffffff : 0;
						_landmark.graphics.beginFill(c, .2);
						_landmark.graphics.drawRect(isZ? i : 0, isZ? 0 : i, 1, 1);
					}
				}
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
			_landmark = new Shape();
			
			_inputRadiusLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputRadius = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			_inputThicknessLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputThickness = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			_fillCb = addChild(new CheckBoxKube(Label.getLabel("toolConfig-diskShape-fill"))) as CheckBoxKube;
			_axisSelector = addChild(new AxisSelector(false)) as AxisSelector;
			
			_inputRadius.text = "10";
			_inputThickness.text = "2";
			
			_inputRadiusLabel.text = Label.getLabel("toolConfig-circleShape-inputRadius");
			_inputThicknessLabel.text = Label.getLabel("toolConfig-circleShape-inputThick");
			
			_inputRadius.addEventListener(Event.CHANGE, updateLandMark);
			_inputThickness.addEventListener(Event.CHANGE, updateLandMark);
			_axisSelector.addEventListener(Event.CHANGE, updateLandMark);
			_fillCb.addEventListener(Event.CHANGE, updateLandMark);
			_fillCb.addEventListener(Event.CHANGE, changeFillHandler);
			
			computePositions();
			updateLandMark();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			
			_inputRadius.x = Math.round(_inputRadiusLabel.width + 4);
			_inputRadiusLabel.y = Math.round( (_inputRadius.height - _inputRadiusLabel.height) * .5 );
			
			_axisSelector.y = Math.round(_inputRadius.height + 5);
			
			_fillCb.y = 3;
			_fillCb.x = Math.round(Math.max(_inputRadius.x + _inputRadius.width, _axisSelector.width)) + 10;
			_inputThicknessLabel.x = _fillCb.x;
			_inputThickness.y = Math.round(_fillCb.y + _fillCb.height + 5);
			_inputThickness.x = Math.round(_inputThicknessLabel.x + _inputThicknessLabel.width + 4);
			_inputThicknessLabel.y = Math.round( _inputThickness.y + (_inputThickness.height - _inputThicknessLabel.height) * .5 );
			
			var i:int, len:int = numChildren;
			for(i = 0; i < len; ++i) {
				if(getChildAt(i) is Validable) Validable(getChildAt(i)).validate();
			}
		}
		
		/**
		 * Updates the landmark
		 */
		private function updateLandMark(event:Event = null):void {
			_drawToLandmark = true;
			draw(0, 0, 0, 0, 0, null);
			_drawToLandmark = false;
		}
		
		/**
		 * Called when fill is changed
		 */
		private function changeFillHandler(event:Event):void {
			_inputThickness.enabled = !_fillCb.selected;
			_inputThicknessLabel.alpha = _fillCb.selected? .4 : 1;
		}
		
	}
}