package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.components.form.AxisSelector;
	import com.muxxu.kub3dit.components.form.CheckBoxKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
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
	public class RectanglePanel extends Sprite implements IToolPanel {
		private var _eraseMode:Boolean;
		private var _inputWidthLabel:CssTextField;
		private var _inputWidth:InputKube;
		private var _inputHeightLabel:CssTextField;
		private var _inputHeight:InputKube;
		private var _inputThicknessLabel:CssTextField;
		private var _inputThickness:InputKube;
		private var _landmark:Shape;
		private var _axisSelector:AxisSelector;
		private var _fillCb:CheckBoxKube;
		private var _drawToLandmark:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>RectanglePanel</code>.
		 */
		public function RectanglePanel() {
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
		public function get landmark():Shape {
			return _landmark;
		}



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
		public function draw(ox:int, oy:int, oz:int, kubeID:int, chunksManagerRef:ChunksManager, gridSize:int, gridOffset:Point):void {
			var i:int, len:int, w:int, h:int, t:int, px:Number, py:Number, pz:Number, c:uint;
			w = parseInt(_inputWidth.text);
			h = parseInt(_inputHeight.text);
			t = parseInt(_inputThickness.text);
			len = w*h;
			if(_drawToLandmark) {
				_landmark.graphics.clear();
			}
			var axis:String = _axisSelector.value;
			var fill:Boolean = _fillCb.selected;
			if(axis == "y" || !_drawToLandmark) {
				for(i = 0; i < len; ++i) {
					if(fill || i%w < t || i%w >= w-t || Math.floor(i/w) < t || Math.floor(i/w) >= h-t) {
						if(_drawToLandmark) {
							px = i % w;
							py = Math.floor(i/w);
							c = (px+py)%2 == 0? 0xffffff : 0;
							_landmark.graphics.beginFill(c, .2);
							_landmark.graphics.drawRect(px, py, 1, 1);
						}else{
							if(axis == "y") {
								px = Math.ceil(ox - w * .5) + (i % w);
								py = Math.ceil(oy - h * .5) + Math.floor(i/w);
								pz = oz;
							}else if(axis == "x") {
								px = ox;
								py = Math.ceil(oy - w * .5) + (i % w);
								pz = oz + Math.floor(i/w);
							}else if(axis == "z") {
								px = Math.ceil(ox - w * .5) + (i % w);
								py = oy;
								pz = oz + Math.floor(i/w);
							}
							chunksManagerRef.update(px, py, pz, _eraseMode? 0 : kubeID);
						}
					}
				}
			}else{
				len = w;
				var isZ:Boolean = axis == "z";
				for(i = 0; i < len; ++i) {
					if(_drawToLandmark) {
						c = i%2 == 0? 0xffffff : 0;
						_landmark.graphics.beginFill(c, .2);
						_landmark.graphics.drawRect(isZ? i : 0, isZ? 0 : i, 1, 1);
					}
				}
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_landmark = new Shape();
			
			_inputWidthLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputWidth = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			_inputHeightLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputHeight = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			_inputThicknessLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputThickness = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			_axisSelector = addChild(new AxisSelector(false)) as AxisSelector;
			_fillCb = addChild(new CheckBoxKube(Label.getLabel("toolConfig-diskShape-fill"))) as CheckBoxKube;
			
			_inputWidth.text = "10";
			_inputHeight.text = "10";
			_inputThickness.text = "2";
			
			_inputWidthLabel.text = Label.getLabel("toolConfig-rectShape-inputWidth");
			_inputHeightLabel.text = Label.getLabel("toolConfig-rectShape-inputHeight");
			_inputThicknessLabel.text = Label.getLabel("toolConfig-rectShape-inputThick");
			
			_inputWidth.addEventListener(Event.CHANGE, updateLandMark);
			_inputHeight.addEventListener(Event.CHANGE, updateLandMark);
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
			var maxLabelW:Number = Math.round( Math.max(_inputWidthLabel.width, _inputHeightLabel.width, _inputThicknessLabel.width) ) + 4;
			
			_inputWidth.x = maxLabelW;
			_inputHeight.x = maxLabelW;
			
			_inputWidthLabel.y = Math.round((_inputWidth.height - _inputWidthLabel.height) * .5);
			_inputHeightLabel.y = Math.round((_inputHeight.height - _inputHeightLabel.height) * .5);
			
			_inputHeight.y += Math.round(_inputWidth.height + 5);
			_inputHeightLabel.y += Math.round(_inputWidth.height + 5);
			
			_axisSelector.y = Math.round(_inputHeight.y + _inputHeight.height + 5);
			
			_fillCb.y = 3;
			_fillCb.x = Math.round(Math.max(_inputWidth.x + _inputWidth.width, _inputHeight.x + _inputWidth.height, _axisSelector.width)) + 10;
			_inputThicknessLabel.x = _fillCb.x;
			_inputThickness.y = Math.round(_fillCb.y + _fillCb.height + 5);
			_inputThickness.x = Math.round(_inputThicknessLabel.x + _inputThicknessLabel.width + 4);
			_inputThicknessLabel.y = Math.round( _inputThickness.y + (_inputThickness.height - _inputThicknessLabel.height) * .5 );
		}
		
		/**
		 * Updates the landmark
		 */
		private function updateLandMark(event:Event = null):void {
			_drawToLandmark = true;
			draw(0, 0, 0, 0, null, 0, null);
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