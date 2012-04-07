package com.muxxu.build3r.views {

	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.build3r.controler.FrontControlerBuild3r;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.utils.input.keyboard.events.KeyboardSequenceEvent;
	import com.nurun.utils.input.keyboard.KeyboardSequenceDetector;
	import flash.events.Event;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.build3r.model.ModelBuild3r;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;

	/**
	 * 
	 * @author Francois
	 * @date 7 avr. 2012;
	 */
	public class DebugView extends AbstractView {
		private var _input:InputKube;
		private var _ks:KeyboardSequenceDetector;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>DebugView</code>.
		 */
		public function DebugView() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:ModelBuild3r = event.model as ModelBuild3r;
			if(_input != null && model.position != null) {
				_input.text = model.position.x+","+model.position.y+","+model.position.z;
			}
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			visible = false;
			
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_input = addChild(new InputKube("x,y,z", false, false, 0, 0, true)) as InputKube;
			_input.validate();
			
			graphics.beginFill(0x44526f, 1);
			graphics.drawRect(0, 0, _input.width, _input.height);
			graphics.endFill();
			
			_ks = new KeyboardSequenceDetector(stage);
			_ks.addEventListener(KeyboardSequenceEvent.SEQUENCE, sequenceHandler);
			_ks.addSequence("debug", KeyboardSequenceDetector.DEBUG_CODE);
			
			_input.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
		}

		private function submitHandler(event:FormComponentEvent):void {
			var chunks:Array = _input.text.split(",");
			var pos:Point3D = new Point3D();
			pos.x = parseInt(chunks[0]);
			pos.y = parseInt(chunks[1]);
			pos.z = parseInt(chunks[2]);
			FrontControlerBuild3r.getInstance().touchForum(pos);
		}

		private function sequenceHandler(event:KeyboardSequenceEvent):void {
			visible = !visible;
		}
		
	}
}