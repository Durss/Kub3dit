package com.muxxu.kub3dit.views {
	import flash.events.KeyboardEvent;
	import gs.TweenLite;

	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;

	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Francois
	 * @date 11 déc. 2011;
	 */
	public class LockView extends AbstractView {
		private var _enabled:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LockView</code>.
		 */
		public function LockView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			model.addEventListener(LightModelEvent.LOCK, lockHandler);
			model.addEventListener(LightModelEvent.UNLOCK, unlockHandler);
			ViewLocator.getInstance().removeView(this);
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		/**
		 * Enables the view
		 */
		public function enable():void {
			if(_enabled) return;
			_enabled = true;
			computePositions();
			TweenLite.to(this, .25, {autoAlpha:1, overwrite:1});
			enterFrameHandler();
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, lockEvent, true, 9999);
			stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, lockEvent, true, 9999);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, lockEvent, true, 9999);
			stage.addEventListener(MouseEvent.CLICK, lockEvent, true, 9999);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, lockEvent, true, 9999);
			stage.addEventListener(MouseEvent.MOUSE_UP, lockEvent, true, 9999);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, lockEvent, true, 9999);
			stage.addEventListener(KeyboardEvent.KEY_UP, lockEvent, true, 9999);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, lockEvent, true, 9999);
		}

		/**
		 * Disables the view
		 */
		public function disable():void {
			if(!_enabled) return;
			_enabled = false;
			computePositions();
			TweenLite.to(this, .25, {autoAlpha:0, overwrite:1, delay:.25});
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, lockEvent, true);
			stage.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, lockEvent, true);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, lockEvent, true);
			stage.removeEventListener(MouseEvent.CLICK, lockEvent, true);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, lockEvent, true);
			stage.removeEventListener(MouseEvent.MOUSE_UP, lockEvent, true);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, lockEvent, true);
			stage.removeEventListener(KeyboardEvent.KEY_UP, lockEvent, true);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, lockEvent, true);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			visible = false;
			alpha = 0;
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Locks the UI
		 */
		private function lockHandler(event:LightModelEvent):void {
			enable();
		}
		
		/**
		 * Unlocks the UI
		 */
		private function unlockHandler(event:LightModelEvent):void {
			disable();
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
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			graphics.clear();
			if(_enabled && stage != null) {
				graphics.beginFill(0xffffff, .5);
				graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
				graphics.endFill();
			}
		}
		
		/**
		 * Called when an action occurs to lock it.
		 */
		private function lockEvent(event:Event):void {
			if(event is MouseEvent && !MouseEvent(event).ctrlKey) {
				event.stopPropagation();
				event.preventDefault();
			}
		}
		
		/**
		 * Called when the mouse moves.
		 */
		private function enterFrameHandler(event:Event = null):void {
			if(!_enabled) return;
			if(event != null){
				lockEvent(event);
			}
		}
		
	}
}