package  
com.muxxu.kub3dit.engin3d.molehill{

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	public class CubeFragmentShader  extends AGALMiniAssembler
	{

		public function CubeFragmentShader(context:Context3D, accelerated:Boolean) {
			context;//avoid unused warning
			var src:String =
			"mov ft0, v0 \n" +//UV data
			"mov ft3, v1 \n" +//Alpha
			"mov ft4, v2 \n" +//Brightness
			"tex ft1, ft0, fs0 <2d,repeat,nearest> \n";
			
			if(accelerated) {
				//Fog management
				//*
	//			compute distance from the camera's position : sqrt((xa-xb)² + (yb-ya)²)
				src += 
				"sub ft5, fc0.x, v3.x \n" +
				"mul ft5, ft5, ft5 \n" +
				"sub ft6, fc0.y, v3.y \n" +
				"mul ft6, ft6, ft6 \n" +
				"add ft5, ft6, ft5 \n" +
				"sqt ft5, ft5 \n" +
	//			compute this : (8-(max(N, 80)-80))/8
				"max ft6, fc0.w, ft5 \n" +
				"sub ft6, ft6, fc0.w \n" +
				"sub ft6, fc0.z, ft6 \n" +
				"div ft6, ft6, fc0.z \n" +
				"mul ft1.w, ft6, ft1.w \n" +
				//*/
				
				//Alpha
				"mul ft1.w, ft3.x, ft1.w \n" +
				
				//Brightness
				"mul ft5, ft4.x, ft1.xyz \n" +
				"mov ft5.w, ft1.w \n";
			}else{
				src += "mov ft5 ft1\n";
			}
			
			src += "mov oc, ft5 \n";
			
			assemble(Context3DProgramType.FRAGMENT, src);
		}
	}

}