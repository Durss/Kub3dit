package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.buttons.GraphicButtonKube;
	import com.muxxu.kub3dit.components.form.input.InputKube;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.engin3d.vo.Point3D;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.graphics.RotationCCWIcon;
	import com.muxxu.kub3dit.graphics.RotationCWIcon;
	import com.muxxu.kub3dit.vo.ToolTipAlign;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.pos.roundPos;

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
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author Francois
	 * @date 11 déc. 2011;
	 */
	public class SelectionPanel extends Sprite implements IToolPanel {
		
		private var _landMark:Shape;
		private var _pressed:Boolean;
		private var _lastOrigin:Point3D;
		private var _lastGridOffset:Point;
		private var _selectionOriginOffset:Point3D;
		private var _dragOffset:Point;
		private var _mousePos:Point;
		private var _selectRect:Rectangle;
		private var _copyBt:ButtonKube;
		private var _cancelBt:ButtonKube;
		private var _depth:InputKube;
		private var _depthLabel:CssTextField;
		private var _chunksManager:ChunksManager;
		private var _copyData:ByteArray;
		private var _fixedLandmark:Boolean;
		private var _levelToColor:Array;
		private var _rCwBt:GraphicButtonKube;
		private var _rCcwBt:GraphicButtonKube;
		private var _rotationLabel:CssTextField;
		private var _rotation:int;
		private var _bmd:BitmapData;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SelectionPanel</code>.
		 */
		public function SelectionPanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function set chunksManager(value:ChunksManager):void {
			_chunksManager = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get landmark():Shape {
			return _landMark;
		}

		/**
		 * @inheritDoc
		 */
		public function set eraseMode(value:Boolean):void {
		}

		/**
		 * @inheritDoc
		 */
		public function get eraseMode():Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get fixedLandmark():Boolean {
			return _fixedLandmark;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function dispose():void {
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
			if(_fixedLandmark) {
				if(_pressed) {
					_lastOrigin.x = ox;
					_lastOrigin.y = oy;
					_lastOrigin.z = oz;
					_lastGridOffset.x = gridOffset.x;
					_lastGridOffset.y = gridOffset.y;
					
					_mousePos.x = Math.floor(_landMark.mouseX);
					_mousePos.y = Math.floor(_landMark.mouseY);
					
					_selectRect.x = Math.min(_dragOffset.x, _mousePos.x);
					_selectRect.y = Math.min(_dragOffset.y, _mousePos.y);
					
					_selectRect.width = Math.max(_dragOffset.x, _mousePos.x) - _selectRect.x + 1;
					_selectRect.height = Math.max(_dragOffset.y, _mousePos.y) - _selectRect.y + 1;
					
					if(_selectRect.x != _mousePos.x) {
						_lastOrigin.x -= _selectRect.width - 1;
					}
					if(_selectRect.y != _mousePos.y) {
						_lastOrigin.y -= _selectRect.height - 1;
					}
					
					_landMark.graphics.clear();
					_landMark.graphics.beginFill(0xffffff, .4);
					_landMark.graphics.drawRect(_selectRect.x, _selectRect.y, _selectRect.width, _selectRect.height);
					_landMark.graphics.drawRect(_selectRect.x+1, _selectRect.y+1, Math.max(0, _selectRect.width-2), Math.max(0, _selectRect.height-2));
					
					_copyBt.enabled = _selectRect.width > 0 && _selectRect.height > 0;
					_copyBt.mouseEnabled = true;
				}
			}else{
//				_fixedLandmark = true;
				
				_copyData.position = 0;
				var px:int, py:int, pz:int, tile:int, reg:int;
				var w:uint = _copyData.readUnsignedInt();
				var h:uint = _copyData.readUnsignedInt();
				
				ox -= Math.floor(w*.5);
				oy -= Math.floor(h*.5);
				
				var i:int = 0;
				//past data from top left at the upper level
				while(_copyData.bytesAvailable) {
					px = i%w;
					py = Math.floor(i/w)%h;
					pz = Math.floor(i/(w*h));
					tile = _copyData.readUnsignedShort();
					
					if(pz < 0) break;
					
					if(tile > 0) {
						if(_rotation == 90) {
							reg = px;
							px = w - 1 - py;
							py = reg;
						}else 
						if(_rotation == 180) {
							reg = px;
							px = w - 1 - px;
							py = h - 1 - py;
						}else 
						if(_rotation == 270) {
							reg = px;
							px = py;
							py = h - 1 - reg;
						}
						_chunksManager.update(ox + px, oy + py, oz - pz, tile);
					}
					i++;
				}
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_landMark = new Shape();
			_lastOrigin = new Point3D();
			_lastGridOffset = new Point();
			_dragOffset = new Point();
			_mousePos = new Point();
			_selectRect = new Rectangle();
			
			_rotation = 0;
			_fixedLandmark = true;
			_levelToColor = Textures.getInstance().levelColors;
			
			_copyBt = addChild(new ButtonKube(Label.getLabel("toolConfig-selector-copy"))) as ButtonKube;
			_cancelBt = addChild(new ButtonKube(Label.getLabel("toolConfig-selector-cancel"))) as ButtonKube;
			_depth = addChild(new InputKube("", false, true, 1, Config.getNumVariable("mapSizeHeight")-1)) as InputKube;
			_depthLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_rCwBt = addChild(new GraphicButtonKube(new RotationCWIcon())) as GraphicButtonKube;
			_rCcwBt = addChild(new GraphicButtonKube(new RotationCCWIcon())) as GraphicButtonKube;
			_rotationLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			
			_rotationLabel.text = Label.getLabel("toolConfig-sandKube-rotate");
			
			_depth.text = Config.getVariable("mapSizeHeight");
			_depthLabel.text = Label.getLabel("toolConfig-selector-depth");
			_copyBt.enabled = false;
			_copyBt.mouseEnabled = true;
			
			_cancelBt.x = _copyBt.width + 5;
			_depth.x = _depthLabel.width + 5;
			_depth.y = _depthLabel.y  = _copyBt.height + 5;
			_rotationLabel.y = Math.round(_depth.y + _depth.height + 5);
			_rCcwBt.x = _rotationLabel.x + _rotationLabel.width + 10;
			_rCwBt.x = _rCcwBt.x + _rCcwBt.width + 10;
			_rCwBt.y = _rCcwBt.y = _rotationLabel.y;
			
			var i:int, len:int = numChildren;
			for(i = 0; i < len; ++i) {
				if(getChildAt(i) is Validable) Validable(getChildAt(i)).validate();
			}
			
			_depth.validate();
			
			roundPos(_cancelBt, _depth, _depthLabel);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			_copyBt.addEventListener(MouseEvent.ROLL_OVER, rollOverCopyHandler);
			
			cancel();
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		/**
		 * Updates the landmark
		 */
		private function drawLandMark():void {
			if(_bmd == null) return;
			
			var m:Matrix = new Matrix();
			m.rotate(_rotation * MathUtils.DEG2RAD);
			if(_rotation == 90) m.translate(_bmd.width, 0);
			if(_rotation == 180) m.translate(_bmd.width, _bmd.height);
			if(_rotation == 270) m.translate(0, _bmd.height);
			
			_landMark.graphics.clear();
			_landMark.graphics.beginBitmapFill(_bmd, m);
			_landMark.graphics.drawRect(0, 0, _bmd.width, _bmd.height);
		}
		
		
		
		
		//__________________________________________________________ MOUSE EVENTS
		
		/**
		 * Called when a button is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			var i:int, len:int, px:int, py:int, pz:int, depth:int, tile:int, pixelsDone:Array;
			if(event.target == _copyBt && _copyBt.enabled) {
				pixelsDone = [];
				_fixedLandmark = false;
				_copyBt.enabled = false;
				_copyBt.mouseEnabled = true;
				_depth.enabled = _rCcwBt.enabled = _rCwBt.enabled = _cancelBt.enabled = true;
				_depthLabel.alpha = _rotationLabel.alpha = 1;

				depth = Math.min(parseInt(_depth.text), _lastOrigin.z+1);
				_copyData = new ByteArray();
				_copyData.writeUnsignedInt(_selectRect.width);
				_copyData.writeUnsignedInt(_selectRect.height);
				
				_bmd = new BitmapData(_selectRect.width, _selectRect.height, true, 0);
				
				_landMark.graphics.clear();
				len = _selectRect.width * _selectRect.height * depth;
				//Copy data from top left at the upper level
				for(i = 0; i < len; ++i) {
					px = i%_selectRect.width;
					py = Math.floor(i/_selectRect.width)%_selectRect.height;
					pz = depth - Math.floor(i/(_selectRect.width*_selectRect.height)) - 1;
					
					if(pz < 0) break;
					tile = _chunksManager.map.getTile(_lastOrigin.x + px, _lastOrigin.y + py, pz);
					
					if (tile > 0 && pixelsDone[px+"_"+py] == undefined) {
						pixelsDone[px+"_"+py] = true;
						_bmd.setPixel32(px, py, _levelToColor[tile][pz]);
					}
					
					_copyData.writeShort( tile );
					drawLandMark();
				}
				
			}else if(event.target == _cancelBt) {
				cancel();
				
			}else if(event.target == _rCcwBt){
				_rotation -= 90;
				
			}else if(event.target == _rCwBt){
				_rotation += 90;
			}
			
			if(_rotation < 0) _rotation = 360 + _rotation;
			if(_rotation > 360) _rotation -= 360;
			if(event.target == _rCcwBt || event.target == _rCwBt) {
				drawLandMark();
			}
		}
		
		/**
		 * Called when a key is released
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.ESCAPE) cancel();
		}
		
		/**
		 * Stops copying
		 */
		private function cancel():void {
			_fixedLandmark = true;
			_copyData = null;
			_landMark.graphics.clear();
			_depth.enabled = _rCcwBt.enabled = _rCwBt.enabled = _cancelBt.enabled = false;
			_depthLabel.alpha = _rotationLabel.alpha = .4;
		}
		
		/**
		 * Called when a mouse event occurs.
		 */
		private function mouseEventHandler(event:MouseEvent):void {
			if(event.type == MouseEvent.MOUSE_DOWN && _fixedLandmark) {
				_dragOffset.x = Math.floor(_landMark.mouseX);
				_dragOffset.y = Math.floor(_landMark.mouseY);
				_selectionOriginOffset = _lastOrigin.clone();
				_pressed = true;
			}
			else if(event.type == MouseEvent.MOUSE_UP) {
				_pressed = false;
			}
		}
		
		/**
		 * Called when copy button is rolled over
		 */
		private function rollOverCopyHandler(event:MouseEvent):void {
			if(!_copyBt.enabled) {
				dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("toolConfig-selector-copyHelp"), ToolTipAlign.BOTTOM));
			}
		}
		
	}
}