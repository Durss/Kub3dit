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
	 * optimized with DDA
	 */
	public class RayCaster extends EventDispatcher 
	{
		private var _map:Map;
		
		private var _mapPosX:int;
		private var _mapPosY:int;
		private var _mapPosZ:int;
		private var _mapStepX:int;
		private var _mapStepY:int;
		private var _mapStepZ:int;
		private var _cellEdgeX:Number;
		private var _cellEdgeY:Number;
		private var _cellEdgeZ:Number;
		private var _cellOffsetX:Number;
		private var _cellOffsetY:Number;
		private var _cellOffsetZ:Number;
		
		private var _distanceMax:int;
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
			_lastTestedKube = new Vector3D();
			_actualTestedKube = new Vector3D();
			_distanceMax = 2s5; //15 is quite high value (6 which is the Kube normal value is a bit short)
		}
		
		//PRIVATE FUNCTIONS
		
		private function identifyKube(position:Vector3D, kubeTested:Vector3D):void {
			//TEST TO DETERMINE WHICH TILE IS TESTED
			var locX:int = 0;
			var locY:int = 0;
			var locZ:int = 0;
			locX = ( -(position.x - _cubeSize * 0.5) / _cubeSize) >> 0;
			locY = ((position.y +_cubeSize * 0.5) / _cubeSize) >> 0;
			locZ = position.z < -_cubeSize * 0.5 ? -1 : ((position.z + _cubeSize * 0.5) / _cubeSize) >> 0;
			
			//Writing value of tile coordinates
			kubeTested.x = locX;
			kubeTested.y = locY;
			kubeTested.z = locZ;
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
	
			projectionMatrix.invert(); // CLIP TO VIEW : Applying inverted projection (screen == clip assumed)
			normalizedVect = projectionMatrix.transformVector(normalizedVect);
			
			var matrixCamera:Matrix3D = new Matrix3D(Vector.<Number>([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0])); //VIEW TO WORLD
			matrixCamera.appendRotation(90, Vector3D.X_AXIS);
			matrixCamera.appendRotation(rotZdeg, Vector3D.Y_AXIS);
			matrixCamera.appendRotation(rotXdeg, Vector3D.X_AXIS); // sign inversion resp Stage3DView Matrix
			matrixCamera.transpose();
			
			normalizedVect = matrixCamera.transformVector(normalizedVect);
			normalizedVect.normalize();
		//sign inversion not needed anymore
			//normalizedVect.x = - normalizedVect.x; //correciton due to inversion in 3Dengine
			
			
			//INITIALIZATION WITH TEST OF THE INIT POSITION
			identifyKube(cameraPosition, _actualTestedKube);
			
			if (isAkube(_actualTestedKube)) { //COLLISION TEST (not sure of the validity of the test)
				_collision = true;
				return(true);
			}
			
			if (_lastTestedKube == null) { _lastTestedKube = new Vector3D();} //Defining last tested kube
			_lastTestedKube.x = _actualTestedKube.x;
			_lastTestedKube.y = _actualTestedKube.y;
			_lastTestedKube.z = _actualTestedKube.z;
			
			//INITIALIZATION OF THE DDA VARS
			_mapPosX = _actualTestedKube.x >> 0;
			_mapPosY = _actualTestedKube.y >> 0;
			_mapPosZ = _actualTestedKube.z >> 0;
			
			_cellOffsetX = 1 / normalizedVect.x; //1 is the cell size along X, here we take a unit cell
			_cellOffsetY = 1 / normalizedVect.y; //resp. Y
			_cellOffsetZ = 1 / normalizedVect.z; //resp. Z
			
			if (normalizedVect.x > 0) {
				_mapStepX = 1;
				_cellOffsetX = 1 / normalizedVect.x;
				_cellEdgeX = (1+_mapPosX - ((_cubeSize * 0.5 - cameraPosition.x) / _cubeSize))/normalizedVect.x;
			}else {
				_mapStepX = -1;
				_cellOffsetX = -1 / normalizedVect.x;
				_cellEdgeX = (_mapPosX - ((_cubeSize * 0.5 - cameraPosition.x) / _cubeSize))/normalizedVect.x;
			}
			if (normalizedVect.y > 0) {
				_mapStepY = 1;
				_cellOffsetY = 1 / normalizedVect.y;
				_cellEdgeY = (1 + _mapPosY - ((cameraPosition.y +_cubeSize * 0.5) / _cubeSize))/normalizedVect.y;
			}else {
				_mapStepY = -1;
				_cellOffsetY = -1 / normalizedVect.y;
				_cellEdgeY = (_mapPosY - ((cameraPosition.y + _cubeSize * 0.5) / _cubeSize))/normalizedVect.y;
			}
			if (normalizedVect.z > 0) {
				_mapStepZ = 1;
				_cellOffsetZ = 1 / normalizedVect.z;
				_cellEdgeZ = (1 + _mapPosZ - ((cameraPosition.z + _cubeSize * 0.5) / _cubeSize))/normalizedVect.z;
			}else {
				_mapStepZ = -1;
				_cellOffsetZ = -1 / normalizedVect.z;
				_cellEdgeZ = (_mapPosZ - ((cameraPosition.z + _cubeSize * 0.5) / _cubeSize))/normalizedVect.z;
			}
			
			//DDA
			var dist:Number = 0;
			var lastEdge:Number = 0;
			
			while (dist <= _distanceMax) {
				_lastTestedKube.x = _mapPosX;
				_lastTestedKube.y = _mapPosY;
				_lastTestedKube.z = _mapPosZ;
				
				if (_cellEdgeX < _cellEdgeY) {
					if (_cellEdgeX < _cellEdgeZ) {
						dist += _cellEdgeX - lastEdge;
						lastEdge = _cellEdgeX;
						_mapPosX += _mapStepX;
						_cellEdgeX += _cellOffsetX;
					}else {
						dist += _cellEdgeZ - lastEdge;
						lastEdge = _cellEdgeZ;
						_mapPosZ += _mapStepZ;
						_cellEdgeZ += _cellOffsetZ;
					}
				}else {
					if (_cellEdgeY < _cellEdgeZ) {
						dist += _cellEdgeY - lastEdge;
						lastEdge = _cellEdgeY;
						_mapPosY += _mapStepY;
						_cellEdgeY += _cellOffsetY;
					}else {
						dist += _cellEdgeZ - lastEdge;
						lastEdge = _cellEdgeZ;
						_mapPosZ += _mapStepZ;
						_cellEdgeZ += _cellOffsetZ;
					}
				}
				
				_actualTestedKube.x = _mapPosX;
				_actualTestedKube.y = _mapPosY;
				_actualTestedKube.z = _mapPosZ;
				
				if (isAkube(_actualTestedKube)) { 
					return(true);
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