package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.muxxu.kub3dit.commands.BrowseForFileCmd;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.components.buttons.GraphicButtonKube;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.graphics.FLipHorizontalIcon;
	import com.muxxu.kub3dit.graphics.FLipVerticalIcon;
	import com.muxxu.kub3dit.graphics.RotationCCWIcon;
	import com.muxxu.kub3dit.graphics.RotationCWIcon;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.math.MathUtils;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author Francois
	 * @date 11 nov. 2011;
	 */
	public class SandKubePanel extends Sprite implements IToolPanel {
		private var _chunksManager:ChunksManager;
		private var _landMark:Shape;
		private var _cmd:BrowseForFileCmd;
		private var _bmd:BitmapData;
		private var _colors:Array;
		private var _size:int;
		private var _loadBt:ButtonKube;
		private var _rotationLabel:CssTextField;
		private var _data:ByteArray;
		private var _clearBt:ButtonKube;
		private var _rCwBt:GraphicButtonKube;
		private var _rCcwBt:GraphicButtonKube;
		private var _rotation:int;
		private var _eraseMode:Boolean;
		private var _flipLabel:CssTextField;
		private var _hFlipBt:GraphicButtonKube;
		private var _vFlipBt:GraphicButtonKube;
		private var _hflipState:Boolean;
		private var _vflipState:Boolean;
		private var _lastDrawGUID:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SandKubePanel</code>.
		 */
		public function SandKubePanel() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function set eraseMode(value:Boolean):void {
			_eraseMode = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get eraseMode():Boolean {
			return _eraseMode;
		}
		
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
		public function get fixedLandmark():Boolean {
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set level(value:int):void { }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function draw(ox:int, oy:int, oz:int, kubeID:int, gridSize:int, gridOffset:Point):void {
			var drawGUID:String = ox + "" + oy + "" + oz + "" + kubeID + "" + eraseMode;
			if(drawGUID == _lastDrawGUID) return;
			_lastDrawGUID = drawGUID;
			
			if(_data == null) return;
			
			_data.position = 0;
			var i:int, px:int, py:int, pz:int, tile:int, reg:int;
			var max:int = _colors.length;
			while(_data.bytesAvailable) {
				tile = _data.readByte();
				if(tile > 0 && tile < max) {
					px = i%_size;
					py = _size - Math.floor(i/_size)%_size;
					pz = oz + Math.floor(i/(_size*_size));
					if(_rotation == 90) {
						reg = px;
						px = _size - py;
						py = reg + 1;
					}else
					if(_rotation == 180) {
						reg = px;
						px = _size - 1 - px;
						py = _size + 1 - py;
					}else
					if(_rotation == 270) {
						reg = px;
						px = py - 1;
						py = _size - reg;
					}
					
					if(_hflipState) {
						px = _size - 1 - px;
					}
					if(_vflipState) {
						py = _size + 1 - py;
					}
					
					px += ox - Math.floor(_size * .5);
					py += oy - Math.floor(_size * .5) - 1;
					
					_chunksManager.addInvalidableCube(px, py, pz, _eraseMode? 0 : tile);
				}
				
				i++;
			}
			_chunksManager.invalidate();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_size = 32;
			_landMark = new Shape();
			_colors = Textures.getInstance().levelColors;
			_bmd = new BitmapData(_size, _size, true, 0);
			
			_loadBt = addChild(new ButtonKube(Label.getLabel("toolConfig-sandKube-load"))) as ButtonKube;
			_clearBt = addChild(new ButtonKube(Label.getLabel("toolConfig-sandKube-clear"))) as ButtonKube;
			_rCwBt = addChild(new GraphicButtonKube(new RotationCWIcon())) as GraphicButtonKube;
			_rCcwBt = addChild(new GraphicButtonKube(new RotationCCWIcon())) as GraphicButtonKube;
			_rotationLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			
			_flipLabel = addChild(new CssTextField("inputToolsConfLabel")) as CssTextField;
			_hFlipBt = addChild(new GraphicButtonKube(new FLipHorizontalIcon())) as GraphicButtonKube;
			_vFlipBt = addChild(new GraphicButtonKube(new FLipVerticalIcon())) as GraphicButtonKube;
			
			_rotationLabel.text = Label.getLabel("toolConfig-sandKube-rotate");
			_flipLabel.text = Label.getLabel("toolConfig-sandKube-flip");
			
			_clearBt.x = Math.round(_loadBt.x + _loadBt.width + 5);
			_rotationLabel.y = Math.round(_clearBt.y + _clearBt.height + 5);
			_rCcwBt.x = _rotationLabel.x + Math.max(_flipLabel.width, _rotationLabel.width) + 10;
			_rCwBt.x = _rCcwBt.x + _rCcwBt.width + 10;
			_rCwBt.y = _rCcwBt.y = _rotationLabel.y;
			
			_flipLabel.y = Math.round(_rCwBt.y + _rCwBt.height + 5);
			_hFlipBt.x = _rCcwBt.x;
			_vFlipBt.x = _hFlipBt.x + _hFlipBt.width + 10;
			_vFlipBt.y = _hFlipBt.y = _flipLabel.y;
			
			var i:int, len:int = numChildren;
			for(i = 0; i < len; ++i) {
				if(getChildAt(i) is Validable) Validable(getChildAt(i)).validate();
			}
			
			_clearBt.enabled = _rCwBt.enabled = _rCcwBt.enabled = _hFlipBt.enabled = _vFlipBt.enabled = false;
			_rotationLabel.alpha = _flipLabel.alpha = .4;
			
			_cmd = new BrowseForFileCmd("Sandkube image", "*.png;*.jpg");
			_cmd.addEventListener(CommandEvent.COMPLETE, loadImageCompleteHandler);
			addEventListener(MouseEvent.CLICK, clickButtonHandler);
		}
		
		/**
		 * Called when a button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if(event.target == _loadBt ){
				_cmd.execute();
				
			}else if(event.target == _clearBt){
				_data = null;
				_landMark.graphics.clear();
				_clearBt.enabled = _rCwBt.enabled = _rCcwBt.enabled = _hFlipBt.enabled = _vFlipBt.enabled = false;
				_rotationLabel.alpha = _flipLabel.alpha = .4;
				
			}else if(event.target == _rCcwBt){
				_rotation -= 90;
				
			}else if(event.target == _rCwBt){
				_rotation += 90;
				
			}else if(event.target == _hFlipBt){
				_hflipState = !_hflipState;
				
			}else if(event.target == _vFlipBt){
				_vflipState = !_vflipState;
			}
			
			if(_rotation < 0) _rotation = 360 + _rotation;
			if(_rotation > 360) _rotation -= 360;
			drawLandMark();
		}
		
		/**
		 * Called when SandKube image loading completes.
		 */
		private function loadImageCompleteHandler(event:CommandEvent):void {
			var i:int, len:int, px:int, py:int, pz:int, tile:int;
			var ba:ByteArray = event.data as ByteArray;
			_data = new ByteArray();
			ba.position = ba.length - _size*_size*(_size-1);//-1 removes the useless sea level
			ba.readBytes(_data);
			len = _bmd.width * _bmd.height;
			_bmd.fillRect(_bmd.rect, 0);
			var max:int = _colors.length;
			for(i = 0; i < len; ++i) {
				px = i%_size;
				py = Math.floor(i/_size);
				pz = 30;
				while(pz>=0) {
					_data.position = px + py*_size + pz*_size*_size;
					tile = _data.readByte();
					if(tile > 0) {
						if(tile < max) {
							_bmd.setPixel32(px, (_size-1) - py, _colors[tile][pz]);
						}
						break;
					}
					pz--;
				}
			}
			
			_rotation = 0;
			_hflipState = false;
			_vflipState = false;
			
			drawLandMark();
			
			_clearBt.enabled = _rCwBt.enabled = _rCcwBt.enabled = _hFlipBt.enabled = _vFlipBt.enabled = true;
			_rotationLabel.alpha = _flipLabel.alpha = 1;
		}
		
		/**
		 * Draw the landmark
		 */
		private function drawLandMark():void {
			if(_data == null) return;
			
			var m:Matrix = new Matrix();
			m.rotate(_rotation * MathUtils.DEG2RAD);
			if(_rotation == 90) m.translate(_size, 0);
			if(_rotation == 180) m.translate(_size, _size);
			if(_rotation == 270) m.translate(0, _size);
			
			if(_hflipState) m.scale(-1, 1);
			if(_vflipState) m.scale(1, -1);
			
			_landMark.graphics.clear();
			_landMark.graphics.beginBitmapFill(_bmd, m);
			_landMark.graphics.drawRect(0, 0, _size, _size);
		}
		
	}
}