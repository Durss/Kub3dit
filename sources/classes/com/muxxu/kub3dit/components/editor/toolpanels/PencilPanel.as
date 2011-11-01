package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.components.form.RadioButtonKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
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
		public function get drawer():Function {
			return drawingMethod;
		}
		
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
		}
		
		/**
		 * Updates the landmark
		 */
		private function updateLandMark(event:Event = null):void {
			drawingMethod(0, 0, 0, 0, null, true);
		}
		
		/**
		 * Method that will be used to draw with the tool
		 */
		private function drawingMethod(ox:int, oy:int, pz:int, kubeID:int, chunksManagerRef:ChunksManager, toLandMark:Boolean = false):void {
			var i:int, len:int, size:int, px:int, py:int, d:Number, c:uint;
			size = parseInt(_inputSize.text);
			if(toLandMark) {
				_landmark.graphics.clear();
			}
			if(_squareRB.selected) {
				len = size*size;
				for(i = 0; i < len; ++i) {
					if(toLandMark) {
						px = i % size;
						py = Math.floor(i/size);
						c = (px+py)%2 == 0? 0xffffff : 0;
						_landmark.graphics.beginFill(c, .2);
						_landmark.graphics.drawRect(px + 1, py + 1, 1, 1);
					}else{
						px = Math.ceil(ox - size * .5) + (i % size);
						py = Math.ceil(oy - size * .5) + Math.floor(i/size);
						chunksManagerRef.update(px, py, pz, _eraseMode? 0 : kubeID);
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
						if(toLandMark) {
							px = i % size;
							py = Math.floor(i/size);
							c = (px+py)%2 == 0? 0xffffff : 0;
							_landmark.graphics.beginFill(c, .2);
							_landmark.graphics.drawRect(px + 1, py + 1, 1, 1);
						}else{
							chunksManagerRef.update(px, py, pz, _eraseMode? 0 : kubeID);
						}
					}
				}
			}
		}
	}
}