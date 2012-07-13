package com.muxxu.kub3dit.components.editor {
	import com.muxxu.kub3dit.engin3d.events.ManagerEvent;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.kub3dit.engin3d.chunks.ChunkData;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.editor.toolpanels.IToolPanel;
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.events.LightModelEvent;
	import com.muxxu.kub3dit.graphics.GridPattern;
	import com.muxxu.kub3dit.graphics.LookAtgraphic;
	import com.muxxu.kub3dit.graphics.RadarIcon;
	import com.muxxu.kub3dit.views.Stage3DView;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.math.MathUtils;

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
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.getTimer;
	
	
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class Grid extends Sprite {

		private var _3dView:Stage3DView;
		private var _size:int;
		private var _pattern:BitmapData;
		private var _bitmaps:Array;
		private var _pressed:Boolean;
		private var _currentKube:String;
		private var _lastPos:Point;
		private var _lookAt:LookAtgraphic;
		private var _z:int;
		private var _oldCamPos:Point;
		private var _lastStartTime:int;
		private var _subLevelsDrawn:Boolean;
		private var _cellSize:int;
		private var _dragMode:Boolean;
		private var _offsetDrag:Point;
		private var _offset:Point;
		private var _offsetOffDrag:Point;
		private var _panel:IToolPanel;
		private var _landMark:Sprite;
		private var _levelSlider:LevelsSlider;
		private var _gridHolder:Sprite;
		private var _colors:Array;
		private var _bmdGrid:BitmapData;
		private var _levelsTarget:BitmapData;
		private var _map:Map;
		private var _radarBt:ButtonKube;
		private var _lastOrigin:Point;
		private var _radarMode:Boolean;
		private var _globalMousePos:Point3D;
		private var _mousePos:Point;
		private var _scaleMatrix:Matrix;
		private var _tmpPoint:Point;
		private var _ox:int;
		private var _oy:int;
		private var _displayCoords:Boolean;
		private var _over:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Grid</code>.
		 */
		public function Grid(mousePos:Point3D) {
			_globalMousePos = mousePos;
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the current kube ID
		 */
		public function set currentKube(currentKube:String):void { _currentKube = currentKube; }
		
		override public function get width():Number { return _size * _cellSize * _gridHolder.scaleX; }
		
		override public function get height():Number { return _levelSlider.y + _levelSlider.height; }
		
		/**
		 * Sets the current panel used to configure the drawing draw
		 */
		public function set currentPanel(value:IToolPanel):void {
			_panel = value;
			_panel.chunksManager = _3dView.manager;
			_panel.level = _z;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Sets the map's reference
		 */
		public function setMap(map:Map):void {
			_map = map;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			var src:GridPattern = new GridPattern();
			_pattern = new BitmapData(src.width, src.height, true, 0);
			_pattern.draw(src);
			
			_size = 32*2;
			_cellSize = 6;
			_lastPos = new Point(-1,-1);
			_oldCamPos = new Point(-1,-1);
			_offset = new Point(0,0);
			_lastOrigin = new Point();
			_mousePos = new Point();
			_tmpPoint = new Point();
			_scaleMatrix = new Matrix();
			_scaleMatrix.scale(_cellSize, _cellSize);
			
			_3dView = ViewLocator.getInstance().locateViewByType(Stage3DView) as Stage3DView;
			
			_gridHolder = addChild(new Sprite()) as Sprite;
			_landMark = _gridHolder.addChild(new Sprite()) as Sprite;
			_lookAt = _gridHolder.addChild(new LookAtgraphic()) as LookAtgraphic;
			_levelSlider = addChild(new LevelsSlider()) as LevelsSlider;
			_radarBt = addChild(new ButtonKube(Label.getLabel("drawFullRadar"), false, new RadarIcon())) as ButtonKube;
			
			_bmdGrid = new BitmapData(_size*_cellSize, _size*_cellSize, true, 0);
			_levelsTarget = _bmdGrid.clone();
			
			computePositions();
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
			_levelSlider.addEventListener(Event.CHANGE, changeLevelHandler);
			_gridHolder.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_radarBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			ViewLocator.getInstance().addEventListener(LightModelEvent.KUBE_SELECTION_CHANGE, kubeSelectionChangeHandler);
			_3dView.manager.addEventListener(ManagerEvent.INTERNAL_UPDATE, updateMapRendering);
			addEventListener(MouseEvent.ROLL_OVER, rollHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollHandler);
			
			_gridHolder.scrollRect = new Rectangle(0,0,_size*_cellSize,_size*_cellSize);
		}
		
		/**
		 * Called when the grid is rolled over/out
		 */
		private function rollHandler(event:MouseEvent):void {
			_over = event.type == MouseEvent.ROLL_OVER;
		}
		
		/**
		 * Forces grid's rendering when a map update is made by something else
		 * thand this view (selection cut, CTRL+Z, CTRL+Y)
		 */
		private function updateMapRendering(event:Event = null):void {
			_subLevelsDrawn = false;
		}
		
		/**
		 * Replaces the elements
		 */
		private function computePositions():void {
			_levelSlider.y = _size * _cellSize * _gridHolder.scaleY + 5;
			_levelSlider.width = _size * _cellSize * _gridHolder.scaleX;
			_z = _levelSlider.level;
			_radarBt.height = 15;
			_radarBt.x = Math.round(_levelSlider.width - _radarBt.width);
			_radarBt.y = _levelSlider.y + 22;
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/**
		 * Called when a new kube is selected
		 */
		private function kubeSelectionChangeHandler(event:LightModelEvent):void {
			_currentKube = event.data as String;
		}
		
		/**
		 * Called on ENTER_FRAME event to render the grid
		 */
		private function enterFrameHandler(event:Event = null):void {
			if(_3dView == null || _3dView.manager == null || _map == null) return;
			_bitmaps = Textures.getInstance().bitmapDatas;
			_colors = Textures.getInstance().levelColors;

			
			//Drag management
			if(_dragMode && _pressed) {
				_offset.x = Math.round((_offsetDrag.x - _gridHolder.mouseX)/_cellSize) + _offsetOffDrag.x;
				_offset.y = Math.round((_offsetDrag.y - _gridHolder.mouseY)/_cellSize) + _offsetOffDrag.y;
			}
			_ox = Math.round(-Camera3D.locX / ChunkData.CUBE_SIZE_RATIO - _size * .5) + _offset.x;
			_oy = Math.round(Camera3D.locY / ChunkData.CUBE_SIZE_RATIO - _size * .5) + _offset.y;
			//Limit drag
			if(_ox < -_size*.5) _offset.x -= _ox+_size*.5;
			if(_oy < -_size*.5) _offset.y -= _oy+_size*.5;
			if(_ox > _map.mapSizeX - _size*.5) _offset.x -= _ox - (_map.mapSizeX - _size*.5);
			if(_oy > _map.mapSizeY - _size*.5) _offset.y -= _oy - (_map.mapSizeY - _size*.5);
			//limit global offset
			_ox = MathUtils.restrict(_ox, -_size * .5, _map.mapSizeX - _size*.5);
			_oy = MathUtils.restrict(_oy, -_size * .5, _map.mapSizeY - _size*.5);
			
			_lastOrigin.x = _ox;
			_lastOrigin.y = _oy;
			
			//Draw the water
			_gridHolder.graphics.clear();
			_gridHolder.graphics.beginFill(0x80c7db);
			_gridHolder.graphics.drawRect(0, 0, _size*_cellSize+1, _size*_cellSize+1);
			_gridHolder.graphics.endFill();
			
			//Sub levels drawing management
			_tmpPoint.x = Camera3D.locX / ChunkData.CUBE_SIZE_RATIO;
			_tmpPoint.y = Camera3D.locY / ChunkData.CUBE_SIZE_RATIO;
			if(!_tmpPoint.equals(_oldCamPos) || _dragMode) {
				_oldCamPos = _tmpPoint.clone();
				_radarMode = false;
				_subLevelsDrawn = false;
				_lastStartTime = getTimer();
			}
			
			//Draw landmark over the grid
			if(_panel != null) {
				if(_landMark.numChildren > 0) _landMark.removeChildAt(0);
				var landmark:Shape = _panel.landmark;
				if(landmark != null) {
					_landMark.addChild(landmark);
					landmark.scaleX = landmark.scaleY = _cellSize;
					if(!_panel.fixedLandmark) {
						landmark.x = Math.floor( ((_gridHolder.mouseX) / _cellSize) - Math.floor((landmark.width * .5) / _cellSize))*_cellSize;
						landmark.y = Math.floor( ((_gridHolder.mouseY) / _cellSize) - Math.floor((landmark.height * .5) / _cellSize))*_cellSize;
					}else{
						landmark.x = landmark.y = 0;
					}
				}
			}
			
			//Look at target orientation
			_lookAt.x = _size * .5 * _cellSize - _offset.x * _cellSize + _cellSize*.5;
			_lookAt.y = _size * .5 * _cellSize - _offset.y * _cellSize + _cellSize*.5;
			_lookAt.rotation = Camera3D.rotationX;
			
			//DRAWING MANAGEMENT
			if(_over) {
				_mousePos.x = Math.floor(_gridHolder.mouseX/_cellSize);
				_mousePos.y = Math.floor(_gridHolder.mouseY/_cellSize);
				_globalMousePos.x = _ox + _mousePos.x;
				_globalMousePos.y = _oy + _mousePos.y;
				_globalMousePos.z = _z;
			}else{
				_mousePos.x = _mousePos.y = -1;
				_globalMousePos.x = -1;
				_globalMousePos.y = -1;
				_globalMousePos.z = -1;
			}
			
			//If user's drawing
			if(_pressed && !_dragMode && _mousePos.x > -1) {
				_lastPos = _mousePos;
				_tmpPoint.x = _ox;
				_tmpPoint.y = _oy;
				_panel.draw(_ox+_mousePos.x, _oy+_mousePos.y, _z, parseInt(_currentKube), _size, _tmpPoint);
				if(_panel.eraseMode) {
					_lastStartTime = getTimer();
					_subLevelsDrawn = false;
				}
				_radarMode = false;
			}
			
			//Draw the grid
			//If we didn't moved from Xms and if the sublevels aren't drawn, then draw them
			if(getTimer() - _lastStartTime > 100) {
				//If sublevels haven't been drawn yet since last action that needed it, draw them
				if(!_subLevelsDrawn) {
					_subLevelsDrawn = true;
					drawGridBase(_ox, _oy);
					drawSubLevels(_ox, _oy, _z-1);
				}
				if(!_radarMode) drawLevel(_ox, _oy, _z, 1);
			}else{
				drawGridBase(_ox, _oy);
				drawLevel(_ox, _oy, _z, 1);
			}
			
			_gridHolder.graphics.beginBitmapFill(_bmdGrid, _scaleMatrix);
			_gridHolder.graphics.drawRect(0, 0, _size*_cellSize+1, _size*_cellSize+1);
			_gridHolder.graphics.endFill();
			
			var m:Matrix = new Matrix();
			m.translate(-_ox * _cellSize, -_oy * _cellSize);
			_gridHolder.graphics.beginBitmapFill(_pattern, m);
			_gridHolder.graphics.drawRect(0, 0, _size*_cellSize+1, _size*_cellSize+1);
			_gridHolder.graphics.endFill();
			
			if(_displayCoords) {
				dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, (_ox-_map.mapSizeX*.5+_mousePos.x)+","+(_oy-_map.mapSizeY*.5+_mousePos.y)));
			}
		}
		
		/**
		 * Draws the base of the grid (water and disable zone)
		 */
		private function drawGridBase(ox:int, oy:int):void {
			//draw disable zone
			_bmdGrid.fillRect(_bmdGrid.rect, 0x55000000);
			//draw enabled zone depending on the offsets
			var rect:Rectangle = new Rectangle();
			rect.x = ox <0? -ox : 0;
			rect.y = oy <0? -oy : 0;
			rect.width = Math.min(_size,  Math.min(_map.mapSizeX, _map.mapSizeX-ox));
			rect.height = Math.min(_size, Math.min(_map.mapSizeY, _map.mapSizeY-oy));
			_bmdGrid.fillRect(rect, 0);
		}
		
		/**
		 * Draw one single grid's level
		 */
		public function drawLevel(ox:int, oy:int, oz:int, alpha:Number = 1):void {
			if(oz < 0) return;
			
			var i:int, len:int, px:int, py:int, tile:int;
			len = _size * _size;
			for(i = 0; i < len; ++i) {
				py = Math.floor(i/_size);
				px = i - py*_size;
				tile = _map.getTile(ox+px, oy+py, oz);
				if(tile > 0 && tile != 61) {
					_bmdGrid.setPixel32(px, py, ((alpha*0xff) << 24) + (_colors[tile][oz] & 0xffffff));
				}
			}
		}
		
		/**
		 * Draw the sublevels
		 */
		private function drawSubLevels(ox:int, oy:int, oz:int):void {
			var i:int, len:int;
			len = Math.min(3, oz + 1);
			var alphaStep:Number = .5 / len;
			for(i = len; i >= 0; --i) {
				drawLevel(ox, oy, oz-i, .6 - i*alphaStep);
			}
		}

		
		
		
		
		
		
		//__________________________________________________________ INPUT EVENTS
		
		/**
		 * Called when a key is pressed or released.
		 */
		private function keyHandler(event:KeyboardEvent):void {
			if(event.type == KeyboardEvent.KEY_DOWN) {
				_dragMode = event.keyCode == Keyboard.SPACE;
				if(_dragMode && _over) {
					Mouse.cursor = MouseCursor.HAND;
				}
				//Coords tooltip
				if (event.keyCode == Keyboard.CONTROL) {
					if(_gridHolder.mouseX >= 0 && _gridHolder.mouseY >= 0 && _gridHolder.mouseX < _size*_cellSize && _gridHolder.mouseY < _size*_cellSize) {
						_displayCoords = true;
					}
				}
			}else {
				if(event.keyCode == Keyboard.SPACE){
					_dragMode = false;
					Mouse.cursor = MouseCursor.AUTO;
				}
				if (event.keyCode == Keyboard.CONTROL) {
					_displayCoords = false;
					dispatchEvent(new ToolTipEvent(ToolTipEvent.CLOSE));
				}
			}
			if(_dragMode) _oldCamPos = new Point(-1,-1);//forces the sublevels redraw
		}
		
		/**
		 * Called when mouse wheel is used
		 */
		private function mouseWheelHandler(event:MouseEvent):void {
			if(event.shiftKey) {
				_gridHolder.scaleX = _gridHolder.scaleY = MathUtils.restrict(_gridHolder.scaleX+MathUtils.sign(event.delta)*.25, 1, 1.5);
				computePositions();
			}else{
				_z += event.delta > 0? 1 : -1;
				_z = MathUtils.restrict(_z, 0, Config.getNumVariable("mapSizeHeight")-1);
				_oldCamPos = new Point(-1,-1);//forces the sublevels redraw
				_lastPos.x = _lastPos.y = -1;
				_levelSlider.level = _z;
				if(_panel != null) _panel.level = _z;
			}
		}
		
		/**
		 * Called when the mouse is pressed
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			_offsetDrag = new Point(_gridHolder.mouseX, _gridHolder.mouseY);
			_offsetOffDrag = _offset.clone();
			_pressed = true;
			enterFrameHandler();
		}
		
		/**
		 * Called when the mouse is released
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			_pressed = false;
			FrontControler.getInstance().saveHistory();
		}
		
		/**
		 * Called when a button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if(event.currentTarget == _radarBt) {
				var i:int, len:int;
				len = Config.getNumVariable("mapSizeHeight");
				for(i = 0; i < len; ++i) {
					drawLevel(_lastOrigin.x, _lastOrigin.y, i);
				}
				_radarMode = true;//Prevents from drawing the current level over the radar rendering.
			}
		}
		
		/**
		 * Called when changing level from slider
		 */
		private function changeLevelHandler(event:Event):void {
			_z = _levelSlider.level;
			_oldCamPos = new Point(-1,-1);//forces the sublevels redraw
			_lastPos.x = _lastPos.y = -1;
			if(_panel != null) _panel.level = _z;
		}
		
	}
}