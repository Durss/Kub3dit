package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.components.form.CheckBoxKube;
	import com.muxxu.kub3dit.components.form.RadioButtonKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.nurun.components.form.FormComponentGroup;
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
	public class PencilPanel extends Sprite implements IToolPanel {
		
		private var _inputSize:InputKube;
		private var _group:FormComponentGroup;
		private var _squareRB:RadioButtonKube;
		private var _circleRB:RadioButtonKube;
		private var _inputLabel:CssTextField;
		private var _eraseMode:Boolean;
		private var _landmark:Shape;
		private var _drawToLandmark:Boolean;
		private var _chunksManager:ChunksManager;
		private var _lastDrawGUID:String;
		private var _dropMode:CheckBoxKube;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PencilPanel</code>.
		 */
		public function PencilPanel() {
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
		public function draw(ox:int, oy:int, pz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
			var drawGUID:String = ox + "" + oy + "" + pz + "" + kubeID + "" + eraseMode;
			if(drawGUID == _lastDrawGUID && !_drawToLandmark) return;
			_lastDrawGUID = drawGUID;
			
			var i:int, len:int, size:int, px:int, py:int, d:Number, c:uint;
			size = parseInt(_inputSize.text);
			if(_drawToLandmark) {
				_landmark.graphics.clear();
			}
			var dropMode:Boolean = _dropMode.selected;
			if(_squareRB.selected) {
				len = size*size;
				for(i = 0; i < len; ++i) {
					if(_drawToLandmark) {
						px = i % size;
						py = Math.floor(i/size);
						c = (px+py)%2 == 0? 0xffffff : 0;
						_landmark.graphics.beginFill(c, .2);
						_landmark.graphics.drawRect(px, py, 1, 1);
					}else{
						px = Math.ceil(ox - size * .5) + (i % size);
						py = Math.ceil(oy - size * .5) + Math.floor(i/size);
						if(dropMode) {
							_chunksManager.drop(px, py, _eraseMode? 0 : kubeID);
						}else{
							_chunksManager.update(px, py, pz, _eraseMode? 0 : kubeID);
						}
					}
				}
			}else{
				//rounds the size to an odd number to be sure to get something that really looks like a circle
				if(size%2 == 0) size ++;
				len = size*size;
				for(i = 0; i < len; ++i) {
					px = Math.ceil(ox - size * .5) + (i % size);
					py = Math.ceil(oy - size * .5) + Math.floor(i/size);
					d = Math.sqrt( Math.pow(px - ox, 2) + Math.pow(py - oy, 2) );
					if(d <= size * .5) {
						if(_drawToLandmark) {
							px = i % size;
							py = i/size;
							c = (px+py)%2 == 0? 0xffffff : 0;
							_landmark.graphics.beginFill(c, .2);
							_landmark.graphics.drawRect(px, py, 1, 1);
						}else{
							if(dropMode) {
								_chunksManager.drop(px, py, _eraseMode? 0 : kubeID);
							}else{
								_chunksManager.update(px, py, pz, _eraseMode? 0 : kubeID);
							}
						}
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
			
			_group = new FormComponentGroup();
			_inputLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputSize = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			_squareRB = addChild(new RadioButtonKube(Label.getLabel("toolConfig-pencilShape-square"), _group)) as RadioButtonKube;
			_circleRB = addChild(new RadioButtonKube(Label.getLabel("toolConfig-pencilShape-circle"), _group)) as RadioButtonKube;
			_dropMode = addChild(new CheckBoxKube(Label.getLabel("toolConfig-pencilShape-dropper"))) as CheckBoxKube;
			
			_inputSize.text = "1";
			
			_inputLabel.text = Label.getLabel("toolConfig-pencilShape-input");
			
			_inputSize.addEventListener(Event.CHANGE, updateLandMark);
			_squareRB.addEventListener(Event.CHANGE, updateLandMark);
			_circleRB.addEventListener(Event.CHANGE, updateLandMark);
			
			computePositions();
			updateLandMark();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_inputSize.x = Math.round(_inputLabel.width + 2);
			_inputLabel.y = Math.round((_inputSize.height - _inputLabel.height) * .5);
			_squareRB.x = _circleRB.x = Math.round(_inputSize.x + _inputSize.width + 15);
			_circleRB.y = Math.round(_squareRB.height + 5);
			_dropMode.y = _circleRB.y + _circleRB.height;
			
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
	}
}