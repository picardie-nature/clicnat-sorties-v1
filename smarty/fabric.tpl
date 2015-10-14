{include file="head.tpl" titre_page="Espace de saisie de vos activités"}
<fieldset><legend>Chargement fichier XML</legend>
<form method="POST" action="?t=fabric&action=xml_incoming" enctype="multipart/form-data">	
	Fichier XML a utiliser <input type="file" name="xml"><input type="submit" value="Envoyer">
</form>
</fieldset>
{if $doc}
<form method="get" action="index.php">
	<input type="hidden" name="t" value="fabric"/>
	<input type="hidden" name="action" value="tableau_pdf"/>
	<select name="taille">
		<option value="A3">A3</option>
		<option value="A4">A4</option>
	</select>
	<input type="submit" value="Créer le PDF"/>
</form>
<fieldset>
	<legend>Liste des images des personnes</legend>
	<textarea style="width:100%; height:10em;">{$doc->images_personnes()}</textarea>
</fieldset>
<fieldset>
	<legend>Liste des illustrations</legend>
	<textarea style="width:100%; height:10em;">{$doc->illustrations()}</textarea>
</fieldset>
<fieldset>
	<legend>Activités par cellule de la carte</legend>
	<textarea style="width:100%; height:10em;">{$doc->sorties_par_cellule()}</textarea>
</fieldset>
<fieldset>
	<legend>GeoJSON</legend>
	<textarea style="width:100%; height:10em;">{$doc->geojson()}</textarea>
</fieldset>
{/if}
{include file="foot.tpl"}
