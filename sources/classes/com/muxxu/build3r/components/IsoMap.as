package com.muxxu.build3r.components {
	import com.muxxu.build3r.graphics.NorthArrowGraphic;
	import com.muxxu.build3r.vo.LightMapData;
	import com.muxxu.build3r.vo.Metrics;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.kub3dit.utils.drawIsoKube;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * 
	 * @author Francois
	 * @date 11 mars 2012;
	 */
	public class IsoMap extends Sprite implements IBuild3rMap {
		
		private var _width:int = 3;
		private var _height:int = 3;
		private var _depth:int = 3;
		
		private var _holder:Shape;
		private var _refPoint:Point3D;
		private var _forumPosition:Point3D;
		private var _map:LightMapData;
		private var _forumPositionReference:Point3D;
		private var _emptyCube:BitmapData;
		private var _cache:Array;
		private var _saveSize:int;
		private var _timeout:uint;
		private var _spacePressed:Boolean;
		private var _localOffset:Point3D;
		private var _dragOffset:Point;
		private var _lastCheck:Point;
		private var _markerCube:*;
		private var _localOffsetSave:Point3D;
		private var _rotation:int;
		private var _northArrow:NorthArrowGraphic;
		private var _ready:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>IsoMap</code>.
		 */
		public function IsoMap() {
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
			
			_ready = true;
			if(stage != null) {
				timeoutRendering();
				render();
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_cache =  [];
			_rotation = 0;
			_lastCheck = new Point();
			_localOffset = new Point3D();
			
			var emptyFace:BitmapData = new BitmapData(16, 16, true, 0x09ffffff);
			_emptyCube = drawIsoKube(emptyFace, emptyFace, false, 1, true, 0x33cc0000);
			
			var markerFace:BitmapData = new BitmapData(16, 16, true, 0xA0ff0000);
			_markerCube = drawIsoKube(markerFace, markerFace, false, 1, true, 0xA0cc0000);
			
			_holder = addChild(new Shape()) as Shape;
			_northArrow = addChild(new NorthArrowGraphic()) as NorthArrowGraphic;
			
			_northArrow.stop();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
			addEventListener(Event.ADDED_TO_STAGE, render);
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
				if(mouseY < _holder.y) return;
				
				_dragOffset = new Point(stage.mouseX, stage.mouseY);
				_lastCheck.x = mouseX;
				_lastCheck.y = mouseY;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseEventHandler);
			
			//Mouse release
			}else if(event.type == MouseEvent.MOUSE_UP) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseEventHandler);
			
			//Mouse move. Manage drag
			} else {
				var dx:Number = mouseX-_lastCheck.x;
				var dy:Number = mouseY-_lastCheck.y;
				var d:Number = Math.sqrt(dx * dx + dy * dy);
				if(d > 10) {
					var a:Number = Math.atan2(dy, dx)+Math.PI;
					_lastCheck.x = mouseX;
					_lastCheck.y = mouseY;
					if(a > 0 && a <= Math.PI*.4) _localOffset.y += _rotation==0? 1 : -1;
					if(a > Math.PI*.4 && a < Math.PI * .6) _localOffset.z += 1;
					if(a > Math.PI*.6 && a <= Math.PI) _localOffset.x += _rotation==0? -1 : 1;
					
					if(a > Math.PI && a <= Math.PI*1.4) _localOffset.y += _rotation==0? -1 : 1;
					if(a > Math.PI*1.4 && a <= Math.PI * 1.6) _localOffset.z -= 1;
					if(a <= 0 || a > Math.PI*1.6) _localOffset.x += _rotation==0? 1 : -1;
				}
				render();
			}
		}
		
		/**
		 * Defines a rendering timout to update the rendering after a delay.
		 */
		private function timeoutRendering():void {
			_saveSize = _width;
			_width = _height = _depth = 1;
			clearTimeout(_timeout);
			_timeout = setTimeout(renderMore, 500);
		}
		
		/**
		 * Called when a key is released
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			
			if(event.keyCode == Keyboard.SPACE) {
				if(_spacePressed) {
					_localOffset = _localOffsetSave.clone();
					_spacePressed = false;
					renderMore();
				}
			}
			
			if(event.keyCode == Keyboard.ENTER) {
				_rotation = (_rotation+180)%360;
				_northArrow.gotoAndStop(_rotation==0? 1 : 2);
				render();
			}
		}
		
		/**
		 * Called when a key is pressed
		 */
		private function keyDownHandler(event:KeyboardEvent):void {
			if(stage == null) return;
			
			if (event.keyCode == Keyboard.SPACE) {
				if(!_spacePressed) {
					_spacePressed = true;
					_localOffsetSave = _localOffset.clone();
					_localOffset.x = _localOffset.y = _localOffset.z = 0;
					timeoutRendering();
					clearTimeout(_timeout);
					render();
				}
				return;
			}
			
			var px:int, py:int, pz:int;
			
			if(event.keyCode == Keyboard.UP) py = -1;
			if(event.keyCode == Keyboard.DOWN) py = 1;
			if(event.keyCode == Keyboard.RIGHT) px = 1;
			if(event.keyCode == Keyboard.LEFT) px = -1;
			if(event.keyCode == Keyboard.PAGE_UP) pz = 1;
			if(event.keyCode == Keyboard.PAGE_DOWN) pz = -1;
			
			if(px != 0 || py != 0 || pz != 0) {
				_localOffset.x += px;
				_localOffset.y += py;
				_localOffset.z += pz;
				render();
			}
		}
		
		/**
		 * Renders more map.
		 */
		private function renderMore():void {
			_width = _height = _depth = _saveSize;
			render();
		}

		
		/**
		 * Renders the grid.
		 */
		private function render(event:Event = null):void {
			if(!_ready) return;
			
			var i:int, len:int, w:int, h:int, bmd:BitmapData, textures:Array, pos:Point3D, drawMark:Boolean;
			var margin:int, tile:int, ratio:Number, m:Matrix, pos2:Point, offsetedPos:Point3D,tmpPos:Point3D;
			ratio = Math.min(1, Metrics.STAGE_WIDTH/(39*_width));
			margin = 0;
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
			
			len = _width * _height * _depth;
			w = 39 * ratio+margin;
			h = 41 * ratio+margin;
			m = new Matrix();
			_holder.graphics.clear();
			for(i = 0; i < len; ++i) {
				pos.x = _width-1 - i % _width; 
				pos.y = Math.floor(i / _height)%_height;
				pos.z = Math.floor(i / (_height*_width));
				
				if (_rotation == 180) {
					tmpPos.x = _width-1-pos.x;
					tmpPos.y = _height-1-pos.y;
				}else{
					tmpPos.x = pos.x;
					tmpPos.y = pos.y;
				}
				tmpPos.x += offsetedPos.x - Math.floor(_width*.5);
				tmpPos.y += offsetedPos.y - Math.floor(_height*.5);
				tmpPos.z = pos.z + offsetedPos.z - Math.floor(_depth*.5);
				
				drawMark = tmpPos.x == _forumPosition.x-_forumPositionReference.x + _refPoint.x
							&& tmpPos.y == _forumPosition.y-_forumPositionReference.y + _refPoint.y
							&& tmpPos.z == _forumPosition.z-_forumPositionReference.z + _refPoint.z;
				
				tile = _map.getTile(tmpPos.x, tmpPos.y, tmpPos.z);
				
//				pos.z -= Math.floor(_depth*.5);
				pos2.x  = ((pos.x) * w + pos.y * w *.5 - pos.x*w*.5);
				pos2.y = (_depth * h * .75 + pos.y * h*.25 - pos.z * h * .5 - pos.x*h*.25 - h);
				
				m.identity();
				m.scale(ratio, ratio);
				m.translate(pos2.x, pos2.y);
				
				if(tile > 0) {
					if(_cache[tile] == null) {
						bmd = drawIsoKube(textures[tile][0], textures[tile][1], false, 1, true);
						_cache[tile] = bmd;
					}else{
						bmd = _cache[tile];
					}
				}else{
					if(pos.x == 0 || pos.y == _height-1 || pos.z == _depth-1) {
						bmd = _emptyCube;
					}else{
						if(drawMark) drawMarker(pos2, w, h, margin, m, ratio);
						continue;
					}
				}
				
				_holder.graphics.beginBitmapFill(bmd, m, false, ratio < 1);
				_holder.graphics.drawRect(pos2.x, pos2.y, w-margin, h-margin);
				_holder.graphics.endFill();
				if(drawMark) drawMarker(pos2, w, h, margin, m, ratio);
			}
			
			//Center the holder
			_holder.y = Math.round((Metrics.STAGE_HEIGHT-y - _holder.height) * .5);
			_holder.x = Math.round((Metrics.STAGE_WIDTH - _holder.width) * .5);
			var bounds:Rectangle = _holder.getBounds(_holder);
			_holder.x -= bounds.x;
			_holder.y -= bounds.y;
			
			if(_rotation == 0) {
				_northArrow.x = _holder.x - bounds.x + bounds.width * .5 - w * _width * .275;
				_northArrow.y = _holder.y - bounds.y + bounds.height * .5 - h * (_depth+1) * .45;
			}else{
				_northArrow.x = _holder.x - bounds.x + bounds.width * .5 + w * _width * .275;
				_northArrow.y = _holder.y - bounds.y + bounds.height * .5 + h * (_depth-1) * .35;
			}
		}
		
		/**
		 * Draws the marker
		 */
		private function drawMarker(pos:Point, w:int, h:int, margin:int, m:Matrix, ratio:Number):void {
			if(!_spacePressed) {
				_holder.graphics.beginBitmapFill(_markerCube, m, false, ratio < 1);
				_holder.graphics.drawRect(pos.x, pos.y, w-margin, h-margin);
				_holder.graphics.endFill();
			}
		}
		
	}
}