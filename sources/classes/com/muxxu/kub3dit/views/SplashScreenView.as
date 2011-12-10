package com.muxxu.kub3dit.views {
	import gs.TweenLite;
	import gs.easing.Elastic;

	import com.muxxu.kub3dit.components.buttons.ButtonSplashScreen;
	import com.muxxu.kub3dit.components.form.MapSizeInput;
	import com.muxxu.kub3dit.controler.FrontControler;
	import com.muxxu.kub3dit.events.ToolTipEvent;
	import com.muxxu.kub3dit.graphics.CloudGraphic;
	import com.muxxu.kub3dit.graphics.LogoGraphic;
	import com.muxxu.kub3dit.graphics.MainCloudGraphic;
	import com.muxxu.kub3dit.graphics.SplashScreenBackgroundGraphic;
	import com.muxxu.kub3dit.model.Model;
	import com.muxxu.kub3dit.vo.ToolTipAlign;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * 
	 * @author Francois
	 * @date 2 nov. 2011;
	 */
	public class SplashScreenView extends AbstractView {
		private var _logo:LogoGraphic;
		private var _background:SplashScreenBackgroundGraphic;
		private var _createBt:ButtonSplashScreen;
		private var _loadBt:ButtonSplashScreen;
		private var _buttonsHolder:Sprite;
		private var _clouds:Vector.<CloudGraphic>;
		private var _cloudsHolder:Sprite;
		private var _speeds:Vector.<Number>;
		private var _backButtons:MainCloudGraphic;
		private var _shadow:DropShadowFilter;
		private var _mapSize:MapSizeInput;
		private var _ready:Boolean;
		private var _creationMode:Boolean;
		private var _defaultBt:ButtonSplashScreen;
		private var _defaultSize:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SplashScreenView</code>.
		 */
		public function SplashScreenView() {
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			if(!_ready && model.map == null) {
				_ready = true;
				initialize();
			}else{
				TweenLite.to(this, .25, {autoAlpha:0, delay:.5});
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_background = addChild(new SplashScreenBackgroundGraphic()) as SplashScreenBackgroundGraphic;
			_cloudsHolder = addChild(new Sprite()) as Sprite;
			_logo = addChild(new LogoGraphic()) as LogoGraphic;
			_logo.addFrameScript(_logo.totalFrames - 1, onAnimComplete);
			_backButtons = addChild(new MainCloudGraphic()) as MainCloudGraphic;
			_buttonsHolder = addChild(new Sprite()) as Sprite;
			_defaultBt = _buttonsHolder.addChild(new ButtonSplashScreen("")) as ButtonSplashScreen;
			_createBt = _buttonsHolder.addChild(new ButtonSplashScreen(Label.getLabel("splashCreate"))) as ButtonSplashScreen;
			_loadBt = _buttonsHolder.addChild(new ButtonSplashScreen(Label.getLabel("splashLoad"))) as ButtonSplashScreen;
			_mapSize = addChild(new MapSizeInput()) as MapSizeInput;
			
			_defaultSize = 4;
			changeDefaultHandler();
			
			_buttonsHolder.alpha = 0;
			_buttonsHolder.visible = false;
			_backButtons.alpha = 0;
			_backButtons.visible = false;
			_mapSize.alpha = 0;
			_mapSize.visible = false;
			_loadBt.width = _createBt.width = _defaultBt.width = Math.max(_loadBt.width, _createBt.width, _defaultBt.width)+100;
			
			createClouds();
			
			_createBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_defaultBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_loadBt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_mapSize.addEventListener(Event.COMPLETE, mapSizeSubmitHandler);
			_mapSize.addEventListener(Event.CANCEL, cancelMapSizeHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			stage.addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_defaultBt.addEventListener(MouseEvent.MOUSE_WHEEL, changeDefaultHandler);
			_defaultBt.addEventListener(MouseEvent.ROLL_OVER, overDefaultHandler);
			
			computePositions();
			
			_backButtons.width = _buttonsHolder.width * 1.5;
			_backButtons.height = _buttonsHolder.height * 1.5;
			computePositions();//double compute dirty but needed!
		}
		
		/**
		 * Creates the clouds
		 */
		private function createClouds():void {
			//Create clouds
			var i:int, len:int, cloud:CloudGraphic;
			len = 10;
			_clouds = new Vector.<CloudGraphic>(len, true);
			_speeds = new Vector.<Number>(len, true);
			_shadow = new DropShadowFilter(10,135,0,.2,10,10,1,2);
			for(i = 0; i < len; ++i) {
				cloud = _cloudsHolder.addChild(new CloudGraphic()) as CloudGraphic;
				cloud.gotoAndStop(Math.ceil(Math.random() * (cloud.totalFrames-1)));
				cloud.x = i/(len-1)*stage.stageWidth;
				cloud.y = Math.random()*stage.stageHeight - cloud.height*.5;
				cloud.filters = [_shadow];
				_clouds[i] = cloud;
				_speeds[i] = i*.15+3;
			}
			
			_backButtons.filters = [_shadow];
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			_background.width = stage.stageWidth;
			_background.height = stage.stageHeight;
			
			_createBt.y = Math.round(_defaultBt.y + _defaultBt.height - 15);
			_loadBt.y = Math.round(_createBt.y + _createBt.height - 15);
			
			PosUtils.centerInStage(_logo);
			PosUtils.centerInStage(_buttonsHolder);
			PosUtils.centerInStage(_mapSize);
			PosUtils.centerInStage(_backButtons);
			
			_backButtons.x -= 10;
			_backButtons.y += 15;
		}
		
		/**
		 * Called when animation completes
		 */
		private function onAnimComplete(delay:Number = .5):void {
			_logo.stop();
			TweenLite.to(_logo, delay==0? .2 : .5, {autoAlpha:0, delay:delay});
			TweenLite.to(_buttonsHolder, .25, {autoAlpha:1, delay:delay + (delay==0? .2 : .5)});
			TweenLite.to(_backButtons, .25, {autoAlpha:1, delay:delay + (delay==0? .2 : .5)});
			stage.removeEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		
		
		//__________________________________________________________ MOUSE EVENTS
		
		/**
		 * Called when th view is clicked to skip it.
		 */
		private function clickHandler(event:MouseEvent):void {
			onAnimComplete(0);
		}
		
		/**
		 * Called when a button is clicked
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if(event.currentTarget == _createBt) {
				_creationMode = true;
				TweenLite.to(_mapSize, .25, {autoAlpha: 1});
				TweenLite.to(_buttonsHolder, .25, {autoAlpha: 0});
				TweenLite.to(_backButtons, 2, {width:_mapSize.width * 1.5, height:_mapSize.height * 1.5, ease:Elastic.easeOut, easeParams:[1,.4], onUpdate:computePositions});
				computePositions();
				
			}else if(event.currentTarget == _defaultBt) {
				FrontControler.getInstance().createMap(_defaultSize, _defaultSize, Config.getNumVariable("mapSizeHeight"));
				
			}else if(event.currentTarget == _loadBt) {
				FrontControler.getInstance().loadMap();
			}
		}
		
		/**
		 * Called when map's size are submitted.
		 */
		private function mapSizeSubmitHandler(event:Event):void {
			mouseEnabled = mouseChildren = false;
			FrontControler.getInstance().createMap(_mapSize.sizeX, _mapSize.sizeY, Config.getNumVariable("mapSizeHeight"));
		}
		
		/**
		 * Called when cancel button is clicked
		 */
		private function cancelMapSizeHandler(event:Event):void {
			TweenLite.to(_mapSize, .25, {autoAlpha: 0});
			TweenLite.to(_buttonsHolder, .25, {autoAlpha: 1});
			_creationMode = false;
			TweenLite.to(_backButtons, 2, {width:_buttonsHolder.width * 1.5, height:_buttonsHolder.height * 1.5, ease:Elastic.easeOut, easeParams:[1,.4], onUpdate:computePositions});
			computePositions();
		}
		
		/**
		 * Called when changing the default map's size
		 */
		private function changeDefaultHandler(event:MouseEvent = null):void {
			if(event != null) {
				_defaultSize += MathUtils.sign(event.delta);
			}
			
			_defaultSize = MathUtils.restrict(_defaultSize, 1, 20);
			
			_defaultBt.label = Label.getLabel("splashDefault").replace(/\$\{X\}/gi, _defaultSize).replace(/\$\{Y\}/gi, _defaultSize);
			_defaultBt.validate();
		}
		
		/**
		 * Called when default button is rolled over
		 */
		private function overDefaultHandler(event:MouseEvent):void {
			_defaultBt.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("defaultHelp"), ToolTipAlign.TOP, 20, "tooltipContentBig"));
		}
		
		
		
		
		//__________________________________________________________ CLOUDS

		private function enterFrameHandler(event:Event):void {
			var i:int, len:int, cloud:CloudGraphic;
			len = _clouds.length;
			for(i = 0; i < len; ++i) {
				cloud = _clouds[i];
				cloud.x += _speeds[i];
				if(cloud.x > stage.stageWidth) {
					if(Math.random()>.98) {
						cloud.gotoAndStop(cloud.totalFrames);
					}else{
						cloud.gotoAndStop(Math.ceil(Math.random() * (cloud.totalFrames-1)));
					}
					cloud.x = -cloud.getBounds(cloud).right;
					cloud.y = Math.random()*stage.stageHeight - cloud.height*.5;
				}
			}
		}
		
	}
}