package com.muxxu.kub3dit.components.tooltip {	import com.muxxu.kub3dit.components.tooltip.content.ToolTipContent;	import com.muxxu.kub3dit.components.window.BackWindow;	import com.muxxu.kub3dit.vo.ToolTipMessage;	import flash.display.DisplayObject;	import flash.display.InteractiveObject;	import flash.display.Shape;	import flash.display.Sprite;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.filters.DropShadowFilter;	import flash.geom.Point;	import flash.geom.Rectangle;	import gs.TweenLite;	/**	 * Displays a tooltip.	 * 	 * @author  Francois	 */	public class ToolTip extends Sprite {		private var _currentContent:ToolTipContent;		private var _target:InteractiveObject;		private var _background:BackWindow;		private var _backMask:Shape;		private var _opened:Boolean;
								/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>ToolTip</code>.		 */		public function ToolTip() {			initialize();		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Gets the virtual component's height.		 */		override public function get height():Number { return _background.height; }				/**		 * Gets the virtual component's width.		 */		override public function get width():Number { return _background.width; }				/**		 * Sets the X and restrict it to be always visible.		 */		override public function set x(value:Number):void {			super.x = value;			var globPoint:Point = localToGlobal(new Point(0, 0));			if(globPoint.x < 0) value -= globPoint.x;			if(stage != null) {				if(globPoint.x > stage.stageWidth - width) value -= globPoint.x - (stage.stageWidth - width);			}			super.x = value;		}				/**		 * Sets the X and restrict it to be always visible.		 */		override public function set y(value:Number):void {			super.y = value;			var globPoint:Point = localToGlobal(new Point(0, 0));			if(globPoint.y < 0) value -= globPoint.y;//globalToLocal(new Point(0,0)).y;			if(stage != null) {				if(globPoint.y > stage.stageHeight - height) value -= globPoint.y - (stage.stageHeight - height);			}			super.y = value;		}						/* ****** *		 * PUBLIC *		 * ****** */		/**		 * Opens the tooltip with a specific content.		 */		public function open(data:ToolTipMessage):void {			//if the target has changed			if(_target != data.target) {				if(_target != null) {					_target.removeEventListener(MouseEvent.ROLL_OUT, rollOutTargetHandler);				}				_target = data.target;				if(_target != null) {					_target.addEventListener(MouseEvent.ROLL_OUT, rollOutTargetHandler);				}			}						//If we display a new content			if(_currentContent != data.content) {				//Dispose previous content				if(_currentContent != null) {					removeChild(_currentContent as DisplayObject);					_currentContent.dispose();					_currentContent.removeEventListener(Event.CLOSE, close);					_currentContent.removeEventListener(Event.RESIZE, computePositions);				}				_currentContent = data.content;				_currentContent.addEventListener(Event.CLOSE, close);				_currentContent.addEventListener(Event.RESIZE, computePositions);				addChild(_currentContent as DisplayObject);			}			if(!_opened) {				TweenLite.killTweensOf(this);				TweenLite.to(this, .3, {autoAlpha:1});			}			_opened = true;			computePositions();		}		/**		 * Closes the tooltip.		 */		public function close(...arg):void {			if(_opened) {				_target = null;				_opened = false;				TweenLite.killTweensOf(this);
				TweenLite.to(this, .3, {autoAlpha:0});
				dispatchEvent(new Event(Event.CLOSE));			}		}		/**		 * Locks the tooltip.<br>		 * <br>		 * Once locked, the tooltip is closed when it's rolled out. 		 */		public function lock():void {			if(_target != null) {				_target.removeEventListener(MouseEvent.ROLL_OUT, rollOutTargetHandler);			}			_currentContent.addEventListener(MouseEvent.ROLL_OUT, rollOutTargetHandler);		}								/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initialize the class.		 */		private function initialize():void {			_background = addChild(new BackWindow()) as BackWindow;			_backMask	= addChild(new Shape()) as Shape;						alpha = 0;			visible = false;			mouseEnabled = false;			mouseChildren = false;						_backMask.graphics.beginFill(0xFF0000, .5);			_backMask.graphics.drawRect(0, 0, 50, 50);			_background.mask = _backMask;						filters = [new DropShadowFilter(4,45,0,.4,7,7,.7,3)];		}		/**		 * Resize and replace the elements.		 */		private function computePositions(e:Event = null):void {			var content:DisplayObject = _currentContent as DisplayObject;			var margin:int		= 1;			var windowMargin:int= 10;			var backW:int		= Math.round(content.width + (margin + BackWindow.CELL_WIDTH) * 2) - 1;			var backH:int		= Math.round(content.height + (margin + BackWindow.CELL_WIDTH) * 2) - 1;						if(_target != null) {				var bounds:Rectangle= _target.getBounds(_target);				var pos:Point		= _target.localToGlobal(new Point(bounds.x, bounds.y));								if(stage != null) {					if(pos.x < windowMargin)								pos.x = windowMargin;					if(pos.x > stage.stageWidth - backW - windowMargin)		pos.x = stage.stageWidth - backW - windowMargin;					if(pos.y < 0)											pos.y = windowMargin;					if(pos.y > stage.stageHeight - backH - windowMargin)	pos.y = stage.stageHeight - backH - windowMargin;				}								pos					= parent.globalToLocal(pos);				pos.x				= Math.round(pos.x + (bounds.width - backW) * .5);				pos.y				= Math.round(pos.y - backH - 5);								x = pos.x;				y = pos.y;			}			_background.width = _backMask.width = backW;			_background.height = _backMask.height = backH;			content.x = content.y = margin + BackWindow.CELL_WIDTH;		}				/**		 * Called when the target is rolled out.		 */		private function rollOutTargetHandler(e:MouseEvent):void {			if(_target != null) {				_target.removeEventListener(MouseEvent.ROLL_OUT, rollOutTargetHandler);			}			_currentContent.removeEventListener(MouseEvent.ROLL_OUT, rollOutTargetHandler);			close();		}	}}