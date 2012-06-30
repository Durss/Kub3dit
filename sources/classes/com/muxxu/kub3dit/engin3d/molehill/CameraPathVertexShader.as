package  
com.muxxu.kub3dit.engin3d.molehill{

	import flash.display3D.Context3DProgramType;
	public class CameraPathVertexShader  extends AGALMiniAssembler
	{

		public function CameraPathVertexShader() {
			//vaX = values from vertex buffer
			//vcX = constants set with setProgramConstantsXX
			//vtX = temporary vertex register
			//vX  = registers to pass data to fragment shader
			var src:String =
			"m44 op, va0, vc0 \n" +
			"mov v0, va1 \n";
			
			assemble(Context3DProgramType.VERTEX, src);
		}
	}

}