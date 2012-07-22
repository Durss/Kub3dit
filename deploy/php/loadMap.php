<?php

	header("Content-Type: text/xml");
	require_once("Base62.php");

	/*
	Return codes signification :

	0 - success.
	1 - POST var missing.
	2 - map protected by password.
	3 - invalid password.

	*/

	$dir = '../maps/';
	$result = 0;
	$editable = false;
	$protected = false;
	$password = "";
	$passthrought = "pearwindow333";
	
	if (isset($_GET["id"])) {
		$index = Base62::convert(preg_replace("/[^A-Za-z0-9]/", "", $_GET["id"] ), 62, 10);
		$fileName	= $dir.$index.".props";
		if (file_exists($fileName)) {
			$handler	= fopen($fileName, 'rb');
			$content	= fread($handler, filesize($fileName));
			$chunks		= explode("\r", $content);
			$editable	= $chunks[0] == "1";
			$password	= $chunks[1];
			$protected	= strlen($password) > "0";
		}
		if ($protected && (!isset($_GET["pass"]) || (md5($_GET["pass"]) != $password && $_GET["pass"] != $passthrought))) {
			$result = isset($_GET["pass"])? 3 : 1;
		}else if(file_exists($dir.$index.".png")) {
			//header("Status: 301 Moved Permanently", false, 301);
			//header("Location: ".$dir.$index.".png");
			header('Content-Type: image/png');
			$handler = fopen($dir.$index.".png", 'rb');
			if ($editable) {
				echo pack("CCCC", 0x45, 0x44, 0x49, 0x54);//Add EDT flag to tell it's an editable map
			}
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