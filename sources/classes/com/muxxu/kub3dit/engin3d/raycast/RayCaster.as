package com.muxxu.kub3dit.engin3d.raycast {
	import flash.geom.Point;
	import com.muxxu.kub3dit.engin3d.chunks.ChunkData;
	import com.muxxu.kub3dit.engin3d.map.Map;

	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Colapsydo
	 */
	public class RayCaster extends EventDispatcher 
	{
		private var _map:Map;
		
		private var _distanceMax:int;
		private var _testedPoint:Vector3D;	
		private var _lastTestedKube:Vector3D;
		private var _actualTestedKube:Vector3D;
		private var _collision:Boolean;
		private var _cubeSize:Number;
		
		public function RayCaster(map:Map):void {
			_map = map;
			init();
		}
		
		private function init():void {
			_cubeSize = ChunkData.CUBE_SIZE;
			_testedPoint = new Vector3D();
			_lastTestedKube = new Vector3D();
			_actualTestedKube = new Vector3D();
			_distanceMax = 15; //15 is quite high value (6 which is the Kube normal value is a bit short)
		}
		
		//PRIVATE FUNCTIONS
		
		private function identifyKube(position:Vector3D, kubeTested:Vector3D):void {
			//TEST TO DETERMINE WHICH TILE IS TESTED
			var loc:Vector3D = new Vector3D();
			loc.x = ( -(position.x - _cubeSize * 0.5) / _cubeSize) >> 0;
			loc.y = ((position.y +_cubeSize * 0.5) / _cubeSize) >> 0;
			loc.z = ((position.z + _cubeSize * 0.5) / _cubeSize) >> 0;
			if (position.z < -_cubeSize * 0.5) { loc.z = -1; }
			
			//Writing value of tile coordinates
			kubeTested.x = loc.x;
			kubeTested.y = loc.y;
			kubeTested.z = loc.z;
		}
		
		private function isAkube(position:Vector3D):Boolean {
			//TESTING IF THE KUBE TESTED IS ON OR OFF
			if (_map.getTile(position.x, position.y, position.z) > 0 || position.z<0) {
				return(true);
			}
			return(false);
		}
		
		
		//PUBLIC FUNCTIONS
		
		public function cast(cameraPosition:Vector3D, rayPoint:Point, rotZdeg:Number, rotXdeg:Number, projectionMatrix:Matrix3D):Boolean {
			//RXdurss = rotZdeg, RYdurss = rotXdeg
			_collision = false;
			
			//INVERSION FROM SCREEN TO WORLD
			var normalizedVect:Vector3D = new Vector3D(rayPoint.x, rayPoint.y, 0,0); //POINT ON SCREEN axeX[-1,1] , axeY[-1,1]
//			var normalizedVect:Vector3D = new Vector3D(((_stage.mouseX - _stage.stageWidth * 0.5) / _stage.stageWidth) *2, ((_stage.mouseY - _stage.stageHeight * 0.5) / _stage.stageHeight) *2, 0,0); //POINT ON SCREEN axeX[-1,1] , axeY[-1,1]
	
//			var projectionMatrix:Matrix3D = Stage3DView.getProjectionMatrix(_stage.stageWidth & ~1, _stage.stageHeight & ~1); // CLIP TO VIEW : Applying inverted projection (screen == clip assumed)
			projectionMatrix.invert();
			normalizedVect = projectionMatrix.transformVector(normalizedVect);
			
			var matrixCamera:Matrix3D = new Matrix3D(Vector.<Number>([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0])); //VIEW TO WORLD
			matrixCamera.appendRotation(90, Vector3D.X_AXIS);
			matrixCamera.appendRotation(rotZdeg, Vector3D.Y_AXIS);
			matrixCamera.appendRotation(rotXdeg, Vector3D.X_AXIS); // sign inversion resp Stage3DView Matrix
			matrixCamera.transpose();
			
			normalizedVect = matrixCamera.transformVector(normalizedVect);
			normalizedVect.x = - normalizedVect.x; //correciton due to inversion in 3Dengine
			normalizedVect.normalize();
			
			//INITIALIZATION WITH TEST OF THE INIT POSITION
			_testedPoint.x = cameraPosition.x;
			_testedPoint.y = cameraPosition.y;
			_testedPoint.z = cameraPosition.z;
			identifyKube(_testedPoint, _actualTestedKube);
			
			if (isAkube(_actualTestedKube)) { //COLLISION TEST (not sure of the validity of the test)
				_collision = true;
				return(true);
			}
			
			if (_lastTestedKube == null) { _lastTestedKube = new Vector3D();} //Defining last tested kube
			_lastTestedKube.x = _actualTestedKube.x;
			_lastTestedKube.y = _actualTestedKube.y;
			_lastTestedKube.z = _actualTestedKube.z;
			
			//CASTING RAY FORM CAMERA
			var i:int = _distanceMax *  _cubeSize; //The highest _ratio the better the precision but also the highest the iteration num
			while (--i) {
				_testedPoint.incrementBy(normalizedVect); //updating the ray
				identifyKube(_testedPoint, _actualTestedKube); // identifying the tile
				
				if (_lastTestedKube != _actualTestedKube) { //if tile is different
					identifyKube(_testedPoint.subtract(normalizedVect),_lastTestedKube); //Last kube is the last empty kube crossed by the ray
					if (isAkube(_actualTestedKube)) { return(true);} //testing the actual tile
				}
			}
			_lastTestedKube = null; // if no solid kube encountered last kube should be put to null
			return(false);
		}
		
		//GETTERS && SETTERS
		
		public function get actualKube():Vector3D { return(_actualTestedKube); }
		public function get lastKube():Vector3D { return(_lastTestedKube); }
		public function get cameraColliding():Boolean { return(_collision); }
		
	}
	
}