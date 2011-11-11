<?php
	session_start();
	
	$betaMode = false;
	
	//Redirect the user if "www" are on the address. Prevents from SharedObject problems.
	if (strpos($_SERVER["SERVER_NAME"], "www") > -1) {
		header("location: http://fevermap.org/kub3dit");
		die;
	}
	
	//header('Content-type: text/html; charset=iso-8859-1');
	$pseudo = "";
	if(strpos($_SERVER["HTTP_REFERER"], "as3game.blogspot.com")) {
		$pseudo = "authorizedReferer";
		$_GET["lang"] = "en";
	}
	if(isset($_GET['uid'], $_GET['pubkey'])) {
		$url = "http://muxxu.com/app/xml?app=kub3dit&xml=user&id=".$_GET['uid']."&key=".md5("ad10c672ca9b23cad961163da05071ed" . $_GET["pubkey"]);
		$xml = simplexml_load_file($url);
		preg_match('/name="(.*?)"/', $xml, $matches); //*? = quantificateur non gourmand
		if ($xml->getName() != "error") {
			if (!isset($_GET["lang"])) $_GET["lang"] = $xml->attributes()->lang;
			$pseudo	= (string)$xml->attributes()->name;//Force string conversion
		}
	}
	
	/**
	 * Checks if a user is on the authorized groups.
	 */
	function isUserOnGroup($pseudo, $url) {
		$handle = fopen($url, "rb");
		$content = '';
		while (!feof($handle)) {
		  $content .= fread($handle, 8192);
		}
		fclose($handle);
		
		$result = str_replace("\n", "", $content);
		$result = str_replace("\r", "", $result);
		$result = preg_replace('/"prevuser".*<\/li>/imU', "", $result);
		return stripos($result, $pseudo) !== false;
	}
	
	function isAuthorizedUser($pseudo, $ref) {
		return strtolower($pseudo) == $ref || (isset($_SESSION["uname"]) && strtolower($_SESSION["uname"]) == $ref);
	}
	//$authorized = isUserOnGroup($pseudo, "http://muxxu.com/g/atlantes/members");
	//$authorized = $authorized || isUserOnGroup($pseudo, "http://muxxu.com/g/motiontwin/members");
	//$authorized = $authorized || isUserOnGroup($pseudo, "http://muxxu.com/g/architectoire/members");
	$authorized = isAuthorizedUser($pseudo, "dursss");
	$authorized = $authorized || isAuthorizedUser($pseudo, "authorizedreferer");
	
	if ($authorized) {
		if (!isset($_SESSION["uname"])) {
			$_SESSION["uname"] = $pseudo;
		}
	}else {
		unset( $_SESSION["uname"] );
	}
	
	//Redirect the user
	if (!$authorized && !isset($_SESSION["uname"])) {
		if (isset($_GET['uid'], $_GET['pubkey'])) {
			header("location: ./closed");
		}else {
			header("location: http://muxxu.com/a/kub3dit");
		}
		die;
	} else if(isset($_GET['uid'], $_GET['pubkey'])) {
		header("location: redirect.php");
		die;
	}else{
		header("Cache-Control: no-cache, must-revalidate");
		header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	}
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml">
	<head>
		<title>Kub3dit</title>
		<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
		<link rel="shortcut icon" href="./favicon.ico" />
		<style type="text/css">
		html, body {
			overflow:hidden;
			height:100%;
			margin:0;
			padding:0;
			font-family: Trebuchet MS,Arial,sans-serif;
		}
		body {
			font: 86 % Arial, "Helvetica Neue", sans - serif;
			color:#000000;
			margin: 0;                
		}
		</style>
		
		<script type="text/javascript" src="js/swfwheel.js"></script>
		<script type="text/javascript" src="js/swfobject.js"></script>
		<script type="text/javascript">
			
		  var _gaq = _gaq || [];
		  _gaq.push(['_setAccount', 'UA-21417708-1']);
		  _gaq.push(['_setCookiePath', '/kub3dit/']); 
		  _gaq.push(['_trackPageview']);

		  (function() {
			var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
			ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
			var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
		  })();

		</script>
    </head>
    <body>
<?php
		if (isset($_GET["lang"]) && file_exists("xml/i18n/labels_".strtolower($_GET["lang"]).".xml")) {
			$lang = $_GET["lang"];
		}else {
			$lang = "fr";
		}
?>
		<div id="content">
			<p>In order to view this page you need JavaScript and Flash Player 11+ support!</p>
			<a href="http://get.adobe.com/fr/flashplayer/">Install flash</a>
		</div>
		
		<script type="text/javascript">
			// <![CDATA[
			var version = "2";
			var so = new SWFObject('swf/application.swf?v='+version, 'content', '100%', '100%', '11', '#47A9D1');
			so.useExpressInstall('swf/expressinstall.swf');
			so.addParam('allowFullScreen', 'true');
			so.addParam('menu', 'false');
			so.addParam('wmode', 'direct');
			so.setAttribute("id", "externalDynamicContent");
			so.setAttribute("name", "externalDynamicContent");
			so.addVariable("version", version);
			so.addVariable("configXml", "./xml/config.xml?v="+version);
			so.addVariable("lang", "<?php echo $lang; ?>");
			so.write('content');
			/*]]>*/
		</script>
	</body>
</html>