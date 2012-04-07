package com.muxxu.build3r.components {
	import com.muxxu.build3r.vo.LightMapData;
	import com.muxxu.build3r.vo.Metrics;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.utils.drawIsoKube;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	/**
	 * 
	 * @author Francois
	 * @date 29 mars 2012;
	 */
	public class FlatMap extends Sprite implements IBuild3rMap {
		
		private var _width:int = 3;
		private var _height:int = 3;
		private var _depth:int = 3;
		
		private var _refPoint:Point3D;
		private var _forumPositionReference:Point3D;
		private var _forumPosition:Point3D;
		private var _map:LightMapData;
		private var _dragOffset:Point;
		private var _localOffset:Point3D;
		private var _holder:Sprite;
		private var _ready:Boolean;
		private var _emptyBmd:BitmapData;
		private var _dragLocOffset:Point3D;
		private var _cache:Array;
		private var _levelSlider:Build3rSlider;
		private var _dragMode:Boolean;
		private var _cacheISO:Array;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FlatMap</code>.
		 */
		public function FlatMap() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function set sizes(value:int):void {
			_width = _height = _depth = value;
			render();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get sizes():int {
			return _width;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function update(mapReferencePoint:Point3D, positionReference:Point3D, position:Point3D, map:LightMapData):void {
			_refPoint = mapReferencePoint;
			_forumPositionReference = positionReference;
			_forumPosition = position;
			_map = map;
			_localOffset.x = _localOffset.y = _localOffset.z = 0;
			_levelSlider.value = _refPoint.z - _localOffset.z + 1;
			
			_ready = true;
			render();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_cache = [];
			_cacheISO = [];
			_localOffset = new Point3D();
			_holder = addChild(new Sprite()) as Sprite;
			_emptyBmd = new BitmapData(16, 16, true, 0);
			_levelSlider = addChild(new Build3rSlider(1, 31)) as Build3rSlider;
			
			_levelSlider.width = Metrics.STAGE_WIDTH - 20;
			
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseEventHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseEventHandler);
			_holder.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			_levelSlider.addEventListener(Event.CHANGE, levelChangeHandler);
			addEventListener(Event.ADDED_TO_STAGE, render);
		}
		
		/**
		 * Called when slider's value changes
		 */
		private function levelChangeHandler(event:Event):void {
			_localOffset.z = -_levelSlider.value+_refPoint.z+1;
			render();
		}
		
		/**
		 * Called when a mouse event occurs.
		 * 
		 * Used to drag the map.
		 */
		private function mouseEventHandler(event:MouseEvent):void {
			if(stage == null) return;
			
			//Mouse down
			if(event.type == MouseEvent.MOUSE_DOWN) {
				_dragOffset = new Point(mouseX, mouseY);
				_dragLocOffset = _localOffset.clone();
				_dragMode = true;
				
			//Mouse release
			}else if(event.type == MouseEvent.MOUSE_UP) {
				_dragMode = false;
			
			//Mouse wheel
			}else if(event.type == MouseEvent.MOUSE_WHEEL) {
				_localOffset.z -= MathUtils.sign(event.delta);
				_levelSlider.value = _refPoint.z - _localOffset.z + 1;
				render();
			
			//Mouse move. Manage drag
			} else {
				if (_dragMode) {
					_localOffset.x = _dragLocOffset.x - Math.round((mouseX - _dragOffset.x) / 10);
					_localOffset.y = _dragLocOffset.y - Math.round((mouseY - _dragOffset.y) / 10);
					render();
				}
				
				if (_holder.hitTestPoint(stage.mouseX, stage.mouseY)) {
					var offsetedPos:Point3D = _forumPosition.clone();
					offsetedPos.x -= _forumPositionReference.x - _refPoint.x - _localOffset.x;
					offsetedPos.y -= _forumPositionReference.y - _refPoint.y - _localOffset.y;
					offsetedPos.z -= _forumPositionReference.z - _refPoint.z + _localOffset.z;
					
					var cellSize:int = 32 * Math.min(1, Metrics.STAGE_WIDTH / (32 * _width));
					var px:int = Math.floor(_holder.mouseX/cellSize) + offsetedPos.x - Math.floor(_width*.5);
					var py:int = Math.floor(_holder.mouseY/cellSize) + offsetedPos.y - Math.floor(_height*.5);
					var tile:int = _map.getTile(px, py, offsetedPos.z);
					
					if(tile > 0) {
						var bmd:BitmapData;
						if(_cacheISO[tile] == null) {
							bmd = drawIsoKube(Textures.getInstance().bitmapDatas[tile][0], Textures.getInstance().bitmapDatas[tile][1], false, 1, true);
							_cacheISO[tile] = bmd;
						}else{
							bmd = _cacheISO[tile];
						}
						
						_holder.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, bmd ));
					}else{
						_holder.dispatchEvent(new ToolTipEvent(ToolTipEvent.CLOSE ));
					}
				}
			}
		}
		
		/**
		 * Called when a key is pressed
		 */
		private function keyDownHandler(event:KeyboardEvent):void {
			if(stage == null) return;
			
			var px:int, py:int, pz:int;
			
			if(event.keyCode == Keyboard.UP) py = -1;
			if(event.keyCode == Keyboard.DOWN) py = 1;
			if(event.keyCode == Keyboard.RIGHT) px = 1;
			if(event.keyCode == Keyboard.LEFT) px = -1;
			if(event.keyCode == Keyboard.PAGE_UP) pz = -1;
			if(event.keyCode == Keyboard.PAGE_DOWN) pz = 1;
			
			if(px != 0 || py != 0 || pz != 0) {
				_localOffset.x += px;
				_localOffset.y += py;
				_localOffset.z += pz;
				if(pz != 0) {
					_levelSlider.value = _refPoint.z - _localOffset.z + 1;
				}
				render();
			}
		}

		
		/**
		 * Renders the grid.
		 */
		private function render(event:Event = null):void {
			if(!_ready) return;
			
			var i:int, len:int, w:int, h:int, bmd:BitmapData, textures:Array, pos:Point3D, drawMark:Boolean;
			var tile:int, ratio:Number, m:Matrix, pos2:Point, offsetedPos:Point3D,tmpPos:Point3D;
			ratio = Math.min(1, Metrics.STAGE_WIDTH/(32*_width));
			textures = Textures.getInstance().bitmapDatas;
			pos = new Point3D();
			pos2 = new Point();
			tmpPos = new Point3D();
			offsetedPos = _forumPosition.clone();
			offsetedPos.x -= _forumPositionReference.x - _refPoint.x - _localOffset.x;
			offsetedPos.y -= _forumPositionReference.y - _refPoint.y - _localOffset.y;
			offsetedPos.z -= _forumPositionReference.z - _refPoint.z;
			if(offsetedPos.z-_localOffset.z < 0) _localOffset.z += offsetedPos.z-_localOffset.z;
			if(offsetedPos.z-_localOffset.z > 30) _localOffset.z = offsetedPos.z-30;
			offsetedPos.z -= _localOffset.z;
			
			len = _width * _height;
			w = 32 * ratio;
			h = 32 * ratio;
			m = new Matrix();
			_holder.graphics.clear();
			_holder.graphics.lineStyle(0,0,.5);
			
			pos.z = offsetedPos.z;
			
			for(i = 0; i < len; ++i) {
				pos.x = _width-1 - i % _width; 
				pos.y = Math.floor(i / _height)%_height;
				
				tmpPos.x = pos.x;
				tmpPos.y = pos.y;
				tmpPos.z = pos.z;
				tmpPos.x += offsetedPos.x - Math.floor(_width*.5);
				tmpPos.y += offsetedPos.y - Math.floor(_height*.5);
				
				drawMark = tmpPos.x == _forumPosition.x-_forumPositionReference.x + _refPoint.x
							&& tmpPos.y == _forumPosition.y-_forumPositionReference.y + _refPoint.y
							&& tmpPos.z == _forumPosition.z-_forumPositionReference.z + _refPoint.z;
				
				tile = _map.getTile(tmpPos.x, tmpPos.y, tmpPos.z);
				
//				pos.z -= Math.floor(_depth*.5);
				pos2.x  = pos.x * w;
				pos2.y = pos.y * h;
				
				m.identity();
				m.scale(2 * ratio, 2 * ratio);
				m.translate(pos2.x, pos2.y);
				
				if(tile > 0) {
					if(_cache[tile] == undefined) {
						bmd = _cache[tile] = textures[tile][0];
					}else{
						bmd = _cache[tile];
					}
				}else{
					bmd = _emptyBmd;
				}
				
				_holder.graphics.beginBitmapFill(bmd, m, false, ratio < 1);
				_holder.graphics.drawRect(pos2.x, pos2.y, w, h);
				_holder.graphics.endFill();
				if(drawMark) {
					_holder.graphics.lineStyle(0,0xff0000,1);
					_holder.graphics.beginFill(0xff0000, .3);
					_holder.graphics.drawRect(pos2.x+1, pos2.y+1, w-2, h-2);
					_holder.graphics.lineStyle(0,0,.5);
				}
			}
			
			//Center the holder
			_holder.y = Math.round((Metrics.STAGE_HEIGHT-y - _holder.height) * .5)-20;
			_holder.x = Math.round((Metrics.STAGE_WIDTH - _holder.width) * .5);
			var bounds:Rectangle = _holder.getBounds(_holder);
			_holder.x -= bounds.x;
			_holder.y -= bounds.y;
			_levelSlider.y = _holder.y + _holder.height + 10;
			PosUtils.hCenterIn(_levelSlider, Metrics.STAGE_WIDTH);
		}
		
	}
}