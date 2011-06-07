package srg.google.maps.extensions
{
	import flash.display.DisplayObject;
	
	import com.google.maps.overlays.OverlayBase;
	import com.google.maps.LatLng;
	
	
	public class CustomOverlayBase extends OverlayBase 
	{
		protected var _id:uint;
		protected var _view:DisplayObject;
		
		public function CustomOverlayBase(obj:DisplayObject) {
			_view = obj;
			addChild(_view);
			
			super();
		}
		
		public function set id(value:uint) {
			_id = value;
		}
		
		public function get id():uint {
			return _id;
		}
	}
	
}