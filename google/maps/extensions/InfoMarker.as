package srg.google.maps.extensions
{
	
	import com.google.maps.overlays.Marker;
	import com.google.maps.LatLng;
	import com.google.maps.overlays.MarkerOptions;
	
	public class InfoMarker extends Marker 
	{
		protected var _id:uint;
		
		public function InfoMarker(latLng:LatLng, options:MarkerOptions = null) {
			super(latLng, options);
		}
		
		public function set id(value:uint) {
			_id = value;
		}
		
		public function get id():uint {
			return _id;
		}
	}
	
}