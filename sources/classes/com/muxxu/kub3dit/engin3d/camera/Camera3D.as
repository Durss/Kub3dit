package  
com.muxxu.kub3dit.engin3d.camera {
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.geom.Vector3D;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
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
		private static var _mapHeight:Number;
		private static var _wasd:Boolean;
		
		private var _stage:Stage;
		private var _lookOffset:Point = new Point();
		private var _mouseView:Boolean = true;
		private var _forward:int;
		private var _strafe:int;
		
		public function Camera3D(stage:Stage) 
		{
			_stage = stage;
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
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
		}
		
		private function onEnterFrame(e:Event):void {
			var offx:Number = _strafe * 15;
			if(!_mouseView) {
				offx = 0;
				rotationX -= _strafe * 4;
			}
			var offy:Number = _forward * 15;
			var dist:Number = (Math.sqrt(offx * offx + offy * offy));
			if (rotationX<0)	rotationX+=360;
			if (rotationX>360)	rotationX-=360;
				
			var moveZ:Number = Math.cos((Camera3D.rotationY+90)*Math.PI/180) * 15 * _forward;
			dist -= Math.abs(moveZ);
			var radians1:Number = rotationX / 180 * Math.PI;
			var radians2:Number = Math.atan2(offy, offx);
			var moveX:Number = Math.cos(radians2+radians1)*dist;
			var moveY:Number = Math.sin(radians2+radians1)*dist;
			_dx -= moveX * .025;
			_dy += moveY * .025;
			_dz += moveZ * .025;
			_dx = Math.min(1, Math.max(_dx,-_mapWidth));
			_dy = Math.max(-1, Math.min(_dy,_mapHeight));
//			if(_dz < 1.5) _dz = 1.5;
			_dz = Math.max(Math.min(_dz,30), 0);
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			if(e.target is TextField) return;
			
			var coeff:int = e.ctrlKey? 5 : 1;
			if(_wasd) {
				if(e.keyCode == Keyboard.UP || e.keyCode == 87) {
					_forward = 1 * coeff;
				}
				if(e.keyCode == Keyboard.DOWN || e.keyCode == 83) {
					_forward = -1 * coeff;
				}
				if (e.keyCode == Keyboard.RIGHT || e.keyCode == 68) {
					_strafe = -1 * coeff;
				} else if (e.keyCode == Keyboard.LEFT || e.keyCode == 65) {
					_strafe = 1 * coeff;
				}
			}else{
				if(e.keyCode == Keyboard.UP || e.keyCode == Keyboard.Z) {
					_forward = 1 * coeff;
				}
				if(e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.S) {
					_forward = -1 * coeff;
				}
				if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D) {
					_strafe = -1 * coeff;
				} else if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.Q) {
					_strafe = 1 * coeff;
				}
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			if(_wasd) {
				if (e.keyCode == Keyboard.UP || e.keyCode == 87 || e.keyCode == Keyboard.DOWN || e.keyCode == 83) _forward = 0;
				if (e.keyCode == Keyboard.RIGHT || e.keyCode == 65 || e.keyCode == Keyboard.LEFT || e.keyCode == 68) _strafe = 0;
			}else{
				if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.Z || e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.S) _forward = 0;
				if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.Q || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.D) _strafe = 0;
			}
		}
		
		private function mouseWheel(e:MouseEvent):void {
			if(e.target is Stage) {
				_dz += (e.delta > 0)? 1 : -1;
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

		public static function setMapSize(width:Number, height:Number):void {
			_mapWidth = width;
			_mapHeight = height;
		}

		public static function moveZTo(level:Number):void {
			_dz = level;
			rotationY = 0;
		}

		public static function toggleWASD():void {
			_wasd = !_wasd;
		}
		
	}

}