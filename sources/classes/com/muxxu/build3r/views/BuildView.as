package com.muxxu.build3r.views {
	import com.muxxu.build3r.components.Build3rSlider;
	import com.muxxu.build3r.i18n.LabelBuild3r;
	import com.muxxu.build3r.model.ModelBuild3r;
	import com.muxxu.build3r.vo.LightMapData;
	import com.muxxu.build3r.vo.Metrics;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.kub3dit.utils.drawIsoKube;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;

	import flash.display.BitmapData;
	import flash.display.Shape;
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
	 * @date 20 févr. 2012;
	 */
	public class BuildView extends AbstractView {
		
		private var _width:int = 3;
		private var _height:int = 3;
		private var _depth:int = 3;
		
		private var _label:CssTextField;
		private var _holder:Shape;
		private var _slider:Build3rSlider;
		private var _refPoint:Point3D;
		private var _forumPosition:Point3D;
		private var _map:LightMapData;
		private var _forumPositionReference:Point3D;
		private var _emptyCube:BitmapData;
		private var _cache:Array;
		private var _saveSize:int;
		private var _timeout:uint;
		private var _help:CssTextField;
		private var _spacePressed:Boolean;
		private var _localOffset:Point3D;
		private var _dragOffset:Point;
		private var _lastCheck:Point;
		private var _markerCube:*;
		private var _localOffsetSave:Point3D;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BuildView</code>.
		 */
		public function BuildView() {
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
			if(model.mapReferencePoint != null) {
				visible = true;
				_refPoint = model.mapReferencePoint;
				_forumPositionReference = model.positionReference;
				_forumPosition = model.position;
				_map = model.map;
				_localOffset.x = _localOffset.y = _localOffset.z = 0;
				
				render();
				timeoutRendering();
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
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_cache =  [];
			visible = false;
			_lastCheck = new Point();
			_localOffset = new Point3D();
			
			var emptyFace:BitmapData = new BitmapData(16, 16, true, 0x09ffffff);
			_emptyCube = drawIsoKube(emptyFace, emptyFace, false, 1, true, 0x33cc0000);
			
			var markerFace:BitmapData = new BitmapData(16, 16, true, 0xA0ff0000);
			_markerCube = drawIsoKube(markerFace, markerFace, false, 1, true, 0xA0cc0000);
			
			_holder = addChild(new Shape()) as Shape;
			_label = addChild(new CssTextField("b-label")) as CssTextField;
			_help = addChild(new CssTextField("b-label")) as CssTextField;
			_slider = addChild(new Build3rSlider(1, 10)) as Build3rSlider;
			
			_label.width = _slider.width = Metrics.STAGE_WIDTH;
			_label.text = LabelBuild3r.getl("build-title");
			_help.text = "(← ↑ → ↓ ▲ ▼ + - <font face='Arial'>˽</font> )";
			_slider.y = Math.round(_label.height) + 5;
			_slider.value = _width;
			_slider.x = Math.round((Metrics.STAGE_WIDTH - _slider.width) * .5);
			_help.x = Math.round((Metrics.STAGE_WIDTH - _help.width) * .5);
			_help.y = Math.round(Metrics.STAGE_HEIGHT - _help.height);
			
			_slider.addEventListener(Event.CHANGE, changeSizeHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
		}
		
		/**
		 * Called when a mouse event occurs.
		 * 
		 * Used to drag the map.
		 */
		private function mouseEventHandler(event:MouseEvent):void {
			//Mouse down
			if(event.type == MouseEvent.MOUSE_DOWN) {
				if(mouseY < _holder.y || mouseY > _help.y) return;
				
				_dragOffset = new Point(mouseX, mouseY);
				_lastCheck.x = mouseX;
				_lastCheck.y = mouseY;
				addEventListener(MouseEvent.MOUSE_MOVE, mouseEventHandler);
			
			//Mouse release
			}else if(event.type == MouseEvent.MOUSE_UP) {
				removeEventListener(MouseEvent.MOUSE_MOVE, mouseEventHandler);
			
			//Mouse move. Manage drag
			} else {
				var dx:Number = mouseX-_lastCheck.x;
				var dy:Number = mouseY-_lastCheck.y;
				var d:Number = Math.sqrt(dx * dx + dy * dy);
				if(d > 10) {
					var a:Number = Math.atan2(dy, dx)+Math.PI;
					_lastCheck.x = mouseX;
					_lastCheck.y = mouseY;
					if(a > 0 && a <= Math.PI*.4) _localOffset.y -= 1;
					if(a > Math.PI*.4 && a < Math.PI * .6) _localOffset.z += 1;
					if(a > Math.PI*.6 && a <= Math.PI) _localOffset.x += 1;
					
					if(a > Math.PI && a <= Math.PI*1.4) _localOffset.y += 1;
					if(a > Math.PI*1.4 && a <= Math.PI * 1.6) _localOffset.z -= 1;
					if(a <= 0 || a > Math.PI*1.6) _localOffset.x -= 1;
				}
				render();
			}
		}
		
		/**
		 * Called when slider's value changes
		 */
		private function changeSizeHandler(event:Event = null):void {
			clearTimeout(_timeout);
			_width = _height = _depth = _slider.value;
			render();
		}

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
		}
		
		/**
		 * Called when a key is pressed
		 */
		private function keyDownHandler(event:KeyboardEvent):void {
			if(!visible) return;
			
			if(event.keyCode == Keyboard.NUMPAD_ADD || event.keyCode == Keyboard.EQUAL) {
				_slider.value ++;
				changeSizeHandler();
				return;
			}
			
			if (event.keyCode == Keyboard.NUMPAD_SUBTRACT || event.keyCode == Keyboard.NUMBER_6) {
				_slider.value --;
				changeSizeHandler();
				return;
			}
			
			
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
			
			_localOffset.x += px;
			_localOffset.y += py;
			_localOffset.z += pz;
			render();
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
		private function render():void {
			var i:int, len:int, w:int, h:int, bmd:BitmapData, textures:Array, pos:Point3D;
			var margin:int, tile:int, ratio:Number, m:Matrix, pos2:Point, offsetedPos:Point3D;
			ratio = _width>5? 1-(_width-5)*.1 : 1;
			margin = 0;
			textures = Textures.getInstance().bitmapDatas;
			pos = new Point3D();
			pos2 = new Point();
			offsetedPos = _forumPosition.clone();
			offsetedPos.x -= _forumPositionReference.x - _refPoint.x + _localOffset.x;
			offsetedPos.y -= _forumPositionReference.y - _refPoint.y + _localOffset.y;
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
				pos.x = _width-1 - i % _width - Math.floor(_width*.5); 
				pos.y = Math.floor(i / _height)%_height - Math.floor(_height*.5);
				pos.z =  Math.floor(i / (_height*_width));
				
				tile = _map.getTile(pos.x + offsetedPos.x, pos.y + offsetedPos.y, pos.z + offsetedPos.z - Math.floor(_depth*.5));
				
//				pos.z -= Math.floor(_depth*.5);
				pos2.x  = ((pos.x+Math.floor(_width*.5)) * w + pos.y * w *.5 - pos.x*w*.5);
				pos2.y = (_depth * h * .75 + pos.y * h*.25 - pos.z * h * .5 - pos.x*h*.25 - h);
				if(tile == 15) trace(pos, pos2)
				
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
					if(pos.x == -Math.floor(_width*.5) || pos.y == Math.ceil(_height*.5)-1 || pos.z == _depth-1) {
						bmd = _emptyCube;
					}else{
						drawMarker(pos, offsetedPos, pos2, w, h, margin, m, ratio);
						continue;
					}
				}
				
				_holder.graphics.beginBitmapFill(bmd, m, false, ratio < 1);
				_holder.graphics.drawRect(pos2.x, pos2.y, w-margin, h-margin);
				_holder.graphics.endFill();
				drawMarker(pos, offsetedPos, pos2, w, h, margin, m, ratio);
			}
			
			var py:int = _slider.y + _slider.height + 10;
			_holder.y = Math.round((Metrics.STAGE_HEIGHT-_help.height-py - _holder.height) * .5) + py;
			_holder.x = Math.round((Metrics.STAGE_WIDTH - _holder.width) * .5);
			var bounds:Rectangle = _holder.getBounds(_holder);
			_holder.x -= bounds.x;
			_holder.y -= bounds.y;
		}

		private function drawMarker(pos:Point3D, offsetedPos:Point3D, pos2:Point, w:int, h:int, margin:int, m:Matrix, ratio:Number):void {
			if(!_spacePressed
			&& pos.x + offsetedPos.x == _forumPosition.x-_forumPositionReference.x + _refPoint.x
			&& pos.y + offsetedPos.y == _forumPosition.y-_forumPositionReference.y + _refPoint.y
			&& pos.z + offsetedPos.z - Math.floor(_depth*.5) == _forumPosition.z-_forumPositionReference.z + _refPoint.z) {
				_holder.graphics.beginBitmapFill(_markerCube, m, false, ratio < 1);
				_holder.graphics.drawRect(pos2.x, pos2.y, w-margin, h-margin);
				_holder.graphics.endFill();
			}
		}
		
	}
}