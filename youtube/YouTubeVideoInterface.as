package com.smp.api.youtube
{
	
	//info:
	//http://code.google.com/intl/pt-PT/apis/youtube/flash_api_reference.html
	
	
	import com.smp.common.display.loaders.LoadDisplayObject;
	import com.smp.media.video.IVideoOutput;
	import com.smp.media.video.VideoEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.system.Security;
	import flash.net.URLVariables;

	
	public class  YouTubeVideoInterface extends EventDispatcher implements IVideoOutput
	{
		protected var _debug:Boolean;
		protected var _playerid:String;
		
		protected var _dispSwf:LoadDisplayObject
		protected var _player:Object;
		protected var _objId:String = "";
		protected var _ready:Boolean = false;
		protected var _verbose:Boolean;
		protected var _time:Number;
		
		
		public function YouTubeVideoInterface(debug:Boolean = false) {
			
			_debug = debug;
			Security.allowDomain('s.ytimg.com');
			Security.allowDomain('www.youtube.com');
			Security.allowDomain('s.ytimg.com');
			Security.allowDomain('i.ytimg.com');
		
			_dispSwf = new LoadDisplayObject("http://www.youtube.com/apiplayer?version=3", true, false);
			_dispSwf.addEventListener(Event.INIT, onLoaderInit);

			_dispSwf.addEventListener(Event.COMPLETE, onPlayerLoaded);
			
		}
		
		protected function onPlayerLoaded(evt:Event):void {
			
			//
		}
		
		public function getPlayer():DisplayObjectContainer {
			
			return _dispSwf;
			
		}
		
		protected function onLoaderInit(event:Event):void {
			
			_dispSwf.content.addEventListener("onReady", onPlayerReady);
			_dispSwf.content.addEventListener("onError", onPlayerError);
			_dispSwf.content.addEventListener("onStateChange", onPlayerStateChange);
			_dispSwf.content.addEventListener("onPlaybackQualityChange", onVideoPlaybackQualityChange);
		}

		protected function onPlayerReady(event:Event):void 
		{
			// Event.data contains the event parameter, which is the Player API ID 
			trace("player ready:", Object(event).data);
			
			_playerid = Object(event).data.toString();

			// Once this event has been dispatched by the player, we can use
			// cueVideoById, loadVideoById, cueVideoByUrl and loadVideoByUrl
			// to load a particular YouTube video.
			
			_ready = true;
			_player = _dispSwf.content;
			
			dispatchEvent(new Event(Event.COMPLETE));

			 
			if (_objId != "") {
				_player.loadVideoById(_objId);
			}
		}

		private function onPlayerError(event:Event):void {
			// Event.data contains the event parameter, which is the error code
			trace("player error:", Object(event).data);
			//throw new Error("YouTubePlayer - loading failed: " + Object(event).data);
			
			dispatchEvent(new VideoEvent(VideoEvent.STREAM_ERROR));
		}

		private function onPlayerStateChange(event:Event):void {
			// Event.data contains the event parameter, which is the new player state
			trace("player state:", Object(event).data);
			
			dispatchEvent(new VideoEvent(VideoEvent.PLAY_CHANGED));
		}

		private function onVideoPlaybackQualityChange(event:Event):void {
			// Event.data contains the event parameter, which is the new video quality
			trace("video quality:", Object(event).data);
		}

		
		//YouTube URL related methods
		
		public function getVideoImage(videoid:String):String {
			return "http://img.youtube.com/vi/"+videoid+"/0.jpg";
		}
		
		public function getVideoThumb(videoid:String):String {
			return "http://img.youtube.com/vi/"+videoid+"/1.jpg";
		}
		
		public function getVideoPreview(videoid:String):String {
			return "http://img.youtube.com/vi/"+videoid+"/0.jpg";
		}
		
		public function getVideoPublicUrl(videoid:String):String {
			return "http://www.youtube.com/watch?v=" + videoid;
		}
		
		public function getVideoUrl(videoid:String):String {
			return "http://www.youtube.com/v/" + videoid;
		}
		
		public function getVideoIdByUrl(url:String):String 
		{
			var queryInit:int
			
			//search for id on a video url: /v/videoid
			var vparampos:int = url.indexOf("/v/");
			if (vparampos > 0) {
				vparampos += 3;
				queryInit = url.lastIndexOf("?");
				if(queryInit > 0){
					return url.substring(vparampos, queryInit);
				}else {
					return url.substring(vparampos);
				}
			}else {
				//search for id on a video public url: /watch?v=
				
				queryInit = url.lastIndexOf("?") + 1;
				var query:String = url.substring(queryInit, url.length);
				var queryVars:URLVariables = new URLVariables();
				
				try {
					queryVars.decode(query);
				}catch (err:Object) {
					return "";
				}
				
				if(queryVars.v){
					return queryVars.v;
				}
			}
			
			return "";
		}
		
		public function getActiveVideoId():String {
			return _objId;
		}
		
		// END: YouTube URL related methods
		
		
		
		// IVideoOutput defined methods
		
		public function load(file:String, loop:Boolean = false, autoplay:Boolean = true, verbose:Boolean = true):void 
		{
			_objId = file;
			if (_ready == true) {
				_player.loadVideoById(_objId);
			}else {
				handleNoPlayerRequest();
			}
		}
		
		public function get loadPercent():int {
			return 0;
		}
		
		public function get loaded():Boolean{
			return _ready;
		}
		
		public function get length():Number {
			if (_ready == true) {
				return _player.getDuration();
			}else {
				handleNoPlayerRequest();
			}
			return 0;
		}
		public function get time():Number {
			if (_ready == true) {
				return _player.getCurrentTime();
			}else {
				handleNoPlayerRequest();
			}
			return 0;
		}
		public function set time(seconds:Number):void {
			if (_ready == true) {
				_time = seconds;
				if (_player.getPlayerState() == 2 || _player.getPlayerState() <= 0) {
					
					_player.seekTo(seconds, true);
					_player.pauseVideo();
				}else if (_player.getPlayerState() == 1 || _player.getPlayerState() == 3 || _player.getPlayerState() == 5) {
					_player.seekTo(seconds, true);
				}
			}else {
				handleNoPlayerRequest();
			}
		}
		public function set videoWidth(largura:Number){
			
		}
		public function set videoHeight(altura:Number){
			
		}
		public function get videoWidth():Number{
			return 0;
		}
		public function get videoHeight():Number{
			return 0;
		}
		public function setSize(width:Number, height:Number):void {
			if (_ready == true) {
				_player.setSize(width, height);
			}else {
				handleNoPlayerRequest();
			}
		}
		public function rescale(width:Number = 0, height:Number = 0):void
		{
			//cromless player default size: 320px by 240px
			if (_ready == true) {
				if(width > 0){			
					_player.setSize(width, 240 / 320 * width);
				}else if(height > 0){
					_player.setSize(240 / 320 * height, height);
				}
			}else {
				handleNoPlayerRequest();
			}
		}
		public function init():void {
			if (_ready == true) {
				_player.playVideo();
			}else {
				handleNoPlayerRequest();
			}
		}
		public function stop():void {
			if (_ready == true) {
				//!! destroys the player !!
				//_player.stopVideo();
				_time = 0;
				_player.pauseVideo();
				_player.seekTo(0);
				
			}else {
				handleNoPlayerRequest();
			}
			
		}
		public function clear():void {
			if (_ready == true) {
				_player.destroy();
			}else {
				handleNoPlayerRequest();
			}
			
		}
		public function togglePause():void {
			if (_ready == true) {
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
		public function get playing():Boolean 
		{
			if (_ready == true) {
				if(_player.getPlayerState() == 1){
					return true;
				}else if (_player.getPlayerState() == 2 || _player.getPlayerState() <= 0) {
					return false;
				}
			}else {
				handleNoPlayerRequest();
			}
			
			return false;
		}
		
		/**
		 * @value : from 0 to 1 converted into 0 - 100
		 */
		public function set volume(value:Number):void {
			if (_ready == true) {
				_player.setVolume(value*100);
			}else {
				handleNoPlayerRequest();
			}
			
		}
		
		/**
		 * @return : from 0 to 100
		 */
		public function get volume():Number {
			if (_ready == true) {
				return _player.getVolume();
			}else {
				handleNoPlayerRequest();
			}
			return 0;
		}
		public function set loop(value:Boolean):void{
			
		}
		public function get loop():Boolean{
			return false;
		}
		
		
		// END: IVideoOutput defined methods
		
		
		private function handleNoPlayerRequest():void {
			if(_debug){
				throw new Error("YouTubeVideoInterface: YouTube Player not loaded yet. Wait for Event.COMPLETE.");
			}
		}
		
		
	}
	
	
}