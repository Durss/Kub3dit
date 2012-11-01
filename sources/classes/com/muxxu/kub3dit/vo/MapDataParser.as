package com.muxxu.kub3dit.vo {
	import com.muxxu.kub3dit.engin3d.camera.Camera3D;
	import com.muxxu.kub3dit.engin3d.map.Map;
	import com.muxxu.kub3dit.engin3d.map.Textures;
	import com.muxxu.kub3dit.exceptions.Kub3ditException;
	import com.muxxu.kub3dit.exceptions.Kub3ditExceptionSeverity;
	import com.nurun.structure.environnement.label.Label;

	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author Francois
	 * @date 19 avr. 2012;
	 */
	public class MapDataParser {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MapDataParser</code>.
		 */
		public function MapDataParser() {
			
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Parses a ByteArray and extracts map's data from it.
		 * 
		 * @param data				ByteArray to parse
		 * @param configureCamera	defines if the camera should be configured or not with the data eventually specified inside the ByteArray.
		 * @param adaptSizes		adapts the sizes of the map to chunks sizes.
		 * @param map				optional Map instance. If defined, the instance is updated. Else a new one is created.
		 * 
		 * @throws Kub3ditException if the file type is unknown
		 */
		public static function parse(data:ByteArray, configureCamera:Boolean = true, adaptSizes:Boolean = true, map:Map = null):Map {
			if(map == null) map = new Map(adaptSizes);
			
			data.position = 0;
			//Search for PNG signature
			if(data.readUnsignedInt() == 0x89504e47) {
				data.position = data.length - 4;
				//search for ".K3D" signature at the end
				if(data.readUnsignedInt() == 0x2e4b3344) {
					data.position = data.length - 4 - 4;
					var dataLen:Number = data.readUnsignedInt();
					data.position = data.length - 4 - 4 - dataLen;
					var tmp:ByteArray = new ByteArray();
					tmp.writeBytes(data, data.position, dataLen);
					data = tmp;
					data.position = 0;
				}
			}else{
				data.position == 0;
			}
			try {
				data.uncompress();
				data.position = 0;
			}catch(error:Error) {
				throw new Kub3ditException(Label.getLabel("unkownSaveFileType"), Kub3ditExceptionSeverity.MINOR);
				return null;
			}
			
			//new FileReference().save(data, "test.bin");//export uncompressed map for debug purpose
			
			var fileVersion:int = data.readByte();
			var parsePaths:Boolean;
			switch(fileVersion){
					
				case Constants.MAP_FILE_TYPE_1:
					map.load(data);
					break;
				
				case Constants.MAP_FILE_TYPE_3:
					parsePaths = true;
					
				case Constants.MAP_FILE_TYPE_2:
					var customs:uint = data.readUnsignedByte();
					var i:int, len:int, cube:CubeData;
					for(i = 0; i < customs; ++i) {
						len = data.readShort();
						cube = new CubeData();
						cube.populate(new XML(data.readUTFBytes(len)));
						Textures.getInstance().addKube(cube);
					}
					
					if(configureCamera) {
						Camera3D.configure(data, parsePaths);
					}else{
						data.position += 2*3 + 4 + 4;//Skip camera infos
					}
					
					if(parsePaths) {
						var paths:Array = data.readObject();
						map.setCameraPaths( paths );
					}else{
						map.setCameraPaths( [] );
					}
					
					map.load(data);
					break;
				
				default:
					throw new Kub3ditException(Label.getLabel("unkownSaveFileType"), Kub3ditExceptionSeverity.MINOR);
			}
			
			return map;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}