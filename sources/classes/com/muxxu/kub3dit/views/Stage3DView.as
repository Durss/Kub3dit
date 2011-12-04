package com.muxxu.kub3dit.views {
	import com.nurun.utils.input.keyboard.events.KeyboardSequenceEvent;
	import com.nurun.utils.input.keyboard.KeyboardSequenceDetector;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.engin3d.background.Background;
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.events.ManagerEvent;
	import com.muxxu.kub3dit.engin3d.ground.Ground;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.exceptions.Kub3ditException;
	import com.muxxu.kub3dit.exceptions.Kub3ditExceptionSeverity;
	import com.muxxu.kub3dit.model.Model;
	import com.muxxu.kub3dit.vo.KeyboardConfigs;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.ErrorEvent;
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
		private var _background:Background;
		private var _ground:Ground;
		private var _visibleChunks:int;
		private var _mapSizeW:int;
		private var _chunkSize:int;
		private var _ready:Boolean;
		private var _visibleCubes:int;
		private var _log:CssTextField;
		private var _mapSizeH:Number;
		private var _map:Map;
		private var _ks:KeyboardSequenceDetector;
		
		
		
		
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
			
			if(!_ready && model.map != null) {
				_ready = true;
				_map = model.map;
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
			_log.background = true;
			_log.visible = false;
			new Camera3D(stage);
			
			_stage3D = stage.stage3Ds[0];
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, context3DReadyHandler);
			_stage3D.addEventListener(ErrorEvent.ERROR, context3DErrorHandler);
			_stage3D.requestContext3D(Context3DRenderMode.AUTO);
		}
		
		/**
		 * Called if Context3D isn't available
		 */
		private function context3DErrorHandler(event:ErrorEvent):void {
			throw new Kub3ditException("Flash badly embeded! Please add wmode=\"direct\" to make it work correctly!", Kub3ditExceptionSeverity.FATAL);
		}
		
		/**
		 * Called when context 3D is ready
		 */
		private function context3DReadyHandler(event:Event):void {
			_manager = new ChunksManager(_map);
			_context3D = _stage3D.context3D;
			_context3D.enableErrorChecking = false;
			_context3D.setCulling(Context3DTriangleFace.BACK);
			_context3D.setDepthTest(true, Context3DCompareMode.LESS);
			_context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			_accelerated = _context3D.driverInfo.toLowerCase().indexOf("software") == -1;
			
			_background = new Background(_context3D);
			_ground = new Ground(_context3D, _accelerated);
			
			createVoxelChunks();
			
			FrontControler.getInstance().view3DReady();
			stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeHandler(null);
			
			_ks = new KeyboardSequenceDetector(stage);
			_ks.addSequence("poil", "poil");
			_ks.addEventListener(KeyboardSequenceEvent.SEQUENCE, sequenceHandler);
		}

		private function sequenceHandler(event:KeyboardSequenceEvent):void {
			Camera3D.toggleWASD();
		}
		
		/**
		 * Called when window is resized
		 */
		private function resizeHandler(event:Event):void {
			var W:int = stage.stageWidth&~1;//&~1 force even size. Stage 3D is a bit faster with even size
			var H:int = stage.stageHeight&~1;
			_context3D.configureBackBuffer(W, H, 0, true);
		}
		
		/**
		 * Creates the voxel chunks
		 */
		private function createVoxelChunks():void {
			_chunkSize = 8;//Number of cubes to compose a chunk of
			_mapSizeW = _map.mapSizeX;//Numer of cubes to compose the map of in width
			_mapSizeH = _map.mapSizeY;//Numer of cubes to compose the map of in height
			_visibleCubes = _accelerated? 160 : 16;//Number of visible cubes before fog
			_visibleChunks = MathUtils.restrict(Math.ceil(_visibleCubes/_chunkSize)+2, 2, Math.min(_mapSizeW, _mapSizeH)/_chunkSize);//Number of visible chunks around us
			
			_manager.initialize(_context3D, _chunkSize, _accelerated);
			_manager.addEventListener(ManagerEvent.COMPLETE, createChunksCompleteHandler);
			Camera3D.setMapSize(_mapSizeW, _mapSizeH);
			Camera3D.setPosition(new Vector3D(0,0,2));
			Camera3D.setPosition(new Vector3D(-_mapSizeW*.5,_mapSizeH*.5, 2));
			Camera3D.rotationX = 0;
			
			//Do the following AFTER camera init to be sure the chunks loading priority
			//based on the z-sorting will be done correctly
			renderFrame(null);
			_manager.setVisibleChunks(Math.min(_visibleChunks, _mapSizeW/_chunkSize), Math.min(_visibleChunks, _mapSizeH/_chunkSize));
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}

		private function keyUpHandler(event:KeyboardEvent):void {
			if(!(event.target is Stage)) return;
			
			if(event.keyCode == Keyboard.NUMPAD_ADD || event.keyCode == Keyboard.NUMPAD_SUBTRACT
			|| event.keyCode == KeyboardConfigs.FOG_FAR || event.keyCode == KeyboardConfigs.FOG_NEAR) {
//				_visibleChunks += (event.keyCode == Keyboard.NUMPAD_ADD|| event.keyCode == KeyboardConfigs.FOG_FAR)? 1 : -1;
				_visibleCubes += (event.keyCode == Keyboard.NUMPAD_ADD|| event.keyCode == KeyboardConfigs.FOG_FAR)? _chunkSize : -_chunkSize;
				_visibleCubes = Math.max(_visibleCubes, _chunkSize);
				_visibleChunks = MathUtils.restrict(Math.ceil(_visibleCubes/_chunkSize)+2, 2, Math.min(_mapSizeW, _mapSizeH)/_chunkSize);
				_manager.setVisibleChunks(_visibleChunks,_visibleChunks);
			}
			
			if(event.keyCode == Keyboard.ESCAPE && event.ctrlKey) {
				_log.text = _context3D.driverInfo;
				_log.visible = !_log.visible;
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
			var W:int = stage.stageWidth&~1;
			var H:int = stage.stageHeight&~1;
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
			var fogLength:int = Math.min(Math.floor(_visibleChunks*.5), 8);//Number of cubes to do the fog on
			var farplane:int = _visibleCubes*.5;//Number of cubes to start the fog at
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>( [ -Camera3D.locX, Camera3D.locY, fogLength, farplane ] ) );
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
			
			_ground.render();
			_manager.render(m, W, H);
			
			_context3D.present();
			
//			_log.text = _manager.offsetX+" :: "+_manager.offsetY+"\n"+Camera3D.locX+" :: "+Camera3D.locY;
			PosUtils.centerInStage(_log);
		}

		/**
		 * Get the project matrix.
		 */
		private static function getProjectionMatrix(w:Number, h:Number, orthogonal:Boolean = false):Matrix3D {
			var zNear:Number, zFar:Number;
			if(!orthogonal) {
				//Perspective view
				var fov:int = 0;//60 * 0.0087266462599;
				zNear = 2000;
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