{include file="head.tpl" titre_page="Espace de saisie de vos activités"}
<fieldset><legend>Chargement fichier XML</legend>
<form method="POST" action="?t=mailing&action=xml_incoming" enctype="multipart/form-data">	
	Fichier XML a utiliser <input type="file" name="xml"><input type="submit" value="Envoyer">
</form> 
</fieldset>
{if $html}
<fieldset><legend>Envoi du message</legend>
<form method="get" action="index.php">
	<input type="hidden" name="t" value="mailing"/>
	<input type="hidden" name="action" value="envoi"/>
	Adresse email de destination <input type="text" name="dest" style="width:100%;" value=""/>
	<input type="submit" value="Envoyer">
</form>
</fieldset>
{/if}
<fieldset><legend>Aperçu</legend>
<div>
{$html}
</div>
</fieldset>
{include file="foot.tpl"}
