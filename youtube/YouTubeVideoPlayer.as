package com.smp.api.youtube {
	
	
	/* Exemmplo de uso:
	 * 
		import com.smp.api.youtube.YouTubeVideoPlayer;
		
		var _videoPlayer = new YouTubeVideoPlayer("XXXXXX", true, true);
		_videoPlayer.addEventListener(Event.COMPLETE, onPlayerReady);
		
		function onPlayerReady(evt:Event):void {
			_videoPlayer.setScreen(screen);
			_videoPlayer.PlayPauseBt = videoControlsCont.videoControls.playPause;
			_videoPlayer.TimelineView = videoControlsCont.videoControls.timelines.timeline;
			_videoPlayer.PlayheadBar = videoControlsCont.videoControls.timelines.playhead;
			_videoPlayer.PlayheadSlider = videoControlsCont.videoControls.playHead;
			_videoPlayer.StopBt = videoControlsCont.videoControls.initBt;
			_videoPlayer.VolumeOnOffBt = videoControlsCont.videoControls.volumeOnOff;
			_videoPlayer.setVolumeBt(videoControlsCont.videoControls.volumeControl);
			_videoPlayer.setMaxVolume(0.8);
			_videoPlayer.setVolume(0.4);
			_videoPlayer.video.rescale(600);
		}
	 * 
	 * 
	*/
	  
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import com.smp.media.video.*;
	import com.smp.media.Invoker;
	import com.smp.media.InputHandler

	
	public class YouTubeVideoPlayer  extends EventDispatcher{
		
		private var videoCollection:Array;
		//private var videoObject:IVideoOutput
		private var invoker:Invoker;
		private var model:VideoModel;
		//private var _file:String = "";
		private var _loop:Boolean;
		private var _autoplay:Boolean;
		
		private var _activeId:int;
		private var _screen:DisplayObjectContainer;
		
		private var playbackWidth:Number = 0;
		
		
		public function YouTubeVideoPlayer(files:Array, loop:Boolean  = false, autoplay:Boolean = false) {
			
			videoCollection = new Array();
			for (var i:uint = 0; i < files.length; i++) {
				var videoObject:IVideoOutput = new YouTubeVideoInterface();	
				videoObject.addEventListener(VideoEvent.END, onVideoComplete);
				videoObject.addEventListener(Event.COMPLETE, onPlayerReady);
				videoCollection.push(videoObject);
			}
			
			_loop = loop;
			_autoplay = autoplay;

			invoker = new Invoker();
			
			model = new VideoModel();
			model.setMediaList(files);
			
			model.activeVideo = videoCollection[0];
			_activeId = 0;
			
			if (files.length == 0) {
				throw new Error("VideoPlayer->init: files array must not be empty.");		
			}
		}
		
		private function onPlayerReady(evt:Event):void{
			(videoCollection[0] as IVideoOutput).load(model.getMediaFile(0), false, _autoplay, true);
			dispatchEvent(evt);
		}
	
		public function set autoplay(value:Boolean):void {
			_autoplay = value;
		}
		
		public function set loop(value:Boolean):void {
			_loop = value;
		}
		
		public function setScreen(obj:DisplayObjectContainer):void {
			_screen = obj;
			_screen.addChild(videoCollection[model.activeId].getPlayer());
		}
		
		public function play(item:uint = 0):void {
			
			
			if (model.activeVideo != (videoCollection[item] as IVideoOutput)) {
				
				if((videoCollection[_activeId] as IVideoOutput).playing){
				(videoCollection[_activeId] as IVideoOutput).stop();
				}
				
				model.activeVideo = (videoCollection[item] as IVideoOutput);
				
				if(!(videoCollection[item] as IVideoOutput).loaded){
					(videoCollection[item] as IVideoOutput).load(model.getMediaFile(item), _loop, _autoplay, true);
				}else {
					(videoCollection[item] as IVideoOutput).init();
				}
				(videoCollection[item] as IVideoOutput).volume = model.getVolume();
				
				_screen.removeChild(videoCollection[_activeId]);
				_screen.addChild(videoCollection[item]);
				
				_activeId = model.activeId;
			}
		
		}
		
		
		/* 
		 * obj é um MovieClip com dois frames "play" e "pause"
		 */
		public function set PlayPauseBt(obj:MovieClip):void {
			var playPauseBt:VideoInterfaceComponent = new PlayPauseButton(obj);
			playPauseBt.init(model);
			invoker.setMouseHandler(playPauseBt, new InputHandler(new PlayPauseCommand(model)));	
		}
		
		/* 
		 * obj é um MovieClip com uma animação na timeline e dois stop(), no 1º e último frame
		 */
		public function set StopBt(obj:MovieClip):void {
			var StopBt:VideoInterfaceComponent = new StopButton(obj);
			StopBt.init(model);
			invoker.setMouseHandler(StopBt, new InputHandler(new StopCommand(model)));
		}
		
		
		/* 
		 * 
		 */
		public function set TimelineView(obj:MovieClip):void {
			playbackWidth = obj.width;
			var timeline:VideoInterfaceComponent = new Timeline(obj);
			timeline.init(model);
		}
		
		/* 
		 * 
		 */
		public function set PlayheadBar(obj:MovieClip):void {
			var playheadBar:VideoInterfaceComponent = new PlayheadBar(obj);
			playheadBar.init(model);
			invoker.setMouseHandler(playheadBar, new InputHandler(new PlayheadBarCommand(model)));
		}
		
		
		/* 
		 * !! Invocar este método sempre DEPOIS de TimelineView!
		 * obj deve ser um MovieClip no palco com outro MovieClip interno (com qualquer nome), centrado na origem (0,0)
		 */
		public function set PlayheadSlider(obj:MovieClip):void {
			var playheadSlider:VideoInterfaceComponent = new PlayheadSlider(obj, playbackWidth);
			playheadSlider.init(model);
			invoker.setHandler(playheadSlider, new InputHandler(new PlayheadSliderCommand(model)));
		}
		
		
		public function set VolumeOnOffBt(obj:MovieClip):void {
			var volumeOnOff:VideoInterfaceComponent = new VolumeOnOff(obj);
			volumeOnOff.init(model);
			invoker.setMouseHandler(volumeOnOff, new InputHandler(new VolumeCommand(model)));
		}
		
		public function setMaxVolume(value:Number):void {
			model.setMaxVolume(value);
		}
		
		/* 
		 * obj é um MovieClip com N MovieClips internos, todos instâncias do mesmo MovieClip
		 * Estas instâncias têm a propriedade name "stepn", com n = 1..N
		 * É assumido por default N = 5;
		 * O MovieClip interno base, tem dois framse "on" e "off"
		 */
		public function setVolumeBt(obj:MovieClip, numSteps:uint = 5):void {
			var volumeBt:VideoInterfaceComponent = new VolumeButton(obj, numSteps);
			volumeBt.init(model);
			invoker.setMouseHandler(volumeBt, new InputHandler(new VolumeCommand(model)));
		}
		
		public function stop():void {
			(videoCollection[model.activeId] as IVideoOutput).stop();
		}
		
		public function setVolume(value:Number):void {
			model.setVolume(value);
			(videoCollection[model.activeId] as IVideoOutput).volume = value;
		}
		
		private function onVideoComplete(evt:Event):void {
			if (_autoplay) {
				if((model.activeId == model.getListLength()-1 && _loop == true) || model.activeId < model.getListLength()-1){
					this.play(model.next());
				}
			}
		}
		
		public function Init():void {
			(videoCollection[model.activeId] as IVideoOutput).init();
		}
		
		public function get video():IVideoOutput
		{
			return (videoCollection[model.activeId] as IVideoOutput);
		}
		
		public function next():void {
			this.play(model.next());
		}
		
		public function previous():void {
			this.play(model.previous());
		}
		
	}
}