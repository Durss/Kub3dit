package com.muxxu.build3r.views {
	import flash.media.SoundTransform;
	import com.muxxu.build3r.components.Build3rSlider;
	import com.muxxu.build3r.controler.FrontControlerBuild3r;
	import com.muxxu.build3r.i18n.LabelBuild3r;
	import com.muxxu.build3r.model.ModelBuild3r;
	import com.muxxu.build3r.vo.LightMapData;
	import com.muxxu.build3r.vo.Metrics;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.kub3dit.utils.drawIsoKube;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.math.MathUtils;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.Sound;

	/**
	 * 
	 * @author Francois
	 * @date 20 févr. 2012;
	 */
	public class SynchView extends AbstractView {
		
		private const _MAP_SIZE:int = 38;
		private const _CELL_SIZE:int = 5;
		
		private var _bmp:Bitmap;
		private var _bmd:BitmapData;
		private var _level:int;
		private var _offset:Point;
		private var _map:LightMapData;
		private var _colors:Array;
		private var _grid:Sprite;
		private var _pressed:Boolean;
		private var _offsetDrag:Point;
		private var _offsetPos:Point;
		private var _hasDragged:Boolean;
		private var _cursor:Shape;
		private var _holder:Sprite;
		private var _mapLabel:CssTextField;
		private var _slider:Build3rSlider;
		private var _kubeLabel:CssTextField;
		private var _kube:Shape;
		private var _kubeCoos:CssTextField;
		private var _reference:Point3D;
		private var _submit:ButtonKube;
		
		[Embed(source="../../../../../assets/check.mp3")]
		private var _sound:Class;
		private var _forumTouched:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SynchView</code>.
		 */
		public function SynchView() {
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
			if(model.mapReferencePoint != null || model.map == null) {
				visible = false;
				return;
			}
			
			if(model.map != null && model.map != _map) {
				_map = model.map;
				visible = true;
				_level = 0;
				_reference.x = _reference.y = -1;
				_offset = new Point(Math.round((_map.width -  _MAP_SIZE) * .5), Math.round((_map.height -  _MAP_SIZE) * .5));
				_colors = Textures.getInstance().levelColors;
				_kubeCoos.style = "b-kubeCoosBig";
				_kubeCoos.text = "[--][--][--]";
				
				_submit.enabled = false;
				
				drawLevel();
			}
			
			if(model.position != null) {
				_forumTouched = true;
				_kubeCoos.style = "b-kubeCoos";
				_kubeCoos.text = "["+model.position.x+"]["+model.position.y+"]["+model.position.z+"]";
				checkComplete();
			}
			_kubeCoos.y = _kube.y + Math.round((_kube.height - _kubeCoos.height) * .5);
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
			
			visible = false;
			_reference = new Point3D(-1,-1,-1);
			_bmd = new BitmapData(_MAP_SIZE, _MAP_SIZE, false, 0);
			_mapLabel = addChild(new CssTextField("b-label")) as CssTextField;
			_holder = addChild(new Sprite()) as Sprite;
			_bmp = _holder.addChild(new Bitmap(_bmd)) as Bitmap;
			_cursor = _holder.addChild(new Shape()) as Shape;
			_grid = _holder.addChild(new Sprite()) as Sprite;
			_slider = _holder.addChild(new Build3rSlider(1, 31)) as Build3rSlider;
			_kube = addChild(drawIsoKube(Textures.getInstance().bitmapDatas[70][0], Textures.getInstance().bitmapDatas[70][1], true, .5)) as Shape;
			
			_kubeLabel = addChild(new CssTextField("b-label")) as CssTextField;
			_kubeCoos = addChild(new CssTextField("b-kubeCoosBig")) as CssTextField;
			_submit = addChild(new ButtonKube(LabelBuild3r.getl("synch-submit"), false, null, true)) as ButtonKube;
			
			_mapLabel.text = LabelBuild3r.getl("synch-titleMap");
			_kubeLabel.text = LabelBuild3r.getl("synch-titleKube");
			_mapLabel.width = Metrics.STAGE_WIDTH;
			_kubeLabel.width = Metrics.STAGE_WIDTH;

			var pattern:BitmapData = new BitmapData(_CELL_SIZE, _CELL_SIZE, true, 0);
			var i:int;
			for(i = 0; i < _CELL_SIZE; ++i) {
				pattern.setPixel32(i, 0, 0x33000000);
				pattern.setPixel32(0, i, 0x33000000);
			}
			
			_cursor.graphics.beginFill(0xffffff, .5);
			_cursor.graphics.drawRect(0, 0, _CELL_SIZE, _CELL_SIZE);
			_cursor.graphics.endFill();
			
			_grid.graphics.beginBitmapFill(pattern);
			_grid.graphics.drawRect(0, 0, _MAP_SIZE * _CELL_SIZE, _MAP_SIZE * _CELL_SIZE);
			_grid.graphics.endFill();
			
			_bmp.scaleX = _bmp.scaleY = _CELL_SIZE;
			_holder.x = Math.round((Metrics.STAGE_WIDTH - _bmp.width) * .5);
			_holder.y = Math.round(_mapLabel.height);
			_slider.y = _CELL_SIZE * _MAP_SIZE + 5;
			_slider.width = _CELL_SIZE * _MAP_SIZE;
			_kubeLabel.y = _holder.y + _holder.height + 5;
			_kube.y = _kubeLabel.y + _kubeLabel.height;
			_kubeCoos.x = _kube.width + 10;
			_submit.x = Math.round(Metrics.STAGE_WIDTH - _submit.width);
			_submit.y = Math.round(Metrics.STAGE_HEIGHT - _submit.height);
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseEventHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_slider.addEventListener(Event.CHANGE, changeLevelHandler);
			_submit.addEventListener(MouseEvent.CLICK, submitHandler);
		}
		
		/**
		 * Called when form is submitted.
		 */
		private function submitHandler(event:MouseEvent):void {
			stage.focus = null;
			FrontControlerBuild3r.getInstance().setReferencePoint(_reference);
		}
		
		/**
		 * Draw the current level
		 */
		private function drawLevel():void {
			_offset.x = MathUtils.restrict(_offset.x, 0, _map.width - _MAP_SIZE);
			_offset.y = MathUtils.restrict(_offset.y, 0, _map.height - _MAP_SIZE);
			
			if(_map.width < _MAP_SIZE) _offset.x = (_map.width - _MAP_SIZE)*.5;
			if(_map.height < _MAP_SIZE) _offset.y = (_map.height - _MAP_SIZE)*.5;
			
			var i:int, len:int, tile:int, px:int, py:int;
			len = _MAP_SIZE * _MAP_SIZE;
			_bmd.fillRect(_bmd.rect, 0xff80c7db);
			for(i = 0; i < len; ++i) {
				px = i%_MAP_SIZE;
				py = Math.floor(i/_MAP_SIZE);
				tile = _map.getTile(px + _offset.x, py + _offset.y, _level);
				if(_reference.x > -1 && _reference.x == px+_offset.x && _reference.y == py+_offset.y && _reference.z == _level) {
					_bmd.setPixel32(px, py, 0xffff0000);
				}else{
					if(tile > 0) {
						_bmd.setPixel32(px, py, _colors[tile][_level]);
					}
				}
			}
		}
		
		/**
		 * Called when slider's value is modified
		 */
		private function changeLevelHandler(event:Event):void {
			_level = _slider.value - 1;
			drawLevel();
		}
		
		/**
		 * Check if everything's complete
		 */
		private function checkComplete():void {
			_submit.enabled = _reference.x != -1 && _forumTouched;
			if(_submit.enabled) {
				Sound(new _sound()).play(0, 0, new SoundTransform(.1));//TODO reset sound to 1
			}
		}
		
		/**
		 * Called when a mouse event occurs
		 */
		private function mouseEventHandler(event:MouseEvent):void {
			if(!visible) return;
			
			if(event.type == MouseEvent.MOUSE_DOWN && event.target == _grid) {
				_pressed = true;
				_hasDragged = false;
				_offsetDrag = new Point(stage.mouseX, stage.mouseY);
				_offsetPos = _offset.clone();
			}else if(event.type == MouseEvent.MOUSE_UP) {
				_pressed = false;
				if (!_hasDragged && event.target == _grid) {
					var pos:Point = new Point(Math.floor(_holder.mouseX / _CELL_SIZE), Math.floor(_holder.mouseY / _CELL_SIZE));
					_reference.x = pos.x + _offset.x;
					_reference.y = pos.y + _offset.y;
					_reference.z = _level;
					drawLevel();
					checkComplete();
				}
			}else if(event.type == MouseEvent.MOUSE_WHEEL) {
				_level += event.delta > 0? 1 : -1;
				_level = MathUtils.restrict(_level, 0, 30);
				_slider.value = _level + 1;
				drawLevel();
			}
		}
		
		/**
		 * Called on ENTER_FRAME event to manage dragging
		 */
		private function enterFrameHandler(event:Event):void {
			if(_pressed){
				_offset.x = _offsetPos.x + Math.round((_offsetDrag.x - stage.mouseX)/_CELL_SIZE);
				_offset.y = _offsetPos.y + Math.round((_offsetDrag.y - stage.mouseY)/_CELL_SIZE);
				if(!_hasDragged) {
					_hasDragged = Math.abs(_offsetDrag.x - stage.mouseX) >= _CELL_SIZE || Math.abs(_offsetDrag.y - stage.mouseY) >= _CELL_SIZE;
				}
				drawLevel();
			}
			
			_cursor.x = Math.floor(_holder.mouseX/_CELL_SIZE) * _CELL_SIZE;
			_cursor.y = Math.floor(_holder.mouseY/_CELL_SIZE) * _CELL_SIZE;
			_cursor.visible = _cursor.x >= 0 && _cursor.y >= 0 && _cursor.x <= _MAP_SIZE*_CELL_SIZE - _CELL_SIZE && _cursor.y <= _MAP_SIZE*_CELL_SIZE - _CELL_SIZE;
		}
		
	}
}