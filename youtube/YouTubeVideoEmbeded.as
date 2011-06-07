package srg.youtube
{
	
	//info:
	//http://code.google.com/intl/pt-PT/apis/youtube/flash_api_reference.html
	
	
	import srg.display.loaders.LoadDisplayObject;
	import srg.media.video.IVideoOutput;
	import srg.media.video.VideoEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.system.Security;
	import flash.net.URLVariables;

	
	public class  YouTubeVideoEmbeded extends YouTubeVideoInterface implements IVideoOutput
	{
	
		public function YouTubeVideoEmbeded(verbose:Boolean = false) {
			
			_verbose = verbose;
			
			Security.allowDomain('s.ytimg.com');
			Security.allowDomain('www.youtube.com');
			Security.allowDomain('s.ytimg.com');
			Security.allowDomain('i.ytimg.com');
		
			_dispSwf = new LoadDisplayObject("", true, true);
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
			
			if(_player != null){
				_player.destroy();
			}
			
			_dispSwf.Load("http://www.youtube.com/v/"+_objId+"?version=3");
			
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
			
			dispatchEvent(new Event(Event.COMPLETE));

		}
		
		
	}
	
	
}