package  
com.muxxu.kub3dit.engin3d.camera {
	import gs.TweenLite;
	import gs.TweenMax;
	import gs.easing.Linear;

	import com.muxxu.kub3dit.engin3d.chunks.ChunkData;
	import com.muxxu.kub3dit.engin3d.map.Map;

	import flash.display.Stage;
	import flash.display.StageDisplayState;
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
		public static var path:Array;
		public static var px:Number = 0;
		public static var py:Number = 0;
		public static var pz:Number = 1;
		private static var _mapWidth:Number;
		private static var _mapDepth:Number;
		private static var _mapHeight:int;
		private static var _map:Map;
		private static var _configured:Boolean;
		
		private var _stage:Stage;
		private var _lookOffset:Point = new Point();
		private var _mouseView:Boolean = false;
		private var _forward:int;
		private var _strafe:int;
		private var _spc:Boolean;
		private var _shift:Boolean;
		
		public function Camera3D(stage:Stage) 
		{
			path = [];
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
			px = data.readShort();
			py = data.readShort();
			pz = data.readShort();
			
			rotationX = data.readUnsignedInt();
			rotationY = data.readInt();
			
			_mapWidth = data.readShort();
			_mapDepth = data.readShort();
			_mapHeight = data.readShort();
			data.position -= 6;//map reads those data after camera
			_configured = true;
		}
		
		private function enterFrameHandler(e:Event):void {
			var coeff:int = _shift && _spc? 40 : _shift? 1 : _spc? 20 : 5;
			var offx:Number = _strafe * 15 * coeff;
			if(!_mouseView) {
				offx = 0;
				rotationX -= _strafe * 4;
			}
			var offy:Number = _forward * 15 * coeff;
			var dist:Number = (Math.sqrt(offx * offx + offy * offy));
//			if (rotationX<0)	rotationX+=360;
//			if (rotationX>360)	rotationX-=360;
			
			var ratio:Number = ChunkData.CUBE_SIZE_RATIO;
			var moveZ:Number = Math.cos((rotationY+90)*Math.PI/180) * 15 * _forward * coeff;
			dist -= Math.abs(moveZ);
			moveZ *= .01;
			var radians1:Number = rotationX / 180 * Math.PI;
			var radians2:Number = Math.atan2(offy, offx);
			var moveX:Number = Math.cos(radians2+radians1)*dist *.01;
			var moveY:Number = Math.sin(radians2+radians1)*dist *.01;
			px -= moveX * ratio;
			py += moveY * ratio;
			pz += moveZ * ratio;
			px = Math.min(1, Math.max(px,-_mapWidth*ratio));
			py = Math.max(-1, Math.min(py,_mapDepth*ratio));
			pz = Math.max(Math.min(pz,_mapHeight*ratio), -ratio*.3);
			
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
		
		private function onKeyDown(event:KeyboardEvent):void {
			if(event.target is TextField || event.ctrlKey) return;
			
			if(event.keyCode == Keyboard.SPACE) _spc = true;
			if(event.shiftKey || event.keyCode == Keyboard.SHIFT) _shift = true;
			if(event.keyCode == Keyboard.UP || event.keyCode == Keyboard.Z || event.keyCode == Keyboard.W) {
				_forward = 1;
			}
			if(event.keyCode == Keyboard.DOWN || event.keyCode == Keyboard.S) {
				_forward = -1;
			}
			if (event.keyCode == Keyboard.RIGHT || event.keyCode == Keyboard.D) {
				_strafe = -1;
			} else if (event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.Q || event.keyCode == Keyboard.A) {
				_strafe = 1;
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			if(e.keyCode == Keyboard.SPACE) _spc = false;
			if(e.keyCode == Keyboard.SHIFT) _shift = false;
			if(e.keyCode == Keyboard.UP || e.keyCode == Keyboard.Z || e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.S || e.keyCode == Keyboard.W) _forward = 0;
			if(e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.Q || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.D || e.keyCode == Keyboard.A) _strafe = 0;

//			if(e.keyCode == Keyboard.F4) {
//				followCurrentPath();
//			}
			if(e.keyCode == Keyboard.ESCAPE) {
				TweenLite.killTweensOf(Camera3D);
			}
		}
		
		private function mouseWheel(e:MouseEvent):void {
			if(e.target is Stage) {
				var ratio:Number = ChunkData.CUBE_SIZE_RATIO;
				pz += (e.delta > 0)? ratio : -ratio;
				pz = Math.round(pz/ratio) * ratio;
			}
		}
		
		private function mouseDown(e:MouseEvent):void {
			if(e.target is Stage) {
				_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0xffffff);
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
				
				_lookOffset.x = _stage.mouseX;
				_lookOffset.y = _stage.mouseY;
				
				_mouseView = true;
				if(_stage.displayState != StageDisplayState.NORMAL && _stage.hasOwnProperty("mouseLock")) {
					_stage["mouseLock"] = true;
					_lookOffset.x -= _stage.stageWidth*.5;
					_lookOffset.y -= _stage.stageHeight*.5;
				}
			}
		}
		
		public static function get locX():Number {
			return px;// / 1 + dy / .5
		}
		
		public static function get locY():Number {
			return py;// -dx / 1 + dy / .5
		}
		
		public static function get locZ():Number {
			return pz;// -dx / 1 + dy / .5
		}
		
		private function mouseMove(e:MouseEvent):void {
			if (_mouseView) {
				if(_stage.hasOwnProperty("mouseLock") && _stage["mouseLock"]) {
					rotationX += (e["movementX"]-_lookOffset.x) * .25;
					rotationY += (e["movementY"]-_lookOffset.y) * .25;
					_lookOffset.x = 0;
					_lookOffset.y = 0;
				}else{
					rotationX += (_stage.mouseX-_lookOffset.x) * .25;
					rotationY += (_stage.mouseY-_lookOffset.y) * .25;
					_lookOffset.x = _stage.mouseX;
					_lookOffset.y = _stage.mouseY;
				}
				rotationY = (rotationY<-90)? -90 : (rotationY>90)? 90 : rotationY;
			}
		}
		
		private function mouseUp(e:MouseEvent):void {
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			_mouseView = false;
			if(_stage.displayState != StageDisplayState.NORMAL && _stage.hasOwnProperty("mouseLock")) {
				_stage["mouseLock"] = false;
			}
		}

		public static function setPosition(vector3D:Vector3D):void {
			px = vector3D.x;
			py = vector3D.y;
			pz = vector3D.z;
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
			pz = level * ChunkData.CUBE_SIZE_RATIO;
			rotationY = 0;
		}
		
		/**
		 * Gets the current state of the camera (pos/rotation) as an anonymous object.
		 */
		public static function getCurrentStateAsObject():Object {
			return {px:px, py:py, pz:pz, rotationX:rotationX, rotationY:rotationY};
		}
		
		/**
		 * Sets the current path.
		 * 
		 * @param path	should be an array of objects returned by getCurrentStateAsObject()
		 */
		public static function setPath(value:Array):void {
			path = value;
		}
		
		/**
		 * Makes the camera 	 the current path.
		 */
		public static function followCurrentPath():void {
			if(path != null && path.length > 0) {
				px = path[0]['px'];
				py = path[0]['py'];
				pz = path[0]['pz'];
				rotationX = path[0]['rotationX'];
				rotationY = path[0]['rotationY'];
				var i:int, len:int, distance:Number, dx:Number, dy:Number, dz:Number;
				len = path.length;
				distance = 0;
				for(i = 1; i < len; ++i) {
					dx = path[i]['px'] - path[i-1]['px'];
					dy = path[i]['py'] - path[i-1]['py'];
					dz = path[i]['pz'] - path[i-1]['pz'];
					distance += Math.sqrt(dx*dx + dy*dy + dz*dz);
				}
				TweenMax.to(Camera3D, distance*.001, {bezier:path, orientToBezier:false, ease:Linear.easeNone});
				path = null;//clear triangles rendering
			}
		}
		
	}

}