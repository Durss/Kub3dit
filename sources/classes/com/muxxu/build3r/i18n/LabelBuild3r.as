package com.muxxu.build3r.i18n {
	import flash.system.Capabilities;
	
	
	/**
	 * Singleton Label
	 * 
	 * @author Francois
	 * @date 22 févr. 2012;
	 */
	public class LabelBuild3r {
		
		private static const _LABELS:Object = {};
		{
			//======= FR =======
			_LABELS["fr"] = {};
			_LABELS["fr"]["load-titleBrowse"] = "Charger une carte depuis votre ordinateur :";
			_LABELS["fr"]["load-titleId"] = "Charger une carte par son ID Kub3dit :";
			_LABELS["fr"]["load-mapProtected"] = "Carte protégée.<br />Entrez le mot de passe.";
			_LABELS["fr"]["load-wrongPass"] = "Mot de passe invalide";
			_LABELS["fr"]["load-invalidFile"] = "Fichier invalide";
			_LABELS["fr"]["load-notFound"] = "Cette carte n'existe pas.";
			_LABELS["fr"]["load-browse"] = "Parcourir...";
			_LABELS["fr"]["load-id"] = "id...";
			_LABELS["fr"]["load-pass"] = "pass...";
			_LABELS["fr"]["load-submit"] = "Charger";
			
			_LABELS["fr"]["synch-submit"] = "OK";
			_LABELS["fr"]["synch-titleMap"] = "Cliquez sur la carte pour<br />définir le point de référence :";
			_LABELS["fr"]["synch-titleKube"] = "Touchez un kube forum dans le jeu pour situer le point de référence :";
			
			_LABELS["fr"]["build-keys"] = "espace entrée";
			_LABELS["fr"]["build-getKube"] = "Ramasser le kube";
			_LABELS["fr"]["build-helpBt"] = "Aide";
			_LABELS["fr"]["build-helpTT"] = "Touchez un kube forum dans<br />le jeu pour savoir quel kube<br />doit se trouver à son<br />emplacement.";
			_LABELS["fr"]["build-changeHelpBt"] = "Changer";
			_LABELS["fr"]["build-changeHelpTT"] = "Charger une<br />nouvelle carte.";
			
			//======= EN =======
			_LABELS["en"] = {};
			_LABELS["en"]["load-titleBrowse"] = "Load a map from your computer:";
			_LABELS["en"]["load-titleId"] = "Load a Kub3dit map by its ID:";
			_LABELS["en"]["load-mapProtected"] = "Map protected.<br />Enter password.";
			_LABELS["en"]["load-wrongPass"] = "Invalid password";
			_LABELS["en"]["load-invalidFile"] = "Invalid file.";
			_LABELS["en"]["load-notFound"] = "Map not found.";
			_LABELS["en"]["load-browse"] = "Browse...";
			_LABELS["en"]["load-id"] = "id...";
			_LABELS["en"]["load-pass"] = "pass...";
			_LABELS["en"]["load-submit"] = "Load";
			
			_LABELS["en"]["synch-submit"] = "OK";
			_LABELS["en"]["synch-titleMap"] = "Click on the map to define <br />the reference point :";
			_LABELS["en"]["synch-titleKube"] = "Touch a forum kube in the game to locate the reference point :";
			
			_LABELS["en"]["build-title"] = "Touch a forum kube in the game to know which kube should be put at its place.";
			_LABELS["en"]["build-keys"] = "space enter";
			_LABELS["en"]["build-getKube"] = "Pick up kube";
			
			_LABELS["es"] = {};
		}
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		public static function getl(id:String):String {
			var lang:String = Capabilities.language;
			if(_LABELS[lang] == undefined) lang = "en";
			return _LABELS[lang][id];
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}