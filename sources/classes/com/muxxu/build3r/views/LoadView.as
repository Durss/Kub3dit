package com.muxxu.build3r.views {
	import gs.TweenLite;

	import com.muxxu.build3r.controler.FrontControlerBuild3r;
	import com.muxxu.build3r.model.ModelBuild3r;
	import com.muxxu.kub3dit.commands.IPassView;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	/**
	 * 
	 * @author Francois
	 * @date 19 févr. 2012;
	 */
	public class LoadView extends AbstractView implements IPassView {
		
		private var _browseBt:ButtonKube;
		private var _idInput:InputKube;
		private var _idBt:ButtonKube;
		private var _label:CssTextField;
		private var _passInput:InputKube;
		private var _emptyCt:ColorTransform;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LoadView</code>.
		 */
		public function LoadView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:ModelBuild3r = event.model as ModelBuild3r;
			visible = model.currentMap == null;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function open(passwordCallback:Function):void {
			mouseEnabled = mouseChildren = true;
			visible = true;
			stage.focus = _passInput;
			_passInput.transform.colorTransform = _emptyCt;
			TweenLite.from(_passInput, .5, {tint:0xff0000});
		}

		/**
		 * @inheritDoc
		 */
		public function error():void {
			mouseEnabled = mouseChildren = true;
			stage.focus = _passInput;
			_passInput.transform.colorTransform = _emptyCt;
			TweenLite.from(_passInput, .5, {tint:0xff0000});
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
			visible = false;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_label = addChild(new CssTextField("promptWindowContent")) as CssTextField;
			_browseBt = addChild(new ButtonKube("Parcourir...")) as ButtonKube;
			
			_idInput = addChild(new InputKube("id...")) as InputKube;
			_passInput = addChild(new InputKube("pass...")) as InputKube;
			_idBt = addChild(new ButtonKube("Charger")) as ButtonKube;
			
			_emptyCt = new ColorTransform();
			
			_label.text = "Charger une carte depuis votre ordinateur ou depuis son ID kub3dit :";
			_idInput.textfield.restrict = '[0-9][a-z][A-Z]';
			_idInput.textfield.maxChars = 15;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_browseBt.addEventListener(MouseEvent.CLICK, submitHandler);
			_idBt.addEventListener(MouseEvent.CLICK, submitHandler);
			_idInput.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_passInput.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			_label.width = _idInput.width = _browseBt.width = _passInput.width = _idBt.width = stage.stageWidth;
			
			PosUtils.vPlaceNext(20, _label, _browseBt);
			PosUtils.vPlaceNext(20, _browseBt, _idInput);
			PosUtils.vPlaceNext(5, _idInput, _passInput, _idBt);
		}
		
		/**
		 * Called when the form is submitted
		 */
		private function submitHandler(event:Event):void {
			if(!mouseEnabled) return;
			
			if(event.target == _browseBt) {
				FrontControlerBuild3r.getInstance().browseForMap();
			}else{
				if(String(_idInput.value).length == 0) {
					stage.focus = _idInput;
					_idInput.transform.colorTransform = _emptyCt;
					TweenLite.from(_idInput, .5, {tint:0xff0000});
				}else{
					mouseEnabled = mouseChildren = false;
					FrontControlerBuild3r.getInstance().loadMapById(_idInput.value as String, _passInput.value as String);
				}
			}
		}
		
	}
}