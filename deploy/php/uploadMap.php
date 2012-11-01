<?php

	header("Content-Type: text/xml");
	require_once("Base62.php");

	/*
	Return codes signification :

	0 - success.
	1 - POST var missing.
	2 - not editable map.
	3 - wrong password.

	*/

	$dir = '../maps/';
	$result = 0;
	$extra = "";
	$updateMode = false;
	
	if (isset($GLOBALS['HTTP_RAW_POST_DATA'], $_GET["mod"], $_GET["pass"])) {
		$filepath = $dir."index.txt";
		if (!file_exists($filepath)) {
			$handler = fopen($filepath, "w");
			fwrite($handler, "0");
			fclose($handler);
		}
		
		//Update mode management
		if (isset($_GET["uid"]) && strlen($_GET["uid"]) > 0) {
			$index = Base62::convert($_GET["uid"], 62, 10);
			$updateMode = true;
			
			$fileName	= $dir.$index.".props";
			if (file_exists($fileName)) {
				$handler	= fopen($fileName, 'rb');
				$content	= fread($handler, filesize($fileName));
				$chunks		= explode("\r", $content);
				$editable	= $chunks[0] == "1";
			}else {
				$editable	= false;
			}
			
			if (!$editable) {
				$result = 2;
			}
			
			if (count($chunks) > 1 && strlen($chunks[1]) > 0 && md5($_GET["pass"]) != $chunks[1]) {
				$result = 3;
			}
		}else{
			//Get last index
			$handler = fopen($filepath, "r+");
			$index = intval(fread($handler, filesize($filepath))) + 1;
			file_put_contents($filepath, $index);
			fclose($handler);
		}
		
		if($result == 0) {
		
			//Create props file
			$propsPath = $dir.$index.".props";
			if (!$updateMode && !file_exists($propsPath)) {//do not override the .props file in case of update.
				$handler = fopen($propsPath, "w");
				fwrite($handler, $_GET["mod"]."\r".(strlen($_GET["pass"]) > 0? md5($_GET["pass"]) : ""));
				fclose($handler);
			}
			
			//create map
			if(@$fp = fopen($dir.$index.".png", 'wb')) {
				fwrite($fp, $GLOBALS[ 'HTTP_RAW_POST_DATA' ]);
				fclose($fp);
				$extra = "\t<fileName><![CDATA[".Base62::convert($index, 10, 62)."]]></fileName>\r\n";
			}
		}
	}else {
		$result = 1;
	}

	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	echo "<root>\r\n";
	echo "\t<result>".$result."</result>\r\n";
	echo $extra;
	echo "</root>";

?>