package com.smp.api.youtube
{
	
	//info:
	//http://code.google.com/intl/pt-PT/apis/youtube/flash_api_reference.html
	
	
	import com.smp.common.display.loaders.DisplayObjectLoader;
	import com.smp.media.video.IVideoOutput;
	import com.smp.media.video.VideoEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.system.Security;
	import flash.net.URLVariables;

	
	public class  YouTubeVideoEmbeded extends YouTubeVideoInterface implements IVideoOutput
	{
		
		protected var autoPlay:Boolean = false;
		
		public function YouTubeVideoEmbeded(verbose:Boolean = false) {
			
			_verbose = verbose;
			
			Security.allowDomain('s.ytimg.com');
			Security.allowDomain('www.youtube.com');
			Security.allowDomain('s.ytimg.com');
			Security.allowDomain('i.ytimg.com');
		
			_dispSwf = new DisplayObjectLoader("", true, true);
			_dispSwf.addEventListener(Event.COMPLETE, onPlayerReady);
			
		}
		
		override protected function onLoaderInit(event:Event):void {
				//clear default
		}
		

		/**
		 * ignore methods beyond "file"
		 * @param	file
		 */
		override public function load(file:String, loop:Boolean = false, autoplay:Boolean = true, verbose:Boolean = true):void 
		{
			_ready = false;
			_objId = file;
			autoPlay = autoplay;
			
			if(_player != null){
				_player.destroy();
			}
			
			_dispSwf.load("http://www.youtube.com/v/"+_objId+"?version=3&modestbranding=1&rel=0");
			
		}
		
		override public function togglePause():void {
			if(_player != null){
				if (_player.getPlayerState() == 2) {
					
					_player.playVideo();
					_player.seekTo(_time);
				}else if (_player.getPlayerState() == 1) {
					
					_time = _player.getCurrentTime();
					_player.pauseVideo();
				}
			}else {
				handleNoPlayerRequest();
			}
			
		}
		
		override public function stop():void {
			if (_player != null) {
				
				//!! destroys the player !!
				//_player.stopVideo();
				//unstarted (-1), ended (0), playing (1), paused (2), buffering (3), video cued (5).
			
				_time = 0;
				if (_player.getPlayerState() == "2") {
					_player.seekTo(0);
				}
				_player.pauseVideo();
				
				
				
			}else {
				handleNoPlayerRequest();
			}
			
		}
		
		public function unload():void{
			if(_player != null){
				_player.destroy();
			}
			
			_dispSwf.unLoad();
		}
		
		override protected function onPlayerReady(event:Event):void 
		{
			
			//_ready = true;
			_player = _dispSwf.content;
			if (autoPlay) {
				//_player.playVideo();
			}
			dispatchEvent(new Event(Event.COMPLETE));

		}
		
		
	}
	
	
}