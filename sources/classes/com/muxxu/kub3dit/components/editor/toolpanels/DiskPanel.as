package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
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
	public class DiskPanel extends Sprite implements IToolPanel {
		
		private var _inputLabel:CssTextField;
		private var _inputRadius:InputKube;
		private var _eraseMode:Boolean;
		private var _landmark:Shape;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>DiskPanel</code>.
		 */
		public function DiskPanel() {
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
			
			_inputLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputRadius = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			
			_inputRadius.text = "10";
			
			_inputLabel.text = Label.getLabel("toolConfig-diskShape-inputRadius");
			
			_inputRadius.addEventListener(Event.CHANGE, updateLandMark);
			
			computePositions();
			updateLandMark();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_inputRadius.x = Math.round(_inputLabel.width + 2);
			_inputRadius.validate();
			_inputLabel.y = Math.round((_inputRadius.height - _inputLabel.height) * .5);
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
			var i:int, len:int, radius:int, px:int, py:int, d:Number, c:uint;
			radius = parseInt(_inputRadius.text);
			len = radius*radius*4;
			if(toLandMark) {
				_landmark.graphics.clear();
			}
			for(i = 0; i < len; ++i) {
				px = (ox - radius) + (i % (radius*2));
				py = (oy - radius) + Math.floor(i/(radius*2));
				d = Math.round(Math.sqrt( Math.pow(px - ox, 2) + Math.pow(py - oy, 2) ));
				if(d < radius) {
					if(toLandMark) {
						px = i % (radius*2);
						py = Math.floor(i/(radius*2));
						c = (px+py)%2 == 0? 0xffffff : 0;
						_landmark.graphics.beginFill(c, .2);
						_landmark.graphics.drawRect(px, py, 1, 1);
					}else{
						chunksManagerRef.update(px, py, pz, _eraseMode? 0 : kubeID);
					}
				}
			}
		}
		
	}
}