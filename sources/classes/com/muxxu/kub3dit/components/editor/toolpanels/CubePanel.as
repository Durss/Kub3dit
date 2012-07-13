package com.muxxu.kub3dit.components.editor.toolpanels {
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
	 * @date 1 nov. 2011;
	 */
	public class CubePanel extends Sprite implements IToolPanel {
		private var _eraseMode:Boolean;
		private var _inputWidthLabel:CssTextField;
		private var _inputWidth:InputKube;
		private var _inputHeightLabel:CssTextField;
		private var _inputHeight:InputKube;
		private var _inputDepthLabel:CssTextField;
		private var _inputDepth:InputKube;
		private var _fillCb:CheckBoxKube;
		private var _inputThickLabel:CssTextField;
		private var _inputThick:InputKube;
		private var _landmark:Shape;
		private var _drawToLandmark:Boolean;
		private var _chunksManager:ChunksManager;
		private var _lastDrawGUID:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CubePanel</code>.
		 */
		public function CubePanel() {
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
			
			var i:int, len:int, w:int, h:int, d:int, t:int, px:Number, py:Number, pz:Number, c:uint, isBorder:Boolean;
			w = parseInt(_inputWidth.text);
			h = parseInt(_inputHeight.text);
			d = parseInt(_inputDepth.text);
			t = parseInt(_inputThick.text);
			len = w * h * d;
			if(_drawToLandmark) {
				_landmark.graphics.clear();
			}
			var fill:Boolean = _fillCb.selected;
			for(i = 0; i < len; ++i) {
				px = Math.ceil(ox - w * .5) + (i % w);
				py = Math.ceil(oz) + Math.floor(i/w)%h;
				pz = Math.ceil(oy - d * .5) + Math.floor(i/(w*h));
				
				if(_drawToLandmark) {
					isBorder = (i % w < t || i % w >= w - t || Math.floor(i / w) < t || Math.floor(i / w) >= d - t);
					if(i < w*d && (fill || (!fill && isBorder))) {
						px = i % w;
						py = Math.floor(i/w);
						c = (px+py)%2 == 0? 0xffffff : 0;
						_landmark.graphics.beginFill(c, .2);
						_landmark.graphics.drawRect(px, py, 1, 1);
					}
				}else{
					if(fill) {
						_chunksManager.update(px, pz, py, _eraseMode? 0 : kubeID);
					}else if(i%w < t || i%w >= w-t
							|| Math.floor(i/w)%h < t || Math.floor(i/w)%h >= h-t
							|| Math.floor(i/(w*h)) < t || Math.floor(i/(w*h)) >= d-t){
							
							_chunksManager.update(px, pz, py, _eraseMode? 0 : kubeID);
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
			
			_inputWidthLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputWidth = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			_inputHeightLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputHeight = addChild(new InputKube("", false, true, 1, 31)) as InputKube;
			_inputDepthLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputDepth = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			_fillCb = addChild(new CheckBoxKube(Label.getLabel("toolConfig-cubeShape-fill"))) as CheckBoxKube;
			_inputThickLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputThick = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			
			_inputWidth.text = "10";
			_inputHeight.text = "10";
			_inputDepth.text = "10";
			_inputThick.text = "1";
			
			_inputWidthLabel.text = Label.getLabel("toolConfig-cubeShape-inputWidth");
			_inputHeightLabel.text = Label.getLabel("toolConfig-cubeShape-inputHeight");
			_inputDepthLabel.text = Label.getLabel("toolConfig-cubeShape-inputDepth");
			_inputThickLabel.text = Label.getLabel("toolConfig-cubeShape-inputThick");
			
			_fillCb.addEventListener(Event.CHANGE, changeFillHandler);
			_fillCb.addEventListener(Event.CHANGE, updateLandMark);
			_inputWidth.addEventListener(Event.CHANGE, updateLandMark);
			_inputHeight.addEventListener(Event.CHANGE, updateLandMark);
			_inputDepth.addEventListener(Event.CHANGE, updateLandMark);
			_inputThick.addEventListener(Event.CHANGE, updateLandMark);
			
			computePositions();
			updateLandMark();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			var maxLabelW:Number = Math.round( Math.max(_inputWidthLabel.width, _inputHeightLabel.width, _inputDepthLabel.width) ) + 4;
			
			_inputWidth.x = maxLabelW;
			_inputHeight.x = maxLabelW;
			_inputDepth.x = maxLabelW;
			
			_inputWidthLabel.y = Math.round((_inputWidth.height - _inputWidthLabel.height) * .5);
			_inputHeightLabel.y = Math.round((_inputHeight.height - _inputHeightLabel.height) * .5);
			_inputDepthLabel.y = Math.round((_inputDepth.height - _inputDepthLabel.height) * .5);
			
			_inputHeight.y += Math.round(_inputWidth.height + 5);
			_inputHeightLabel.y += Math.round(_inputWidth.height + 5);
			
			_inputDepth.y += Math.round(_inputHeight.y + _inputHeight.height + 5);
			_inputDepthLabel.y += Math.round(_inputHeight.y + _inputHeight.height + 5);
			
			_fillCb.y = 3;
			_fillCb.x = Math.round(width + 20);
			
			_inputThickLabel.y = Math.round((_inputThick.height - _inputThickLabel.height) * .5);
			_inputThickLabel.x = _fillCb.x;
			_inputThick.x = Math.round(_inputThickLabel.x + _inputThickLabel.width + 4);
			_inputThick.y += Math.round(_fillCb.y + _fillCb.height + 5);
			_inputThickLabel.y += Math.round(_fillCb.height + 5);
			
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
		 * Called when fill checkbox state changes
		 */
		private function changeFillHandler(event:Event):void {
			_inputThick.enabled = !_fillCb.selected;
			_inputThickLabel.alpha = _fillCb.selected? .5 : 1;
		}
		
	}
}