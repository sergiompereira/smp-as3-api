package srg.google.maps.extensions
{
	import com.google.maps.MapEvent;
	
	public class Map3DEvent extends MapEvent
	{
		
		public static const UPDATE:String = "update";
		public static const READY:String = "ready";
		
		public function Map3DEvent(type:String, feature:Object, bubbles:Boolean = false, cancellable:Boolean = false){
			super(type, feature, bubbles, cancellable);
		}
	}
}