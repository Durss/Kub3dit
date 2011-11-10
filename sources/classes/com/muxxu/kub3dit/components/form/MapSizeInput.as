package com.muxxu.kub3dit.components.form {
	import flash.events.Event;
	import com.muxxu.kub3dit.graphics.MapSizeCross;
	import com.muxxu.kub3dit.vo.ToolTipAlign;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import flash.events.MouseEvent;
	import com.nurun.components.text.CssTextField;
	import com.muxxu.kub3dit.components.buttons.ButtonSplashScreen;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	
	
	[Event(name="cancel", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * 
	 * @author Francois
	 * @date 10 nov. 2011;
	 */
	public class MapSizeInput extends Sprite {
		
		private var _inputW:InputKube;
		private var _inputH:InputKube;
		private var _submitBt:ButtonSplashScreen;
		private var _cancelBt:ButtonSplashScreen;
		private var _inputsHolder:Sprite;
		private var _label:CssTextField;
		private var _cross:MapSizeCross;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MapSizeInput</code>.
		 */
		public function MapSizeInput() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the width of the map
		 */
		public function get sizeX():int { return parseInt(_inputW.text); }
		
		/**
		 * Gets the height of the map
		 */
		public function get sizeY():int { return parseInt(_inputH.text); }



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
			_inputsHolder = addChild(new Sprite()) as Sprite;
			_inputW = _inputsHolder.addChild(new InputKube("x",true, true, 1, 50)) as InputKube;
			_inputH = _inputsHolder.addChild(new InputKube("x",true, true, 1, 50)) as InputKube;
			_label = _inputsHolder.addChild(new CssTextField("splashScreenInputLabel")) as CssTextField;
			_cross = _inputsHolder.addChild(new MapSizeCross()) as MapSizeCross;
			_submitBt = addChild(new ButtonSplashScreen(Label.getLabel("submitMapSize"))) as ButtonSplashScreen;
			_cancelBt = addChild(new ButtonSplashScreen(Label.getLabel("cancelMapSize"))) as ButtonSplashScreen;
			
			_cancelBt.width = _submitBt.width = Math.max(_cancelBt.width, _submitBt.width) + 10;
			
			_inputW.text = "4";
			_inputH.text = "4";
			_label.text = Label.getLabel("inputMapSize");
			
			_inputW.validate();
			_inputH.validate();
			_submitBt.validate();
			
			_inputW.addEventListener(MouseEvent.ROLL_OVER, rollOverInputHanlder);
			_inputH.addEventListener(MouseEvent.ROLL_OVER, rollOverInputHanlder);
			_submitBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_cancelBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_inputW.x = Math.round(_label.width + 10);
			_inputH.x = Math.round(_inputW.x + _inputW.width + _cross.width + 10);
			_cross.x = Math.round(_inputH.x - _cross.width - 5);
			_cross.y = Math.round((_inputW.height - _cross.height) * .5);
			_submitBt.y = _inputsHolder.y + _inputsHolder.height + 5;
			_cancelBt.y = _submitBt.y + _submitBt.height - 20;
			
			PosUtils.hAlign(PosUtils.H_ALIGN_CENTER, 0, _inputsHolder, _submitBt, _cancelBt);
		}
		
		
		
		
		//__________________________________________________________ MOUSE EVENTS
		
		/**
		 * Called when an input is rolled over
		 */
		private function rollOverInputHanlder(event:MouseEvent):void {
			dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("titleMapSize"), ToolTipAlign.TOP, 20, "tooltipContentBig"));
		}
		
		/**
		 * Called when a button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			var type:String = event.currentTarget == _submitBt? Event.COMPLETE : Event.CANCEL;
			dispatchEvent(new Event(type));
		}
		
	}
}