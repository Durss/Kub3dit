package com.muxxu.kub3dit.components.editor.toolpanels {
	import com.nurun.utils.math.MathUtils;
	import flash.geom.Matrix;
	import com.muxxu.kub3dit.graphics.RotationCCWIcon;
	import com.muxxu.kub3dit.graphics.RotationCWIcon;
	import com.muxxu.kub3dit.components.buttons.GraphicButtonKube;
	import com.muxxu.kub3dit.commands.BrowseForFileCmd;
	import com.muxxu.kub3dit.components.buttons.ButtonKube;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
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
						px = _size - 1 - py;
						py = reg;
					}
					if(_rotation == 180) {
						reg = px;
						px = _size - 1 - px;
						py = _size - 1 - py;
					}
					if(_rotation == 270) {
						reg = px;
						px = py;
						py = _size - 1 - reg;
					}
					
					px += ox - _size * .5;
					py += oy - _size * .5;
					
					_chunksManager.update(px, py, pz, tile);
				}
				
				i++;
			}
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
			
			_rotationLabel.text = Label.getLabel("toolConfig-sandKube-rotate");
			
			_clearBt.x = Math.round(_loadBt.x + _loadBt.width + 5);
			_rotationLabel.y = Math.round(_clearBt.y + _clearBt.height + 5);
			_rCcwBt.x = _rotationLabel.x + _rotationLabel.width + 10;
			_rCwBt.x = _rCcwBt.x + _rCcwBt.width + 10;
			_rCwBt.y = _rCcwBt.y = _rotationLabel.y;
			
			_clearBt.enabled = _rCwBt.enabled = _rCcwBt.enabled = false;
			_rotationLabel.alpha = .4;
			
			_cmd = new BrowseForFileCmd("Sandkube image", "*.png;*.jpg");
			_cmd.addEventListener(CommandEvent.COMPLETE, loadImageCompleteHandler);
			_rCwBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_rCcwBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_clearBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_loadBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
		}
		
		/**
		 * Called when a button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if(event.currentTarget == _loadBt ){
				_cmd.execute();
				
			}else if(event.currentTarget == _clearBt){
				_data = null;
				_landMark.graphics.clear();
				_clearBt.enabled = _rCwBt.enabled = _rCcwBt.enabled = false;
				_rotationLabel.alpha = .4;
				
			}else if(event.currentTarget == _rCcwBt){
				_rotation -= 90;
				
			}else if(event.currentTarget == _rCwBt){
				_rotation += 90;
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
			
			drawLandMark();
			
			_clearBt.enabled = _rCwBt.enabled = _rCcwBt.enabled = true;
			_rotationLabel.alpha = 1;
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
			
			_landMark.graphics.clear();
			_landMark.graphics.beginBitmapFill(_bmd, m);
			_landMark.graphics.drawRect(0, 0, _size, _size);
		}
		
	}
}