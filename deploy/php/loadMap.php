<?php

	header("Content-Type: text/xml");
	require_once("Base62.php");

	/*
	Return codes signification :

	0 - success.
	1 - POST var missing.

	*/

	$dir = '../maps/';
	$result = 1;
	
	if (isset($_GET["id"])) {
		$index = Base62::convert(preg_replace("/[^A-Za-z0-9]/", "", $_GET["id"] ), 62, 10);
		if(file_exists($dir.$index.".png")) {
			//header("Status: 301 Moved Permanently", false, 301);
			//header("Location: ".$dir.$index.".png");
			header('Content-Type: image/png');
			$handler = fopen($dir.$index.".png", 'rb');
			fpassthru($handler);
			exit();
		}
	}else {
		$result = 2;
	}

	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	echo "<root>\r\n";
	echo "\t<result>".$result."</result>\r\n";
	echo "</root>";

?>