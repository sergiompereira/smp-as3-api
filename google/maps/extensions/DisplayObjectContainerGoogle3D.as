package srg.google.maps.extensions
{
	import org.papervision3d.objects.DisplayObject3D;
	
	
	public class DisplayObjectContainerGoogle3D extends
	{
		public var lat:Number     = NaN;
		public var lng:Number     = NaN;
		public var alt:Number     = 0;
		
		protected var objectCollection:Array = new Array();
		
		public function addChild(obj:DisplayObject3D):void {
			objectCollection.push(obj);
			addChild(obj);
		}

		public function get hasLatLng():Boolean
		{
			return !isNaN(lat) && !isNaN(lng);
		}
		
	}
}
