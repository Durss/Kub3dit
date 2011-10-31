package  
com.muxxu.kub3dit.engin3d.molehill{

	import flash.display3D.Context3DProgramType;
	public class BackgroundVertexShader  extends AGALMiniAssembler
	{

		public function BackgroundVertexShader() {
			var src:String =
			"m44 op, va0, vc0 \n" +
			"mov v0, va1 \n";
			
			assemble(Context3DProgramType.VERTEX, src);
		}
	}

}