package com.muxxu.kub3dit.views {
	import com.muxxu.kub3dit.engin3d.background.Background;
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.events.ManagerEvent;
	import com.muxxu.kub3dit.engin3d.ground.Ground;
	import com.muxxu.kub3dit.model.Model;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.math.MathUtils;

	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	/**
	 * Displays the 3D things
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class Stage3DView extends AbstractView {
		
		private var _stage3D:Stage3D;
		private var _manager:ChunksManager;
		private var _context3D:Context3D;
		private var _accelerated:Boolean;
		private var _background : Background;
		private var _ground:Ground;
		private var _visibleChunks:int;
		private var _mapSize:int;
		private var _chunkSize:int;
		private var _ready:Boolean;
		private var _visibleCubes:int;
		private var _log:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Stage3DView</code>.
		 */
		public function Stage3DView() {
			
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the number of visible cubes.
		 * Used by radar and grid.
		 */
		public function get visibleCubes():int { return _visibleCubes; }
		
		/**
		 * Gets the chunks manager's reference
		 */
		public function get manager():ChunksManager { return _manager; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			model;
			if(!_ready) {
				_ready = true;
				initialize();
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_log = addChild(new CssTextField("debug")) as CssTextField;
			new Camera3D(stage);
			
			_stage3D = stage.stage3Ds[0];
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, context3DReadyHandler);
			_stage3D.requestContext3D(Context3DRenderMode.AUTO);
		}
		
		/**
		 * Called when context 3D is ready
		 */
		private function context3DReadyHandler(event:Event):void {
			_manager = new ChunksManager();
			_context3D = _stage3D.context3D;
			_context3D.enableErrorChecking = false;
			_context3D.setCulling(Context3DTriangleFace.BACK);
			_context3D.setDepthTest(true, Context3DCompareMode.LESS);
			_context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			_accelerated = _context3D.driverInfo.toLowerCase().indexOf("software") == -1;
			
			_background = new Background(_context3D);
			_ground = new Ground(_context3D);
			createVoxelChunks();
		}
		
		/**
		 * Creates the voxel chunks
		 */
		private function createVoxelChunks():void {
			_chunkSize = 8;//Number of cubes to compose a chunks of
			_mapSize = 32 * 8;//Numer of cubes to compose the map of in width and height
			_visibleCubes = _accelerated? 160 : 32;//Number of visible cubes before fog
			_visibleChunks = _visibleCubes / _chunkSize;//Number of visible chunks around us
			
			_visibleChunks = Math.min(_mapSize, _visibleChunks);
			_manager.initialize(_context3D, _chunkSize, _mapSize);
			_manager.addEventListener(ManagerEvent.COMPLETE, createChunksCompleteHandler);
			Camera3D.setMapSize(_mapSize, _mapSize);
			Camera3D.setPosition(new Vector3D(0,0,2));
			Camera3D.setPosition(new Vector3D(-_mapSize*.5,_mapSize*.5, 2));
			Camera3D.rotationX = -45;
			//Do this AFTER camera init to be sure the chunks loading priority
			//based on the z-sorting will be done correctly
			renderFrame(null);
			_manager.setVisibleChunks(_visibleChunks,_visibleChunks);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}

		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.NUMPAD_ADD || event.keyCode == Keyboard.NUMPAD_SUBTRACT) {
				_visibleChunks += event.keyCode == Keyboard.NUMPAD_ADD? 1 : -1;
				_visibleChunks = MathUtils.restrict(_visibleChunks, 2, _mapSize/_chunkSize);
				_visibleCubes = _visibleChunks * _chunkSize;
				_manager.setVisibleChunks(_visibleChunks,_visibleChunks);
			}
		}
		
		/**
		 * Called when chunks creation completes
		 */
		private function createChunksCompleteHandler(event:ManagerEvent):void {
			_manager.createBuffers();
			graphics.clear();
			addEventListener(Event.ENTER_FRAME, renderFrame);
			_manager.removeEventListener(ManagerEvent.COMPLETE, createChunksCompleteHandler);
		}
		
		/**
		 * Called on ENTER_FRAME to render the chunks
		 */
		private function renderFrame(e:Event):void {
			var W:int = stage.stageWidth;
			var H:int = stage.stageHeight;
			_context3D.configureBackBuffer(W, H, 4, true);
			_context3D.clear();
			
			//compute transformation matrix
			var m:Matrix3D = new Matrix3D();
			m.appendTranslation(Camera3D.locX, -Camera3D.locY, Camera3D.locZ);
			m.appendRotation(90, Vector3D.X_AXIS);
			m.appendRotation(Camera3D.rotationX, Vector3D.Y_AXIS);
			m.appendRotation(-Camera3D.rotationY, Vector3D.X_AXIS);
			m.append(getProjectionMatrix(W, H, false));
			
			//Render background, ground, and cubes
			_background.setSizes(W, H);
			_background.render();
			
			//Set programs constants
			var farplane:int = _visibleCubes*.5 - _chunkSize;//Number of cubes to start the fog at
			var fogLength:int = _visibleChunks < 4? 4 : 8;//Number of cubes to do the fog on
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>( [ -Camera3D.locX, Camera3D.locY, fogLength, farplane ] ) );
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
			
			_ground.render();
			_manager.render(m, W, H);
			
			_context3D.present();
			
//			_log.text = _manager.offsetX+" :: "+_manager.offsetY+"\n"+Camera3D.locX+" :: "+Camera3D.locY;
//			_log.x = stage.stageWidth - _log.width;
		}

		/**
		 * Get the project matrix.
		 */
		private static function getProjectionMatrix(w:Number, h:Number, orthogonal:Boolean = false):Matrix3D {
			var zNear:int, zFar:int;
			if(!orthogonal) {
				//Perspective view
				var fov:int = 0;//60 * 0.0087266462599;
				zNear = 1200;
				zFar = 1;
				var w1:Number = (2 * zNear / (zNear * Math.atan(fov) - w));
				var h1:Number = (2 * zNear / (zNear * Math.atan(fov) + h));
				var q1:Number = -1 * (zFar + zNear) / (zFar - zNear);
				var q2:Number = -2 * (zFar * zNear) / (zFar - zNear);
				
				return new Matrix3D(Vector.<Number>
				([
					w1 ,0 , 0, 0,
					0 ,h1 , 0, 0,
					0 ,0 , q1, q2,
					0 ,0 , -1, 0
				]));
			}else{
				//OrthogonalView (fucked up :( )
				zNear = 2000;
				zFar = -2000;
				return new Matrix3D(Vector.<Number>
				([
					2/w, 0  ,       0,        0,
					0  , 2/h,       0,        0,
					0  , 0  , 		1/(zFar-zNear), 		  0,
					0  , 0  ,       zNear/(zNear-zFar),        1
				]));
			}
		}
		
	}
}