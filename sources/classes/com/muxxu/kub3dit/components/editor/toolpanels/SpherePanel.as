package com.muxxu.kub3dit.components.editor.toolpanels {
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
	 * @date 1 nov. 2011;
	 */
	public class SpherePanel extends Sprite implements IToolPanel {
		
		private var _eraseMode:Boolean;
		private var _inputRadiusLabel:CssTextField;
		private var _inputRadius:InputKube;
		private var _landmark:Shape;
		private var _fillCb:CheckBoxKube;
		private var _inputThickLabel:CssTextField;
		private var _inputThick:InputKube;
		private var _drawToLandmark:Boolean;
		private var _chunksManager:ChunksManager;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SpharePanel</code>.
		 */
		public function SpherePanel() {
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
			var i:int, len:int, r:int, t:int, diameter:int, d:Number, px:Number, py:Number, pz:Number, c:uint;
			r = parseInt(_inputRadius.text);
			t = parseInt(_inputThick.text);
			diameter = r*2;
			len = diameter*diameter*diameter;
			if(_drawToLandmark) {
				_landmark.graphics.clear();
			}
			var fill:Boolean = _fillCb.selected;
			
			for(i = 0; i < len; ++i) {
				px = Math.floor(ox - r) + (i % diameter);
				py = Math.floor(oy - r) + Math.floor(i/diameter)%diameter;
				pz = Math.floor(oz - r) + Math.floor(i/(diameter*diameter));
				
				if(_drawToLandmark) {
					if(i < diameter*diameter) {
						px = i% diameter;
						py = Math.floor(i/diameter);
						
						d = Math.round(Math.sqrt((r - px)*(r - px) + (r - py)*(r - py)));
						if(d < r && ( fill || (!fill && d>=r-t) )) {
							c = (px+py)%2 == 0? 0xffffff : 0;
							_landmark.graphics.beginFill(c, .2);
							_landmark.graphics.drawRect(px-1, py-1, 1, 1);
						}
					}else{
						break;
					}
				}else {
					d = Math.round(Math.sqrt((ox - px)*(ox - px) + (oy - py)*(oy - py) + (oz - pz)*(oz - pz)));
					if(d < r && ( fill || (!fill && d>=r-t) )) {
						_chunksManager.update(px, py, pz, _eraseMode? 0 : kubeID);
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
			
			_inputRadiusLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputRadius = addChild(new InputKube("", false, true, 1, 50)) as InputKube;
			
			_fillCb = addChild(new CheckBoxKube(Label.getLabel("toolConfig-sphereShape-fill"))) as CheckBoxKube;
			_inputThickLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputThick = addChild(new InputKube("", false, true, 1, 50)) as InputKube;
			
			_inputRadius.text = "5";
			_inputThick.text = "1";
			
			_inputRadiusLabel.text = Label.getLabel("toolConfig-sphereShape-inputRadius");
			_inputThickLabel.text = Label.getLabel("toolConfig-sphereShape-inputThick");
			
			_fillCb.addEventListener(Event.CHANGE, changeFillHandler);
			_fillCb.addEventListener(Event.CHANGE, updateLandMark);
			_inputRadius.addEventListener(Event.CHANGE, updateLandMark);
			_inputThick.addEventListener(Event.CHANGE, updateLandMark);
			
			computePositions();
			updateLandMark();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_inputRadius.x = Math.round(_inputRadiusLabel.width + 4);
			_inputRadiusLabel.y = Math.round( (_inputRadius.height - _inputRadiusLabel.height) * .5 );
			
			_fillCb.y = 3;
			_fillCb.x = Math.round(_inputRadius.x + _inputRadius.width + 10);
			_inputThickLabel.x = _fillCb.x;
			_inputThick.y = Math.round(_fillCb.y + _fillCb.height + 5);
			_inputThick.x = Math.round(_inputThickLabel.x + _inputThickLabel.width + 4);
			_inputThickLabel.y = Math.round( _inputThick.y + (_inputThick.height - _inputThickLabel.height) * .5 );
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