package  
com.muxxu.kub3dit.engin3d.molehill{

	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	public class ShaderProgram
	{
		public var program : Program3D = null;
		
		public function ShaderProgram(context : Context3D, vsh : AGALMiniAssembler, fsh : AGALMiniAssembler)
		{
			program = context.createProgram();
			program.upload(vsh.agalcode, fsh.agalcode);
		}
	}

}