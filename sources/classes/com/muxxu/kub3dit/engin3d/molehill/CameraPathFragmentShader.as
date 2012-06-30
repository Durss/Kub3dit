package  
com.muxxu.kub3dit.engin3d.molehill{

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	public class CameraPathFragmentShader extends AGALMiniAssembler
	{

		public function CameraPathFragmentShader(context:Context3D) {
			context;//avoid unused warning
			
			var src:String = 
//			"mov ft0, fs0 \n" +
			"mov oc, v0 \n";
			
			assemble(Context3DProgramType.FRAGMENT, src);
		}
	}

}