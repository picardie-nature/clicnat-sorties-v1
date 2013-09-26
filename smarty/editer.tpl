{include file="head.tpl" titre_page="Edition d'une activité" usemap=true}
<h1>Édition fiche activité #{$sortie->id_sortie}</h1>
<form method="post" action="?t=editer&sortie={$sortie->id_sortie}&update=1">
<small>Fiche créée le {$sortie->date_proposition|date_format:"%d-%m-%Y"} par {$sortie->utilisateur_propose()}</small>

<fieldset><legend>Organisateur</legend>
	Nom : {if $edit}<input type="text" name="orga_nom" value="{$sortie->orga_nom}"}/>{else}<b>{$sortie->orga_nom}</b>{/if}
	Prénom : {if $edit}<input type="text" name="orga_prenom" value="{$sortie->orga_prenom}"/>{else}<b>{$sortie->orga_prenom}</b>{/if}<br/>
	Adresse : <br/>
	{if $edit}<textarea style="width:100%; height:60px;" name="adresse">{$sortie->adresse}</textarea>{else}<b>{$sortie->adresse}</b>{/if}<br/>
	Téléphone : {if $edit}<input type="text" name="tel" size="10" value="{$sortie->tel}"/>{else}<b>{$sortie->tel}</b>{/if}
	Portable : {if $edit}<input type="text" name="portable" size="10" value="{$sortie->portable}"/>{else}<b>{$sortie->portable}</b>{/if}
	Mail : {if $edit}<input type="text" name="mail" value="{$sortie->mail}"/>{else}<b>{$sortie->mail}</b>{/if}<br/>
	<br/>
	Nom de l'association que vous souhaitez associer à cette activité (autre que Picardie Nature) : {if $edit}<input type="text" style="width:100%;" name="structure" value="{$sortie->structure}"/>{else}<b>{$sortie->structure}</b>{/if}<br/><br/>
	Prise en charge des demandes d'inscriptions et de renseignements de la part du public :<br/>
	{if $edit}
		<input type="radio" name="gestion_picnat" id="gestion_picnat_a" value="0" {if !$sortie->gestion_picnat}checked=true{/if}/>Par moi (votre portable et email seront diffusés)<br/>
		<input type="radio" name="gestion_picnat" id="gestion_picnat" value="1" {if $sortie->gestion_picnat}checked=true{/if}/>Par Picardie Nature
	</ul>
	{else}
		<b>{if $sortie->gestion_picnat}oui{else}non{/if}</b>
	{/if}<br/>
</fieldset>
<fieldset><legend>L'activité</legend>
	Nom de l'activité : {if $edit}<input type="text" style="width:100%;" name="nom" value="{$sortie->nom}"/>{else}<b>{$sortie->nom}</b>{/if}<br/>
</fieldset>
<fieldset><legend>Localisation</legend>
	Localisation du point de rendez-vous<br/>
	<style>
		{literal}
		#box_commune {
			position: absolute;
			top: 20px;
			right : 10px;
			width: 200px;
			background-color: white;
			border-width: 0px;
			visibility: visible;
			z-index: 10000;
			padding: 5px;
			font-size: 12px;
			box-shadow: 4px 4px 4px black;
		}
		#box_commune > input {
			width: 100%;
		}
		#map {
			z-index: 0;
		}
		{/literal}
	</style>
	<div id="maproot" style="position:relative;">
		<div id="map" style="height:300px; width:100%;"></div>
		<div id="box_commune">
			Trouver une commune <br/>
			<input type="text" id="srch_commune"/>
		</div>

	</div>
	{if $edit}
		{if !$sortie->id_espace_point}
			X,Y : <input type="text" name="x" id="x" value=""/> 
			<input type="text" name="y" id="y" value=""/> <b>(cliquer sur la carte, pour indiquer le lieu de rendez-vous)</b><br/>
		{else}
			{assign var=point value=$sortie->point()}
			Point <b>#{$sortie->id_espace_point}</b> sur la commune de : {$point->get_commune()}<br/>
			{assign var=grille value=$point->grille_x_y()}
			Grille : {$grille.x} {$grille.y}
			<a href="?t=editer&sortie={$sortie->id_sortie}&annuler_loc=1">annuler localisation</a>
		{/if}
		<p>Assurez-vous, que les propriétaires ou le gestionnaire du site visité soit averti de la date de l'activité.<br/>
		<input type="checkbox" name="validation_externe" id="validation_externe" value="1" {if $sortie->validation_externe}checked=true{/if}>
		<label for="validation_externe">cocher la case quand l'accès au site est validé</label></p>

	{/if}

	Indications permettant de trouver le lieu de rendez-vous (une phrase) :<br/>
	{if $edit}<textarea style="width:100%; height:120px;" name="description_lieu">{$sortie->description_lieu}</textarea>{else}<b>{$sortie->description_lieu}</b>{/if}<br/>
