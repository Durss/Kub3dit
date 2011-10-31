package  
com.muxxu.kub3dit.engin3d.molehill{

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	public class BackgroundFragmentShader  extends AGALMiniAssembler
	{

		public function BackgroundFragmentShader(context:Context3D) {
			context;//avoid unused warning
			
			var src:String =
			"mov ft0, v0 \n" +
			"tex ft1, ft0, fs0 <2d,repeat,nearest> \n" +
			"mov oc, ft1 \n";
			
			assemble(Context3DProgramType.FRAGMENT, src);
		}
	}

}