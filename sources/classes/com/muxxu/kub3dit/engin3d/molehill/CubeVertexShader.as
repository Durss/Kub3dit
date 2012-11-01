package  
com.muxxu.kub3dit.engin3d.molehill{

	import flash.display3D.Context3DProgramType;
	public class CubeVertexShader  extends AGALMiniAssembler
	{

		public function CubeVertexShader() {
			//vaX = values from vertex buffer
			//vcX = constants set with setProgramConstantsXX
			//vtX = temporary vertex register
			//vX  = registers to pass data to fragment shader
			 
			var src:String =
			"m44 vt0, va0, vc0 \n" + //transform vertex x,y,z
			"mov op, vt0 \n" +       //output vertex x,y,z
			
			//Data sent to fragment shader
			"mov v0, va1 \n" +//uv
			"mov v1, va2 \n" +//brightness
			"mov v2, va0 \n";// xuy
			
			assemble(Context3DProgramType.VERTEX, src);
		}
	}

}