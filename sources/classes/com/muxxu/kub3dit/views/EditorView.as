package com.muxxu.kub3dit.views {
	import com.muxxu.kub3dit.components.buttons.ButtonHelp;
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.graphics.GridPattern;
	import com.muxxu.kub3dit.graphics.LookAtgraphic;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.pos.PosUtils;

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
	import flash.utils.getTimer;

	/**
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class EditorView extends AbstractView {
		private var _ready:Boolean;
		private var _3dView:Stage3DView;
		private var _size:int;
		private var _pattern:BitmapData;
		private var _bitmaps:Array;
		private var _pressed:Boolean;
		private var _currentKube:String;
		private var _lastPos:Point;
		private var _model:Model;
		private var _lookAt:LookAtgraphic;
		private var _z:int;
		private var _oldCamPos:Point;
		private var _lastStartTime:int;
		private var _subLevelsDraw:Boolean;
		private var _cellSize:int;
		private var _bmdLevels:Vector.<BitmapData>;
		private var _levelsTarget:Shape;
		private var _dragMode:Boolean;
		private var _offsetDrag:Point;
		private var _offset:Point;
		private var _offsetOffDrag:Point;
		private var _helpButton:ButtonHelp;
		private var _gridHolder:Sprite;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditorView</code>.
		 */
		public function EditorView() {
			
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			_model = event.model as Model;
			if(!_ready) {
				_ready = true;
				_currentKube = _model.currentKubeId;
				initialize();
			}
		}
		
		override public function get width():Number {
			return _size * _cellSize;
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
		private function initialize():void {
			var src:GridPattern = new GridPattern();
			_pattern = new BitmapData(src.width, src.height, true, 0);
			_pattern.draw(src);
			
			_size = 32*2;
			_cellSize = _pattern.width;
			_lastPos = new Point(-1,-1);
			_oldCamPos = new Point(-1,-1);
			_offset = new Point(0,0);
			
			_3dView = ViewLocator.getInstance().locateViewByType(Stage3DView) as Stage3DView;
			_bitmaps = Textures.getInstance().bitmapDatas;
			
			_levelsTarget = new Shape();
			_gridHolder = addChild(new Sprite()) as Sprite;
			_lookAt = _gridHolder.addChild(new LookAtgraphic()) as LookAtgraphic;
			_helpButton = addChild(new ButtonHelp(Label.getLabel("editorHelp"))) as ButtonHelp;
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
			ViewLocator.getInstance().addEventListener(LightModelEvent.KUBE_SELECTION_CHANGE, kubeSelectionChangeHandler);
			
			_gridHolder.scrollRect = new Rectangle(0,0,_size*_cellSize,_size*_cellSize);
		}
		
		/**
		 * Called when a new kube is selected on the selector
		 */
		private function kubeSelectionChangeHandler(event:LightModelEvent):void {
			_currentKube = _model.currentKubeId;
		}
		
		/**
		 * Called on ENTER_FRAME event to render the grid
		 */
		private function enterFrameHandler(event:Event = null):void {
			if(_3dView == null || _3dView.manager.map == null) return;
			var i:int, len:int, ox:int, oy:int, px:int, py:int, tile:int;
			var scrollX:int, scrollY:int;
			//Drag management
			if(_dragMode && _pressed) {
				 _offset.x = Math.round((_offsetDrag.x - mouseX)/_cellSize) + _offsetOffDrag.x;
				 _offset.y = Math.round((_offsetDrag.y - mouseY)/_cellSize) + _offsetOffDrag.y;
			}
			ox = Math.round(-Camera3D.locX - _size * .5) + _offset.x + scrollX;
			oy = Math.round(Camera3D.locY - _size * .5) + _offset.y + scrollY;
			if(ox < 0) _offset.x -= ox;
			if(oy < 0) _offset.y -= oy;
			if(ox > _3dView.manager.map.mapSizeX - _size) _offset.x -= ox - (_3dView.manager.map.mapSizeX - _size);
			if(oy > _3dView.manager.map.mapSizeY - _size) _offset.y -= oy - (_3dView.manager.map.mapSizeY - _size);
			ox = MathUtils.restrict(ox, 0, _3dView.manager.map.mapSizeX - _size);
			oy = MathUtils.restrict(oy, 0, _3dView.manager.map.mapSizeY - _size);
			
			//Draw the water
			_gridHolder.graphics.clear();
			_gridHolder.graphics.beginFill(0x39A8C6);
			_gridHolder.graphics.drawRect(0, 0, _size*_cellSize+1, _size*_cellSize+1);
			_gridHolder.graphics.endFill();
			
			//Sub levels drawing management
			var camPos:Point = new Point(Camera3D.locX, Camera3D.locY);
			if(!camPos.equals(_oldCamPos)) {
				_subLevelsDraw = false;
				_oldCamPos = camPos;
				_lastStartTime = getTimer();
				_bmdLevels = new Vector.<BitmapData>();
			}
			
			//If we didn't moved from Xms and if the sublevels aren't drawn, then draw them
			if(!_subLevelsDraw && getTimer() - _lastStartTime > 100) {
				_subLevelsDraw = true;
				drawSubLevels();
			}
			
			//Look at target orientation
			_lookAt.x = _size * .5 * _cellSize - (_offset.x + scrollX) * _cellSize;
			_lookAt.y = _size * .5 * _cellSize - (_offset.y + scrollY) * _cellSize;
			_lookAt.rotation = Camera3D.rotationX;
			
			//Drawing management
			if(_pressed && !_dragMode) {
				var mousePos:Point = new Point(Math.floor(mouseX/_cellSize), Math.floor(mouseY/_cellSize));
				
				if(mouseX >= 0 && mouseY >= 0 &&
				mouseX < _size*_cellSize && mouseY < _size*_cellSize && 
				!mousePos.equals(_lastPos)) {
					_lastPos = mousePos;
					_3dView.manager.update(ox+mousePos.x, oy+mousePos.y, _z, parseInt(_currentKube));
				}
			}
			
			//Draw sub levels
			len = _bmdLevels.length;
			for(i = 0; i < len; ++i) {
				_gridHolder.graphics.beginBitmapFill(_bmdLevels[i]);
				_gridHolder.graphics.drawRect(0, 0, _size*_cellSize, _size*_cellSize);
				_gridHolder.graphics.endFill();
			}
			
			//Draw the grid
			var m:Matrix = new Matrix();
			m.scale(_cellSize/16, _cellSize/16);
			len = _size*_size;
			for(i = 0; i < len; ++i) {
				py = Math.floor(i/_size);
				px = i - py*_size;
				tile = _3dView.manager.map.getTile(ox+px, oy+py, _z);
				if(tile > 0) {
					_gridHolder.graphics.beginBitmapFill(_bitmaps[tile][0], m);
					_gridHolder.graphics.drawRect(px * _cellSize, py * _cellSize, _cellSize, _cellSize);
					_gridHolder.graphics.endFill();
				}
			}
			
			_gridHolder.graphics.beginBitmapFill(_pattern);
			_gridHolder.graphics.drawRect(0, 0, _size*_cellSize+1, _size*_cellSize+1);
			_gridHolder.graphics.endFill();
			
			PosUtils.alignToRightOf(this, stage);
			_helpButton.x = 0;//_size * _cellSize - _helpButton.width;
			_helpButton.y = _size * _cellSize - _helpButton.height;
		}
		
		/**
		 * Draw the sublevels
		 */
		private function drawSubLevels():void {
			var m:Matrix = new Matrix();
			m.scale(_cellSize/16, _cellSize/16);
			var i:int, len:int, j:int, lenJ:int, ox:int, oy:int, px:int, py:int, tile:int, bmd:BitmapData, drawnCells:Object;
			ox = Math.round(-Camera3D.locX - _size * .5) + _offset.x;
			oy = Math.round(Camera3D.locY - _size * .5) + _offset.y;
			ox = MathUtils.restrict(ox, 0, _3dView.manager.map.mapSizeX - _size);
			oy = MathUtils.restrict(oy, 0, _3dView.manager.map.mapSizeY - _size);
			
			_bmdLevels = new Vector.<BitmapData>();
			drawnCells = {};
			
			len = Math.min(3, _z);
			lenJ = _size * _size;
			for(i = 0; i < len; ++i) {
				_levelsTarget.graphics.clear();
				_levelsTarget.graphics.beginFill(0, .4 - i*.12);
				for(j = 0; j < lenJ; ++j) {
					py = Math.floor(j/_size);
					px = j - py*_size;
					if(drawnCells[px+"-"+py] != undefined) continue;
					tile = _3dView.manager.map.getTile(ox+px, oy+py, _z-i-1);
					if(tile > 0) {
						drawnCells[px+"-"+py] = true;
						_levelsTarget.graphics.drawRect(px * _cellSize, py * _cellSize, _cellSize, _cellSize);
					}
				}
				bmd = new BitmapData(_size*_cellSize, _size*_cellSize, true, 0);
				bmd.draw(_levelsTarget);
				_bmdLevels.push(bmd);
			}
		}

		
		
		
		
		
		
		//__________________________________________________________ INPUT EVENTS
		
		/**
		 * Called when a key is pressed or released.
		 */
		private function keyHandler(event:KeyboardEvent):void {
			if(event.type == KeyboardEvent.KEY_DOWN) {
				_dragMode = event.keyCode == Keyboard.SPACE;
			}else if(event.keyCode == Keyboard.SPACE){
				_dragMode = false;
			}
			if(_dragMode) _oldCamPos = new Point(-1,-1);//forces the sublevels redraw
		}
		
		/**
		 * Called when mouse wheel is used
		 */
		private function mouseWheelHandler(event:MouseEvent):void {
			_z += event.delta > 0? 1 : -1;
			_z = MathUtils.restrict(_z, 0, 30);
			_oldCamPos = new Point(-1,-1);//forces the sublevels redraw
			_lastPos.x = _lastPos.y = -1;
		}
		
		/**
		 * Called when the mouse is pressed
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			_offsetDrag = new Point(mouseX, mouseY);
			_offsetOffDrag = _offset.clone();
			_pressed = true;
			enterFrameHandler();
		}
		
		/**
		 * Called when the mouse is released
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			_pressed = false;
			if(_dragMode) {
//				var ox:int, oy:int, offX:int, offY:int;
//				offX = Math.round((_offsetDrag.x - mouseX)/_cellSize);
//				offY = Math.round((_offsetDrag.y - mouseY)/_cellSize);
//				ox = Math.round(-Camera3D.locX - _size * .5) + _offset.x;
//				oy = Math.round(Camera3D.locY - _size * .5) + _offset.y;
//				ox = MathUtils.restrict(ox, 0, _3dView.manager.map.mapSizeX - _size);
//				oy = MathUtils.restrict(oy, 0, _3dView.manager.map.mapSizeY - _size);
//				if(offX < 0) offX -= ox;
//				if(offX > _3dView.manager.map.mapSizeX - _size) offX -= ox - _3dView.manager.map.mapSizeX - _size;
//				_offset.x = offX;
//				_offset.y = offY;
//				_offset.x = MathUtils.restrict(_offset.x, 0, _3dView.manager.map.mapSizeX - _size);
//				_offset.y = MathUtils.restrict(_offset.y, 0, _3dView.manager.map.mapSizeY - _size);
			}
		}
		
	}
}