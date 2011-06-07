package srg.google.maps.extensions
{
	import flash.display.*;
	import flash.geom.Point;

	import com.google.maps.LatLng;
	import com.google.maps.geom.Point3D;
	import com.google.maps.interfaces.IMap3D;
	import com.google.maps.interfaces.ICamera;
	import com.google.maps.geom.TransformationGeometry;

	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.objects.DisplayObject3D;

	public class CameraMap3D extends Camera3D
	{
		private var mMap3D:IMap3D;
		private var mOrigin:LatLng;

		function CameraMap3D(map:IMap3D, fov:Number=60, near:Number=10, far:Number=5000, useCulling:Boolean=false, useProjection:Boolean=true)
		{
			super(fov, near, far, useCulling, useProjection);
			
			mMap3D = map;
			
		}

		public function set origin(o:LatLng):void
		{
			mOrigin = o;
		}

		public override function lookAt( targetObject:DisplayObject3D, upAxis:Number3D=null ):void
        {
			// do nothing
		}

		public override function transformView(transform:Matrix3D=null):void
		{
			// do nothing
			
		}

		private var _tm1:Matrix3D = Matrix3D.IDENTITY;
		private var _tm2:Matrix3D = Matrix3D.IDENTITY;
		private var _tm3:Matrix3D = Matrix3D.IDENTITY;

		public static const WORLD_LEN:Number = 40075016.685578486;

		// Google Maps' world coord -> meter
		public static const WM:Number = WORLD_LEN / 256.0;

		public function sync():void
		{
			if (!mOrigin)
				return;

			var mapCam:ICamera = mMap3D.camera;
			var mapCenterW:Point = mapCam.latLngToWorld(mapCam.center);
			var g:TransformationGeometry = mapCam.getTransformationGeometry();
			var m:Matrix3D = this.eye;
			var pt:Point = mapCam.latLngToWorld(mOrigin);

			const zs:Number     = near - far;
			const f:Number      = g.focalLength;
			const vw:Number     = g.viewportSize.x;
			const vh:Number     = g.viewportSize.y;
			const aspect:Number = vw / vh;

			_tm1.n11 = f / aspect;  _tm1.n21 = 0;  _tm1.n31 = 0;              _tm1.n41 =  0;
			_tm1.n12 = 0;           _tm1.n22 = f;  _tm1.n32 = 0;              _tm1.n42 =  0;
			_tm1.n13= 0;            _tm1.n23 = 0;  _tm1.n33 = -(near+far)/zs; _tm1.n43 =  1;
			_tm1.n14 = 0;           _tm1.n24 = 0;  _tm1.n34 =  2*near*far/zs; _tm1.n44 =  0;

			// normalize fov
			_tm1.n11 /= vh*.5;
			_tm1.n22 /= vh*.5;

			const cvP:Point3D = g.cameraPosition;
			const cvX:Point3D = g.cameraXAxis;
			const cvY:Point3D = g.cameraYAxis;
			const cvZ:Point3D = g.cameraZAxis;

			_tm2.n11 = -cvX.x;  _tm2.n21 = -cvY.x;  _tm2.n31 = cvZ.x; _tm2.n41 = 0;
			_tm2.n12 = -cvX.y;  _tm2.n22 = -cvY.y;  _tm2.n32 = cvZ.y; _tm2.n42 = 0;
			_tm2.n13 = -cvX.z;  _tm2.n23 = -cvY.z;  _tm2.n33 = cvZ.z; _tm2.n43 = 0;
			_tm2.n44 = 1;

			const camDX:Number = (mapCenterW.x-cvP.x) * WM;
			const camDY:Number = (mapCenterW.y-cvP.y) * WM;
			const camDZ:Number =               cvP.z  * WM;
			var camZ:Number = Math.sqrt( camDX*camDX + camDY*camDY + camDZ*camDZ );

			_tm2.n14 = 0;
			_tm2.n24 = 0;
			_tm2.n34 = camZ;

			_tm3.n14 = (mapCenterW.x-pt.x) * WM;
			_tm3.n24 = (mapCenterW.y-pt.y) * WM;

			m.calculateMultiply4x4(_tm1, _tm2);
			m.calculateMultiply4x4(m, _tm3);
		}
	}
}
