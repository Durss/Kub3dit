package com.muxxu.kub3dit.views {
	import gs.TweenLite;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.engin3d.background.Background;
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.campath.CameraPath;
	import com.muxxu.kub3dit.engin3d.chunks.ChunkData;
	import com.muxxu.kub3dit.engin3d.chunks.ChunksManager;
	import com.muxxu.kub3dit.engin3d.events.ManagerEvent;
	import com.muxxu.kub3dit.engin3d.ground.Ground;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.preview.PreviewCursor;
	import com.muxxu.kub3dit.engin3d.raycast.RayCaster;
	import com.muxxu.kub3dit.exceptions.Kub3ditException;
	import com.muxxu.kub3dit.exceptions.Kub3ditExceptionSeverity;
	import com.muxxu.kub3dit.model.Model;
	import com.muxxu.kub3dit.vo.KeyboardConfigs;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
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
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;

	/**
	 * Displays the 3D things
	 * 
	 * @author Francois
	 * @date 30 oct. 2011;
	 */
	public class Stage3DView extends AbstractView {
		
		private var _stage3D:Stage3D;
		private var _chunksManager:ChunksManager;
		private var _context3D:Context3D;
		private var _accelerated:Boolean;
		private var _background:Background;
		private var _ground:Ground;
		private var _ready:Boolean;
		private var _log:CssTextField;
		private var _map:Map;
		private var _preview:PreviewCursor;
		private var _camPath:CameraPath;
		private var _rayCaster:RayCaster;
		private var _rayStart:Point;
		private var _lastMouse3DPos:Vector3D;
		private var _selectorView:KubeSelectorView;
		private var _selectedKubePos:Vector3D;
		private var _rightButtonPressed:Boolean;
		
		
		
		
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
		 * Gets the chunks manager's reference
		 */
		public function get manager():ChunksManager { return _chunksManager; }



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
			_rayCaster = new RayCaster(_map);
			_chunksManager = new ChunksManager(_map);
			_context3D = _stage3D.context3D;
			_context3D.enableErrorChecking = Capabilities.playerType.toLowerCase() == "standalone";//Enable debug in standalone mode
			_context3D.setDepthTest(true, Context3DCompareMode.LESS);
			_context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			_accelerated = _context3D.driverInfo.toLowerCase().indexOf("software") == -1;
			
			_background	= new Background(_context3D);
			_ground		= new Ground(_context3D, _accelerated, _chunksManager);
			_preview	= new PreviewCursor(_context3D, _accelerated);
			_camPath	= new CameraPath(_context3D);
			_rayStart	= new Point();
			_selectorView = ViewLocator.getInstance().locateViewByType(KubeSelectorView) as KubeSelectorView;
			
			FrontControler.getInstance().view3DReady();
			stage.addEventListener(Event.RESIZE, resizeHandler);
			_chunksManager.addEventListener(ManagerEvent.COMPLETE, createChunksCompleteHandler);
			resizeHandler(null);
			
			initChunksManager();
			FrontControler.getInstance().chunksManager = _chunksManager;
			
			if (!_accelerated) {
				var tfError:CssTextField = addChild(new CssTextField("errorBig")) as CssTextField;
				tfError.background = true;
				tfError.backgroundColor = 0x47A9D1;
				tfError.text = Label.getLabel("accelerationDisabledWarning");
				tfError.y = stage.stageHeight + 10;
				tfError.filters = [new DropShadowFilter(5, -90, 0, .5, 5, 5, 1.2, 3)];
				PosUtils.hCenterIn(tfError, stage);
				TweenLite.to(tfError, .5, {y:stage.stageHeight-tfError.height, delay:2});
				TweenLite.to(tfError, .5, {y:stage.stageHeight + 10, delay:10, removeChild:true});
			}
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
		private function initChunksManager():void {
			Camera3D.setMap(_map);
			
			//Inits the camera correctly to be sure the chunks loading priority
			//based on the z-sorting will be done correctly
			renderFrame(null);
			
			_chunksManager.initialize(_context3D, _accelerated);
			
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, clickHandler, false, 0xffffff);
			stage.addEventListener(MouseEvent.RIGHT_CLICK, rightClickHandler);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rightPressHandler);
		}

		private function rightPressHandler(event:MouseEvent):void {
			_rightButtonPressed = true;
		}

		private function rightClickHandler(event:MouseEvent):void {
			_rightButtonPressed = false;
			if(Camera3D.isDragging || _preview.forcedPosition == null) return;
			_chunksManager.update(_selectedKubePos.x, _selectedKubePos.y, _selectedKubePos.z, 0);
		}
		
		/**
		 * Called when the stage is clicked to put a kube.
		 */
		private function clickHandler(event:MouseEvent):void {
			if(Camera3D.isDragging || _preview.forcedPosition == null) return;
			//Reuse _rayStart var not to create new useless Point instance.
			_rayStart.x = mouseX;
			_rayStart.y = mouseY;
			if(stage.getObjectsUnderPoint(_rayStart).length == 0 && _lastMouse3DPos != null) {
				_chunksManager.update(_lastMouse3DPos.x, _lastMouse3DPos.y, _lastMouse3DPos.z, _selectorView.currentKubeId);
			}
		}
		
		/**
		 * Called when a key is released to change the distance fog.
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(!(event.target is Stage)) return;
			
			if(event.keyCode == Keyboard.NUMPAD_ADD || event.keyCode == Keyboard.NUMPAD_SUBTRACT
			|| event.keyCode == KeyboardConfigs.FOG_FAR || event.keyCode == KeyboardConfigs.FOG_NEAR) {
				var sign:int = (event.keyCode == Keyboard.NUMPAD_ADD|| event.keyCode == KeyboardConfigs.FOG_FAR)? 1 : -1;
				_chunksManager.changeRenderingDistance(sign);
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
			_chunksManager.createBuffers();
			graphics.clear();
			addEventListener(Event.ENTER_FRAME, renderFrame);
			_chunksManager.removeEventListener(ManagerEvent.COMPLETE, createChunksCompleteHandler);
		}
		
		/**
		 * Called on ENTER_FRAME to render the chunks
		 */
		private function renderFrame(e:Event):void {
			var W:int = stage.stageWidth&~1;
			var H:int = stage.stageHeight&~1;
			_context3D.clear();
			_context3D.setCulling(Context3DTriangleFace.BACK);
			
			//compute transformation matrix
			var projection:Matrix3D = getProjectionMatrix(W, H, false);
			var m:Matrix3D = new Matrix3D();
			m.appendTranslation(Camera3D.position.x, -Camera3D.position.y, Camera3D.position.z);
			m.appendRotation(90, Vector3D.X_AXIS);
			m.appendRotation(Camera3D.rotationX, Vector3D.Y_AXIS);
			m.appendRotation(-Camera3D.rotationY, Vector3D.X_AXIS);
			m.append(projection);
			
			_preview.forcedPosition = null;
			_rayStart.x = mouseX;
			_rayStart.y = mouseY;
			//If no object is under the mouse, that's because it's over the stage3D scene
			if(!Camera3D.isDragging && !Camera3D.isFollowing && stage.getObjectsUnderPoint(_rayStart).length == 0) {
				_rayStart.x = ((stage.mouseX - stage.stageWidth * .5) / stage.stageWidth) *2;
				_rayStart.y = ((stage.mouseY - stage.stageHeight * .5) / stage.stageHeight) *2;
				_rayCaster.cast(Camera3D.position, _rayStart, Camera3D.rotationX, Camera3D.rotationY, projection);
				//The ray crossed a Kube
				if(_rayCaster.lastKube != null){
					_selectedKubePos = _rayCaster.actualKube;
					_lastMouse3DPos = _rayCaster.lastKube;
					if(_rightButtonPressed) {
						if(_selectedKubePos.z > -1) {
							_preview.forcedPosition = _selectedKubePos;
						}
					}else{
						_preview.forcedPosition = _lastMouse3DPos;
					}
				}
			}
			
			//Render background, ground, and cubes
			_background.setSizes(W, H);
			_background.render();
			
			//Set programs constants
			var fogLength:int = Math.min(Math.max(_chunksManager.visibleChunksX, _chunksManager.visibleChunksY) * 3, 24) * ChunkData.CUBE_SIZE;
			// Number of cubes to do the fog on
			var farplane:int = _chunksManager.visibleCubes*.5 * ChunkData.CUBE_SIZE - fogLength;//Number of cubes to start the fog at
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>( [ -Camera3D.position.x, Camera3D.position.y, fogLength, farplane ] ) );
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
			
			
			_ground.render();
			_preview.render();
			_chunksManager.render(m, W, H);
			//The chunk manager plays with blend modes. We reset them.
			_context3D.setDepthTest(true, Context3DCompareMode.LESS);
			_context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			_context3D.setCulling(Context3DTriangleFace.NONE);
			_camPath.render();
			
			_context3D.present();
			
			PosUtils.centerInStage(_log);
		}

		/**
		 * Get the projection matrix.
		 */
		private function getProjectionMatrix(w:Number, h:Number, orthogonal:Boolean = false):Matrix3D {
			var zNear:Number, zFar:Number;
			if(!orthogonal) {
				//Perspective view
				var fov:int = 0;//60 * 0.0087266462599;
				zNear = 2000;
				zFar = 1.65;
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