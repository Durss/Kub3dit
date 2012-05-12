// ==UserScript==
// @name          Kube Build3r
// @namespace     http://www.muxxu.free.fr/kube/apps/pfb
// @include       http://kube.muxxu.com/
// @include       http://kube.muxxu.com/?*
// @description   Adds a flash application that allows to load Kub3dit maps and synch it's construction with the game via a forum kube.
// ==/UserScript==

if (document.getElementById('swf_kube') != null) {
	var panelRef, mapRef, appRef, btRef, closeBt;
	appRef = unsafeWindow.document.createElement('div');
	btRef = unsafeWindow.document.createElement('div');
	panelRef = unsafeWindow.document.getElementById('panel');
	
	var mapRef = unsafeWindow.document.getElementById('swf_minimap');
	var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
	if(isChrome && mapRef.getElementsByTagName("embed")[0].getAttribute("wmode") != "direct") {
		mapRef.getElementsByTagName("embed")[0].setAttribute("wmode", "opaque");
		with (mapRef.parentNode) appendChild(removeChild(mapRef));
	}
	
	function showBuild3r() {
		document.getElementById("build3rApp").getElementsByTagName("embed")[0].style.width = "191px";
		document.getElementById("build3rApp").getElementsByTagName("embed")[0].style.height = "310px";
		document.getElementById('swf_minimap').style.visibility = 'hidden';
		return false;
	}
	
	//Due to a security shit this can't be called by flash even if the method is defined on the unsafeWindow object.
	//So flash does the exact same thing internally.
	function hideBuild3r () {
		document.getElementById("build3rApp").getElementsByTagName("embed")[0].style.width = "0px";
		document.getElementById("build3rApp").getElementsByTagName("embed")[0].style.height = "0px";
		document.getElementById('swf_minimap').style.visibility = '';
		return false;
	}
	
	panelRef.appendChild(appRef);
	panelRef.appendChild(btRef);
	
	//Open Button
	btRef.innerHTML = '<a href="javascript:void(0);" style="line-height:15px; width:15px; height:15px" class="button">۩</a>';
	btRef.setAttribute("id", "build3rButton");
	btRef.style.position = "relative";
	btRef.style.left = "18px";
	btRef.style.top = "-19px";
	btRef.style.width = "15px";
	btRef.style.height = "15px";
	btRef.style.lineHeight = "15px";
	btRef.addEventListener("click", showBuild3r, true);
	
	
	
	//Application's panel
	appRef.innerHTML = '<embed type="application/x-shockwave-flash" src="http://fevermap.org/kub3dit/swf/builder.swf" width="0" height="0" allowScriptAccess="always" bgcolor="#44526f" id="build3rSWF" />';
		
		//close button
		/*
		closeBt = unsafeWindow.document.createElement('a');
		closeBt.setAttribute("href", "javascript:void(0);");
		closeBt.setAttribute("class", "button");
		closeBt.style.lineHeight = "15px";
		closeBt.style.width = "15px";
		closeBt.style.height = "15px";
		closeBt.style.zIndex = "1";
		closeBt.style.margin = "0px";
		closeBt.style.marginLeft = "175px";
		closeBt.style.top = "-315px";
		closeBt.style.position = "relative";
		closeBt.innerHTML = "X";
		closeBt.addEventListener("click", hideBuild3r, true);
		appRef.appendChild(closeBt);
		*/
		
		//application
		appRef.setAttribute("id", "build3rApp");
		appRef.style.zIndex = "10";
		appRef.style.position = "relative";
		appRef.style.left = "0px";
		appRef.style.top = "-300px";
		appRef.style.width = "0px";
		appRef.style.height = "0px";
}
