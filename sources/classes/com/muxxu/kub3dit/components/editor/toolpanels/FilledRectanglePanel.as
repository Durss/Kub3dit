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
	public class FilledRectanglePanel extends Sprite implements IToolPanel {
		private var _eraseMode:Boolean;
		private var _inputWidthLabel:CssTextField;
		private var _inputWidth:InputKube;
		private var _inputHeightLabel:CssTextField;
		private var _inputHeight:InputKube;
		private var _landmark:Shape;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FilledRectanglePanel</code>.
		 */
		public function FilledRectanglePanel() {
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
			
			_inputWidthLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputWidth = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			_inputHeightLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_inputHeight = addChild(new InputKube("", false, true, 1, 400)) as InputKube;
			
			_inputWidth.text = "10";
			_inputHeight.text = "10";
			
			_inputWidthLabel.text = Label.getLabel("toolConfig-rectShape-inputWidth");
			_inputHeightLabel.text = Label.getLabel("toolConfig-rectShape-inputHeight");
			
			_inputHeight.addEventListener(Event.CHANGE, updateLandMark);
			_inputWidth.addEventListener(Event.CHANGE, updateLandMark);
			
			computePositions();
			updateLandMark();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			var maxLabelW:Number = Math.round( Math.max(_inputWidthLabel.width, _inputHeightLabel.width) ) + 4;
			
			_inputWidth.x = maxLabelW;
			_inputHeight.x = maxLabelW;
			
			_inputWidthLabel.y = Math.round((_inputWidth.height - _inputWidthLabel.height) * .5);
			_inputHeightLabel.y = Math.round((_inputHeight.height - _inputHeightLabel.height) * .5);
			
			_inputHeight.y += Math.round(_inputWidth.height + 5);
			_inputHeightLabel.y += Math.round(_inputWidth.height + 5);
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
			var i:int, len:int, w:int, h:int, px:Number, py:Number, c:uint;
			w = parseInt(_inputWidth.text);
			h = parseInt(_inputHeight.text);
			len = w*h;
			if(toLandMark) {
				_landmark.graphics.clear();
			}
			for(i = 0; i < len; ++i) {
				if(toLandMark) {
					px =i % w;
					py = Math.floor(i/w);
					c = (px+py)%2 == 0? 0xffffff : 0;
					_landmark.graphics.beginFill(c, .2);
					_landmark.graphics.drawRect(px, py, 1, 1);
				}else{
					px = Math.ceil(ox - w * .5) + (i % w);
					py = Math.ceil(oy - h * .5) + Math.floor(i/w);
					chunksManagerRef.update(px, py, pz, _eraseMode? 0 : kubeID);
				}
			}
		}
		
	}
}