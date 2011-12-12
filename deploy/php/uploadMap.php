<?php

	header("Content-Type: text/xml");
	require_once("Base62.php");

	/*
	Return codes signification :

	0 - success.
	1 - POST var missing.

	*/

	$dir = '../maps/';
	$result = 0;
	$extra = "";
	
	if (isset($GLOBALS['HTTP_RAW_POST_DATA'])) {
		$filepath = $dir."index.txt";
		if (!file_exists($filepath)) {
			$handler = fopen($filepath, "w");
			fwrite($handler, "0");
			fclose($handler);
		}
		
		$handler = fopen($filepath, "r+");
		$index = intval(fread($handler, filesize($filepath))) + 1;
		file_put_contents($filepath, $index);
		fclose($handler);
		
		if(@$fp = fopen($dir.$index.".png", 'wb')) {
			fwrite($fp, $GLOBALS[ 'HTTP_RAW_POST_DATA' ]);
			fclose($fp);
			$extra = "\t<fileName><![CDATA[".Base62::convert($index, 10, 62)."]]></fileName>\r\n";
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