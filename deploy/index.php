<?php
	session_start();
	
	$betaMode = false;
	$redirectWithMap = false;
	
	//Redirect the user if "www" are on the address. Prevents from SharedObject problems.
	if (strpos($_SERVER["SERVER_NAME"], "www") > -1) {
		header("location: http://fevermap.org/kub3dit");
		die;
	}
	
	if(!isset($_GET["lang"]) && !isset($_SESSION["lang"])) {
		function get_client_language($availableLanguages, $default='en'){
			
			if (isset($_SERVER['HTTP_ACCEPT_LANGUAGE'])) {
					
				$langs=explode(',',$_SERVER['HTTP_ACCEPT_LANGUAGE']);

				//start going through each one
				foreach ($langs as $value){
					$choice=substr($value,0,2);
					if(in_array($choice, $availableLanguages)){
						return $choice;
					}
				}
			} 
			return $default;
		}
		$lang = $_SESSION["lang"] = get_client_language(array('fr', 'en'));
	} else {
		$lang = isset($_GET["lang"])? $_GET["lang"] : (isset($_SESSION["lang"])? $_SESSION["lang"] : "en");
	}
	
	//=========================================
	//=============== BETA MODE ===============
	//=========================================
	if($betaMode) {
		//header('Content-type: text/html; charset=iso-8859-1');
		$pseudo = isset($_SESSION["uname"])? $_SESSION["uname"] : "";
		/*
		if(isset($_SERVER["HTTP_REFERER"]) && strpos($_SERVER["HTTP_REFERER"], "as3game.blogspot.com")) {
			$pseudo = "authorized_referer";
			$lang = "en";
		}*/
		if(isset($_GET['uid'], $_GET['pubkey'])) {
			$url = "http://muxxu.com/app/xml?app=kub3dit&xml=user&id=".$_GET['uid']."&key=".md5("ad10c672ca9b23cad961163da05071ed" . $_GET["pubkey"]);
			$xml = simplexml_load_file($url);
			if ($xml->getName() != "error") {
				if (!isset($_GET["lang"])) {
					$lang = (string)$xml->attributes()->lang;
				}
				$pseudo	= (string)$xml->attributes()->name;
			}else {
				$pseudo = "goFuckYourself";
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
			return strtolower($pseudo) == $ref;
		}
		
		$authorized = false;//isAuthorizedUser($pseudo, "durss");//uncoment to authorize only me
		$authorized = $authorized || isAuthorizedUser($pseudo, "ebene");
		$authorized = $authorized || isAuthorizedUser($pseudo, "aerynsun");
		$authorized = $authorized || isAuthorizedUser($pseudo, "mllenolwenn");
		$authorized = $authorized || isAuthorizedUser($pseudo, "musaran");
		$authorized = $authorized || isAuthorizedUser($pseudo, "lwxtz2004");
		$authorized = $authorized || isAuthorizedUser($pseudo, "oshyso");
		$authorized = $authorized || isAuthorizedUser($pseudo, "metylene");
		
		/*
		$dateEnd = DateTime::createFromFormat('d/m/Y', '05/03/2012');
		$dateStart = DateTime::createFromFormat('d/m/Y', '27/02/2012');
		if (DateTime::createFromFormat('d/m/Y', date("d/m/Y")) >= $dateStart && DateTime::createFromFormat('d/m/Y', date("d/m/Y")) <= $dateEnd) {
			$authorized = $authorized || isAuthorizedUser($pseudo, "concours_ES");
		}*/
		$authorized = $authorized || isAuthorizedUser($pseudo, "authorized_referer");
		$authorized = $authorized || isUserOnGroup($pseudo, "http://muxxu.com/g/atlantes/members");
		$authorized = $authorized || isUserOnGroup($pseudo, "http://muxxu.com/g/motiontwin/members");
		$authorized = $authorized || isUserOnGroup($pseudo, "http://muxxu.com/g/architectoire/members");
		
		if ($authorized) {
			//if (!isset($_SESSION["uname"])) {
				$_SESSION["uname"] = $pseudo;
				$_SESSION["lang"] = $lang;
			//}
		}else {
			unset( $_SESSION["uname"] );
		}
	}
		
	//Redirect the user
	if ($betaMode && !$authorized && !isset($_SESSION["uname"])) {
		if (isset($_GET['uid'], $_GET['pubkey'])) {
			header("location: ./closed");
			die;
		}else {
			$redirectWithMap = true;
		}
	}else if (isset($_GET['uid'], $_GET['pubkey'])) {// && !isset($_GET['s']) ) {
		if ($_SERVER["SERVER_NAME"] == "localhost") {
			$url = "http://localhost/kub3dit/";
		}else {
			if (isset($_GET["act"])) {
				$url = "http://fevermap.org/kub3dit/%23".$_GET["act"];
			}else {
				$url = "http://fevermap.org/kub3dit/";
			}
		}
		header("location: redirect.php?url=".$url);//."&pubkey=".$_GET["pubkey"]."&uid=".$_GET["uid"]);
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
		<meta name = "viewport" content = "initial-scale = 1.0, user-scalable = no">
		<link rel="shortcut icon" href="./favicon.ico" />
		<style type="text/css">
		html, body {
			overflow:hidden;
			width:100%;
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
		
		<script type="text/javascript" src="js/swfobject.js"></script>
		<script type="text/javascript" src="js/SWFAddress.js"></script>
		<script type="text/javascript" src="js/swfwheel.js"></script>
		<script type="text/javascript" src="js/swffit.js"></script>
		<script type="text/javascript" src="js/detect-zoom.js"></script>
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
			
			function enableExitAlert() {
				window.onbeforeunload = confirmExit;
				function confirmExit() {
					return "";
				}
			}
		</script>
    </head>
    <body>
<?php
		if($redirectWithMap) {
			echo "		<script type=\"text/javascript\">
				var anchor = self.document.location.hash.substring(1);
				window.location = \"http://muxxu.com/a/kub3dit?act=\"+anchor;
			</script>\n";
			echo "	</body>\n";
			echo "</html>";
			die;
		}

		if (isset($lang) && !file_exists("xml/i18n/labels_".strtolower($lang).".xml")) {
			$lang = "en";
		}
?>
		<div id="content1">
		<div id="content">
			<p>In order to view this page you need JavaScript and Flash Player 11+ support!</p>
			<a href="http://get.adobe.com/fr/flashplayer/">Install flash</a>
		</div>
		</div>
		
		<script type="text/javascript">
<?php
	$version= "16.8.9";
?>
			var flashvars = {};
			flashvars["version"] = "<?php echo $version; ?>";
			flashvars["configXml"] = "./xml/config.xml?v=<?php echo $version; ?>";
			flashvars["lang"] = "<?php echo $lang; ?>";
			
			var attributes = {};
			attributes["id"] = "externalDynamicContent";
			attributes["name"] = "externalDynamicContent";
			
			var params = {};
			params['allowFullScreen'] = 'true';
			params['allowFullScreenInteractive'] = 'true';
			params['menu'] = 'false';
			params['wmode'] = 'direct';
			
			var browserWinWidth = 0, browserWinHeight = 0;
			if( typeof( window.innerWidth ) == 'number' ) {
				//Non-IE
				browserWinWidth = window.innerWidth;
				browserWinHeight = window.innerHeight;
			} else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
				//IE 6+ in 'standards compliant mode'
				browserWinWidth = document.documentElement.clientWidth;
				browserWinHeight = document.documentElement.clientHeight;
			} else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
				//IE 4 compatible
				browserWinWidth = document.body.clientWidth;
				browserWinHeight = document.body.clientHeight;
			}
			if(browserWinHeight > 710) {
				swfobject.embedSWF("swf/application.swf?v=<?php echo $version; ?>", "content", "100%", "100%", "11", "swf/expressinstall.swf", flashvars, params, attributes);
			}else{
				document.getElementsByTagName('html')[0].style.overflow = "auto";
				document.getElementsByTagName('body')[0].style.overflow = "auto";
				swfobject.embedSWF("swf/application.swf?v=<?php echo $version; ?>", "content", "100%", "710", "11", "swf/expressinstall.swf", flashvars, params, attributes);
			}
			
			//swffit.fit("externalDynamicContent", 800, 710, 2000, 2000, true, true);
		</script>
	</body>
</html>