</fieldset>
<fieldset><legend>Description</legend>
	Type de sortie : 
	{if $edit}
		<select name="id_sortie_type">
			{foreach from=$sortie->types_sortie() item=s}
				<option value="{$s.id_sortie_type}" {if $s.id_sortie_type eq $sortie->id_sortie_type}selected{/if}>{$s.lib}</option>
			{/foreach}
		</select>
	{else}
		<b>{$sortie->type_sortie()}</b>
	{/if}
	<!-- ne montrer que aux administrateurs -->
	{if $admin}
	Pôle : 
	<select name="id_sortie_pole">
		{foreach from=$sortie->poles_sortie() item=pole}
		<option value="{$pole.id_sortie_pole}" {if $sortie->id_sortie_pole eq $pole.id_sortie_pole}selected=1{/if}>{$pole.lib}</option>
		{/foreach}
	</select>
	Réseau :
	<select name="id_sortie_reseau">
		{foreach from=$sortie->reseaux_sortie() item=reseau}
		<option value="{$reseau.id_sortie_reseau}" {if $sortie->id_sortie_reseau eq $reseau.id_sortie_reseau}selected=1{/if}>{$reseau.lib}</option>
		{/foreach}
	</select>
	{else}
		<input type="hidden" name="id_sortie_reseau" value="{$sortie->id_sortie_reseau}"/>
		<input type="hidden" name="id_sortie_pole" value="{$sortie->id_sortie_pole}"/>
	{/if}
	<!--
	<br/>Thème de la sortie :
	<select name="theme">
		<option value="">Continuités écologiques</option>
	</select>
	-->
	<hr/>
	Public :
	{if $edit}
		<select name="id_sortie_public">
			{foreach from=$sortie->publics_sortie() item=s}
				<option value="{$s.id_sortie_public}" {if $s.id_sortie_public eq $sortie->id_sortie_public}selected{/if}>{$s.lib}</option>
			{/foreach}
		</select>
	{else}
		<b>{$sortie->public_sortie()}</b>
	{/if}
	<br/>
	<label for="accessible_mobilite_reduite">Sortie accessible aux personnes à mobilité réduite</label>
	{if $edit}
		<input type="checkbox" name="accessible_mobilite_reduite" id="accessible_mobilite_reduite" value="1" {if $sortie->accessible_mobilite_reduite}checked=true{/if}>
	{else}
		<b>{if $sortie->accessible_mobilite_reduite}oui{else}non{/if}</b>
	{/if}
	<br/>
	<label for="accessible_deficient_auditif">Accessible aux déficients auditifs</label>
	{if $edit}
		<input type="checkbox" name="accessible_deficient_auditif" id="accessible_deficient_auditif" value="1" {if $sortie->accessible_deficient_auditif}checked=true{/if}>
	{else}
		<b>{if $sortie->accessible_deficient_auditif}oui{else}non{/if}</b><br/>
	{/if}
	<label for="accessible_deficient_visuel">Accessible aux déficients visuels</label>
	{if $edit}
		<input type="checkbox" name="accessible_deficient_visuel" id="accessible_deficient_visuel" value="1" {if $sortie->accessible_deficient_visuel}checked=true{/if}>
	{else}
		<b>{if $sortie->accessible_deficient_visuel}oui{else}non{/if}</b><br/>
	{/if}
	<hr/>
	Durée (heures) : {if $edit}<input type="hidden" name="duree_heure" id="z_duree_heure" value="{$sortie->duree_heure}"><span id="z_txt_heure"></span>
	<div id="slider_heure"></div>{else}<b>{$sortie->duree_heure}</b>{/if}<br/>
	<hr/>
	Présentation de la sortie <small>Afin d'homogéniser les différents contenus nous pourrons y apporter quelques modifications jugées nécessaires (max 300 caractères)</small><br/>
	{if $edit}<textarea style="width:100%; height:120px;" name="description" id="z_description">{$sortie->description}</textarea><div id="z_longueur_desc"></div>{else}<b>{$sortie->description}</b>{/if}<br/>
			Cadre dans lequel est réalisé la sortie :
	{if $edit}
		<select name="id_sortie_cadre">
			{foreach from=$sortie->cadres_sortie() item=c}
				<option value="{$c.id_sortie_cadre}" {if $c.id_sortie_cadre eq $sortie->id_sortie_cadre}selected{/if}>{$c.lib}</option>
			{/foreach}
		</select>
	{else}
		<b>{$sortie->cadre_sortie()}</b>
	{/if}
	<!-- ajouter un champ sortie autre -->
