package  
com.muxxu.kub3dit.engin3d.camera {
	import com.muxxu.kub3dit.engin3d.chunks.ChunkData;
	import com.muxxu.kub3dit.engin3d.map.Map;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author andre
	 */
	public class Camera3D 
	{
		public static var rotationX:Number = 0;
		public static var rotationY:Number = 0;
		private static var _dx:Number = 0;
		private static var _dy:Number = 0;
		private static var _dz:Number = 1;
		private static var _mapWidth:Number;
		private static var _mapDepth:Number;
		private static var _mapHeight:int;
		private static var _map:Map;
		private static var _configured:Boolean;
		
		private var _stage:Stage;
		private var _lookOffset:Point = new Point();
		private var _mouseView:Boolean = true;
		private var _forward:int;
		private var _strafe:int;
		private var _ctrl:Boolean;
		private var _shift:Boolean;
		
		public function Camera3D(stage:Stage) 
		{
			_stage = stage;
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			_stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
		}
		
		/**
		 * Configures the camera from a byteArray
		 */
		public static function configure(data:ByteArray):void {
			_dx = data.readShort();
			_dy = data.readShort();
			_dz = data.readShort();
			
			rotationX = data.readUnsignedInt();
			rotationY = data.readInt();
			
			_mapWidth = data.readShort();
			_mapDepth = data.readShort();
			_mapHeight = data.readShort();
			data.position -= 6;//map reads those data after camera
			_configured = true;
		}
		
		private function enterFrameHandler(e:Event):void {
			var coeff:int = _shift? 20 : _ctrl? 10 : 1;
			var offx:Number = _strafe * 15 * coeff;
			if(!_mouseView) {
				offx = 0;
				rotationX -= _strafe * 4;
			}
			var offy:Number = _forward * 15 * coeff;
			var dist:Number = (Math.sqrt(offx * offx + offy * offy));
			if (rotationX<0)	rotationX+=360;
			if (rotationX>360)	rotationX-=360;
			
			var ratio:Number = ChunkData.CUBE_SIZE_RATIO;
			var moveZ:Number = Math.cos((Camera3D.rotationY+90)*Math.PI/180) * 15 * _forward * coeff;
			dist -= Math.abs(moveZ);
			moveZ *= .01;
			var radians1:Number = rotationX / 180 * Math.PI;
			var radians2:Number = Math.atan2(offy, offx);
			var moveX:Number = Math.cos(radians2+radians1)*dist *.01;
			var moveY:Number = Math.sin(radians2+radians1)*dist *.01;
			_dx -= moveX * ratio;
			_dy += moveY * ratio;
			_dz += moveZ * ratio;
			_dx = Math.min(1, Math.max(_dx,-_mapWidth*ratio));
			_dy = Math.max(-1, Math.min(_dy,_mapDepth*ratio));
			_dz = Math.max(Math.min(_dz,_mapHeight*ratio), -ratio*.3);
			
			//dirty collision detection attempt
//			var px:Number, py:Number, pz:Number;
//			px = _dx - moveX*ratio*2;
//			py = _dy + moveY*ratio*2;
//			pz = _dz + moveZ*ratio*2;
//			while(_map.getTile(-px/ratio, py/ratio, pz/ratio) > 0) {
//				px += moveX*ratio*2;
//				py -= moveY*ratio*2;
//				pz -= moveZ*ratio*2;
//				_dx = px;// - ratio * .5;
//				_dy = py;// + ratio * .5;
//				_dz = pz;// + ratio * .5;
//			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			if(e.target is TextField) return;
			
			_ctrl = e.ctrlKey;
			_shift = e.shiftKey;
			if(e.keyCode == Keyboard.UP || e.keyCode == Keyboard.Z || e.keyCode == Keyboard.W) {
				_forward = 1;
			}
			if(e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.S) {
				_forward = -1;
			}
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D) {
				_strafe = -1;
			} else if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.Q || e.keyCode == Keyboard.A) {
				_strafe = 1;
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.Z || e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.S || e.keyCode == Keyboard.W) _forward = 0;
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.Q || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.D || e.keyCode == Keyboard.A) _strafe = 0;
		}
		
		private function mouseWheel(e:MouseEvent):void {
			if(e.target is Stage) {
				var ratio:Number = ChunkData.CUBE_SIZE_RATIO;
				_dz += (e.delta > 0)? ratio : -ratio;
				_dz = Math.round(_dz/ratio) * ratio;
			}
		}
		
		private function mouseDown(e:MouseEvent):void {
			if(e.target is Stage) {
				_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
				
				_lookOffset.x = _stage.mouseX;
				_lookOffset.y = _stage.mouseY;
				
				_mouseView = true;
			}
		}
		
		public static function get locX():Number {
			return _dx;// / 1 + dy / .5
		}
		
		public static function get locY():Number {
			return _dy;// -dx / 1 + dy / .5
		}
		
		public static function get locZ():Number {
			return _dz;// -dx / 1 + dy / .5
		}
		
		private function mouseMove(e:MouseEvent):void {
			if (_mouseView) {
				rotationX += (_stage.mouseX-_lookOffset.x) * .15;
				rotationY += (_stage.mouseY-_lookOffset.y) * .15;
				_lookOffset.x = _stage.mouseX;
				_lookOffset.y = _stage.mouseY;
				rotationY = (rotationY<-90)? -90 : (rotationY>90)? 90 : rotationY;
			}
		}
		
		private function mouseUp(e:MouseEvent):void {
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			_mouseView = false;
		}

		public static function setPosition(vector3D:Vector3D):void {
			_dx = vector3D.x;
			_dy = vector3D.y;
			_dz = vector3D.z;
		}

		public static function setMap(map:Map):void {
			_map = map;
			_mapWidth = _map.mapSizeX;
			_mapDepth = _map.mapSizeY;
			_mapHeight = _map.mapSizeZ;
			
			if(!_configured) {
				setPosition(new Vector3D(-_map.mapSizeX*.5 * ChunkData.CUBE_SIZE_RATIO,_map.mapSizeY*.5 * ChunkData.CUBE_SIZE_RATIO, 2 * ChunkData.CUBE_SIZE_RATIO));
				rotationX = 0;
			}
		}

		public static function moveZTo(level:Number):void {
			_dz = level * ChunkData.CUBE_SIZE_RATIO;
			rotationY = 0;
		}
		
	}

}