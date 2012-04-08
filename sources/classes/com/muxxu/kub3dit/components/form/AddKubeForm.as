package com.muxxu.kub3dit.components.form {
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import flash.geom.ColorTransform;
	import com.muxxu.kub3dit.components.LoaderSpinning;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.nurun.components.form.events.FormComponentEvent;
	import flash.display.Shape;
	import gs.TweenLite;
	import flash.display.DisplayObject;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 13 nov. 2011;
	 */
	public class AddKubeForm extends Sprite {
		
		private var _description:CssTextField;
		private var _input:InputKube;
		private var _submit:ButtonKube;
		private var _width:Number;
		private var _openBt:ButtonKube;
		private var _opened:Boolean;
		private var _mask:Shape;
		private var _spinning:LoaderSpinning;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>AddKubeForm</code>.
		 */
		public function AddKubeForm(openBt:ButtonKube) {
			_openBt = openBt;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the width of the component without simply scaling it.
		 */
		override public function set width(value:Number):void {
			_width = value;
			computePositions();
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function open():void {
			_opened = true;
			stage.focus = _input;
			_input.textfield.setSelection(0, _input.textfield.length);
			TweenLite.to(_mask, .25, {scaleY:1});
		}

		public function close():void {
			_opened = false;
			TweenLite.to(_mask, .25, {scaleY:0});
			
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_description = addChild(new CssTextField("addKubeDescription")) as CssTextField;
			_input = addChild(new InputKube("ID", false, true, 0, int.MAX_VALUE)) as InputKube;
			_submit = addChild(new ButtonKube(Label.getLabel("submitKube"))) as ButtonKube;
			_mask = addChild(new Shape()) as Shape;
			_spinning = addChild(new LoaderSpinning()) as LoaderSpinning;
			
			_description.text = Label.getLabel("addKubeDescription");
			
			_width = 0;
			mask = _mask;
			_mask.scaleY = 0;
			_input.width = 200;
			
			computePositions();
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_openBt.addEventListener(MouseEvent.CLICK, clickOpenHandler);
			_submit.addEventListener(MouseEvent.CLICK, submitHandler);
			_input.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			ViewLocator.getInstance().addEventListener(LightModelEvent.KUBE_ADD_COMPLETE, addResultHandler);
			ViewLocator.getInstance().addEventListener(LightModelEvent.KUBE_ADD_ERROR, addResultHandler);
		}
		
		/**
		 * Called when stage is available
		 */
		private function addedToStageHandler(event:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, releaseStageHandler);
		}
		
		/**
		 * Called when the mouse is released.
		 */
		private function releaseStageHandler(event:MouseEvent):void {
			if(!contains(event.target as DisplayObject)) close();
		}
		
		/**
		 * Called when opening button is clicked
		 */
		private function clickOpenHandler(event:MouseEvent):void {
			if(_opened) {
				close();
			}else{
				open();
			}
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_description.width = _width;
			_input.y = _submit.y = Math.round(_description.height);
			_submit.x = Math.round(_input.width);
			
			graphics.clear();
			graphics.beginFill(0x2E8FB8, 1);
			graphics.drawRect(0, 0, _width, Math.round(_submit.y + _submit.height + 5));
			graphics.endFill();
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000, 1);
			_mask.graphics.drawRect(0, 0, _width, Math.round(_submit.y + _submit.height + 5));
			_mask.graphics.endFill();
			
			_spinning.x = (_submit.x + _submit.width) * .5;
			_spinning.y = _submit.y + _submit.height * .5;
		}
		
		/**
		 * Called when form is submitted
		 */
		private function submitHandler(event:Event):void {
			if(Textures.getInstance().customKubes.length < Textures.MAX_CUSTOM_KUBES) {
				_input.enabled = false;
				_submit.enabled = false;
				_spinning.open();
			}
			
			FrontControler.getInstance().addKube(_input.text);
		}
		
		/**
		 * Called when kube add completes or fails
		 */
		private function addResultHandler(event:LightModelEvent):void {
			_spinning.close();
			
			if(event.type == LightModelEvent.KUBE_ADD_ERROR) {
				_input.text = Label.getLabel("invalidKubeId");
				_input.transform.colorTransform = new ColorTransform();
				TweenLite.from(_input, 1, {tint:0xff0000});
			}
			_input.enabled = true;
			_submit.enabled = true;
			_input.textfield.setSelection(0, _input.textfield.length);
		}
		
	}
}