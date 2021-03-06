<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr">
<head>
	<title>{$titre_page}</title>
	<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/themes/redmond/jquery-ui.css" />
	<link rel="stylesheet" href="https://ssl.picardie-nature.org/statique/OpenLayers-2.13.1/theme/default/style.css" />
	<link rel="stylesheet" href="https://ssl.picardie-nature.org/statique/OpenLayers-2.13.1/theme/default/google.css" />
	<link href="css/site_v2_commun.css" media="all" rel="stylesheet" type="text/css"/>
	<link href="css/site.css" media="all" rel="stylesheet" type="text/css"/>
	{if $usedatatable}
	<link href="http://deco.picardie-nature.org/datatables/media/css/demo_table.css" media="all" rel="stylesheet" type="text/css"/>
	{/if}
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=7" />
</head>
<body>
{if $usemap}
<script src="https://ssl.picardie-nature.org/statique/OpenLayers-2.master/OpenLayers.js"></script>
<script src="http://maps.google.com/maps/api/js?sensor=true&v=3.5"></script>
<script src="http://deco.picardie-nature.org/proj4js/lib/proj4js-compressed.js" language="javascript"></script>
<script src="js/carte.js" language="javascript"></script>
{/if}
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script> 
<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>
<script src="http://deco.picardie-nature.org/jquery/js/jquery.ui.datepicker-fr.js" language="javascript"></script>
<script>

{literal}
var J = jQuery.noConflict();

function log(msg) {
	try {
		if (console)
			console.info(msg);
	} catch (e) {
		return false;
	}
}

function dialog_vignette(div_id, obs_id)
{
	$(div_id+'-img').src='icones/load.gif';
	$(div_id+'-img').src='?t=obs_vignette&id='+obs_id;
	J('#'+div_id).dialog({title: "Observation #"+obs_id,width: 500,height: 400});
}

log('firebug ok');
{/literal}
</script>
{literal}
<style>

	div#banniere2 {
		padding-left:0px;
		padding-top: 155px;
	}
	.banniere ul{
		display:inline;
		margin: 0px;
		padding-left:0px;
	}
	li.nbanniere_li {
		display:inline;
	}

	div.bloc_menu:hover {
		background-color: #eaffea;
	}
	div.bloc_menu {
		float: left;
		width: 125px;
		height: 125px;
		margin: 5px;
		padding: 5px;
		background-color: white;
		border: solid 1px black;
	}
	.bloc_menu p {
		padding: 0px;
		margin: 0px;
		font-size: 12px;
	}
	div.panneau_menu {
		height: 200px;
		background-color: white;
		display:none;
		border-width: 5px;
		border-color:rgb(198,229,72);
		border-style: solid;
		border-top-style: none;
		z-index: 2500;
		position: absolute;
		width:970px;
		padding:10px;
	}
	.menu_saisie img { display:none; }

	a.menu_saisie:hover > img {
		position: absolute;
		top: 10px;
		right:5px;
		display:block;
	}

	SPAN.field-name {
		width: 120px;
		text-align: right;
		display: block;
		float: left;
	}

	SPAN.field-content {
		margin-left: 120px; /* sync with field-name width */
		display: block;
	}

	.check-with-label:checked + .label-for-check {
		font-weight: bold;
	}

</style>
{/literal}
<div id="globcont" style="min-width: 1000px;">
	<div class="bloc-haut" style="min-width: 1000px;">
		<div id="banniere">
			<div id="banniere2" class="banniere2">	
				<ul>
				{if $u}
				<li class="nbanniere_li">
					<a class="panneau_btn" id_panneau="panneau_menu_2" href="?t=accueil">Accueil</a>
				</li>

				<li class="nbanniere_li">
					<a class="panneau_btn" id_panneau="panneau_menu_2" href="?t=proposer">Nouveau</a>
				</li>
				<li class="nbanniere_li">
					<a class="panneau_btn" id_panneau="panneau_menu_2" href="?t=calendrier">Calendrier</a>
				</li>

				<li class="nbanniere_li">
					<a class="panneau_btn" id_panneau="panneau_menu_2" href="?t=suivi">Suivi</a>
				</li>

				<li class="nbanniere_li">
					<a href="?t=accueil&fermer=1">Fermer</a>
				</li>
			    {if $admin}
				<li class="nbanniere_li">
					<a href="?t=sel_xml">XML et CSV</a>
				</li>
				<li class="nbanniere_li">
					<a href="?t=mailing">Mailing</a>
				</li>
				<li class="nbanniere_li">
					<a href="?t=fabric">Outils</a>
				</li>
			    {/if}
				{/if}
				</ul>
			</div>
		</div>
	</div>
	<div class="pn_main">
	{foreach from=$bobs_msgs item=bobs_m}
		<div>{$bobs_m}</div>
	{/foreach}

