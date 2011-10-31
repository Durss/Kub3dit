package  
com.muxxu.kub3dit.engin3d.molehill{

	import flash.display3D.Context3DProgramType;
	public class CubeVertexShader  extends AGALMiniAssembler
	{

		public function CubeVertexShader() {
			var src:String =
			"m44 vt0, va0, vc0 \n" + //transform vertex x,y,z
			"mov op, vt0 \n" +       //output vertex x,y,z
			"mov v0, va1 \n" +
			"mov v1, va2 \n" +
			"mov v2, va3 \n" +
			"mov v3, va0 \n"; 
//			"mov v3, vt0.z \n"; 
			
			assemble(Context3DProgramType.VERTEX, src);
		}
	}

}