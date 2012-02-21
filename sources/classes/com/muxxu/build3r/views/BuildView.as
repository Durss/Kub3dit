package com.muxxu.build3r.views {
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import com.muxxu.build3r.components.Build3rSlider;
	import com.muxxu.build3r.controler.FrontControlerBuild3r;
	import com.muxxu.build3r.model.ModelBuild3r;
	import com.muxxu.build3r.vo.LightMapData;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.kub3dit.utils.drawIsoKube;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

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
		private var _refPoint:Point;
		private var _position:Point3D;
		private var _map:LightMapData;
		private var _posRefPoint:Point3D;
		private var _emptyCube:BitmapData;
		private var _cache:Array;
		private var _saveSize:int;
		private var _timeout:uint;
		private var _forumTouch:Boolean;
		private var _help:CssTextField;
		private var _spacePressed:Boolean;
		
		
		
		
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
				_posRefPoint = model.positionReference;
				_position = model.position;
				_map = model.map;
				
				if(_forumTouch) {
					timeoutRendering();
				}
				render();
				_forumTouch = true;
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
			_forumTouch = true;
			
			var emptyFace:BitmapData = new BitmapData(16, 16, true, 0x09ffffff);
			_emptyCube = drawIsoKube(emptyFace, emptyFace, false, 1, true);
			_holder = addChild(new Shape()) as Shape;
			_label = addChild(new CssTextField("b-label")) as CssTextField;
			_help = addChild(new CssTextField("b-label")) as CssTextField;
			_slider = addChild(new Build3rSlider(1, 10)) as Build3rSlider;
			
			_label.width = _slider.width = stage.stageWidth;
			_label.text = "Touchez un kube forum pour savoir quel kube doit se trouver à son emplacement.";
			_help.text = "(← ↑ → ↓ ▲ ▼ + - <font face='Arial'>˽</font> )";
			_slider.y = Math.round(_label.height) + 5;
			_slider.value = _width;
			PosUtils.hCenterIn(_slider, stage);
			PosUtils.hCenterIn(_help, stage);
			PosUtils.alignToBottomOf(_help, stage);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			_slider.addEventListener(Event.CHANGE, changeSizeHandler);
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
			if(event.keyCode == Keyboard.SPACE) _spacePressed = false;
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
					timeoutRendering();
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
			
			_forumTouch = false;
			FrontControlerBuild3r.getInstance().move(px, py, pz);
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
			offsetedPos = _position.clone();
			offsetedPos.x -= _posRefPoint.x - _refPoint.x;
			offsetedPos.y -= _posRefPoint.y - _refPoint.y;
			
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
						continue;
					}
				}
				
				pos.z -= Math.floor(_depth*.5);
				pos2.x  = ((pos.x+Math.floor(_width*.5)) * w + pos.y * w *.5 - pos.x*w*.5);
				pos2.y = (_depth * h * .75 + pos.y * h*.25 - pos.z * h * .5 - pos.x*h*.25 - h);
				
				m.identity();
				m.scale(ratio, ratio);
				m.translate(pos2.x, pos2.y);
				
				_holder.graphics.beginBitmapFill(bmd, m, false, ratio < 1);
				_holder.graphics.drawRect(pos2.x, pos2.y, w-margin, h-margin);
				_holder.graphics.endFill();
			}
			
			var py:int = _slider.y + _slider.height + 10;
			_holder.y = Math.round((stage.stageHeight-_help.height-py - _holder.height) * .5) + py;
			PosUtils.hCenterIn(_holder, stage);
			var bounds:Rectangle = _holder.getBounds(_holder);
			_holder.x -= bounds.x;
			_holder.y -= bounds.y;
		}
		
	}
}