</fieldset>
<fieldset><legend>Matériel à prévoir</legend>
	{foreach from=$sortie->materiels() item=m}
		{if $edit}
			<input type="checkbox" name="materiel_{$m.id_sortie_materiel}" value="{$m.id_sortie_materiel}" {if $m.a_prevoir}checked="true"{/if} id="mat{$m.id_sortie_materiel}"/> 
			<label for="mat{$m.id_sortie_materiel}">{$m.lib}</label><br/>
		{else}
			{if $m.a_prevoir}{$m.lib}<br/>{/if}
		{/if}
	{foreachelse}
		{if !$edit}Aucun matériel requis{/if}
	{/foreach}
	Autre matériel : {if $edit}<input type="text" style="width:100%;" name="materiel_autre" value="{$sortie->materiel_autre}"/>{else}<b>{$sortie->materiel_autre}</b>{/if}<br/>
</fieldset>
<div style="text-align:right;">
	A l'étape suivante vous pourrez renseigner la date et l'heure <input type="submit" value="Passer à la page suivante">
</div>
</form>
<script>
	{literal}
	var m = carte_inserer(document.getElementById("map"));
	var lc = carte_ajout_layer_vecteurs(m, 'Commune');
	var lm = carte_ajout_layer_marqueurs(m, 'Marqueurs');
	var pt = new OpenLayers.LonLat(2.80151, 49.69606);
	pt.transform(m.displayProjection, m.projection);
	var z = 8;
	m.setCenter(pt, z);
	m.events.register('click', null, function (e) {
		console.log(m);
		var pt = e.object.getLonLatFromViewPortPx(e.xy);
		pt.transform(e.object.projection, e.object.displayProjection);
		J('#x').val(pt.lon);
		J('#y').val(pt.lat);
		set_marqueur_pos(m,lm,pt.lon,pt.lat);
	});
	init_search_commune();
	{/literal}
	{if $sortie->id_espace_point}
		{assign var=point value=$sortie->point()}
		var x={$point->get_x()};
		var y={$point->get_y()};
		set_marqueur_pos(m,lm,x,y);
	{/if}
	//{literal}
	function description_longueur() {
		var l = J('#z_description').val().length;;
		var t = 'caractère';
		if (l == 0) {
			J('#z_longueur_desc').html("Description vide");
			return;
		}
		if (l > 1) t = t+'s';
		J('#z_longueur_desc').html(l+" "+t);
	}

	description_longueur();

	J('#z_description').keyup(description_longueur);
	J('#z_description').change(description_longueur);

	function maj_txt_duree() {
		var d = J('#z_duree_heure').val();
		var txt = Math.floor(d)+"h";
		if (d == 3.5) txt = "Demi-journée";
		else if (d == 7) txt = "Journée entière";
		else if (d - Math.floor(d) > 0) {
			txt = Math.floor(d)+"h"+(d - Math.floor(d))*60;
		}
		J('#z_txt_heure').html(txt);
	}

	J('#slider_heure').slider({
		range: "max",
		min: 0,
		max: 7,
		step:0.5,
		slide: function (e,ui) {
			J('#z_duree_heure').val(ui.value);
			maj_txt_duree();
		},
		value: J('#z_duree_heure').val()
	});
	maj_txt_duree();
	//{/literal}
</script>
{include file="foot.tpl"}
