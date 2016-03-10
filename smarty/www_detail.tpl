
<div class="container-fluid">
<div class="row">
	<div class="col-md-10">
		{foreach from=$sortie->dates() item=__sortie_date}
			{if $__sortie_date->date_sortie eq $date_sel}
				{assign var=sortie_date value=$__sortie_date}
			{/if}
		{/foreach}

		<div class="pull-right">
			{if $sortie->accessible_mobilite_reduite}
				<img src="http://sorties.picardie-nature.org/image/mobilite_reduite_1.png" alt="Accessible aux personnes à mobilité réduite">
			{/if}
			{if $sortie->accessible_deficient_auditif}
				<img src="http://sorties.picardie-nature.org/image/deficient_auditif_1.png" alt="Accessible aux déficients auditif">{/if}
			{if $sortie->accessible_deficient_visuel}
				<img src="http://sorties.picardie-nature.org/image/deficient_visuel_1.png" alt="Accessible aux déficients visuel">
			{/if}
		</div>

		<div class="well">
			<h1>{$sortie}</h1>
			<p>{$sortie->description|markdown}</p>
		</div>
		<p><b>Activité organisé par :</b> {$orga->prenom} {$orga->nom} {if $sortie->structure}{$sortie->structure}{else}Picardie-Nature{/if}</p>
		<p><b>Durée :</b> {if $sortie->duree_lib eq "4h00"}demi-journée{else}{if $sortie->duree_lib eq "7h00"}journée{else}{$sortie->duree_lib}{/if}{/if}</p>
		{if $sortie_date->inscription_prealable}
		<p><b>Sur inscription</b>
			{if $sortie->gestion_picnat}
				Picardie Nature 03.62.72.22.54 - decouverte@picardie-nature.org
			{else}
				{if $sortie->portable}{$sortie->portable}{else}{$sortie->tel}{/if}
			{/if}
			{if $sortie_date->inscription_date_limite}
				<b>date limite d'inscription :</b> {$sortie_date->inscription_date_limite|date_format:"%d-%m-%Y"}
			{/if}
		</p>
		{/if}
			<p><b>Matériel :</b>
		<ul>
		{foreach from=$sortie->materiels() item=materiel}
			{if $materiel.a_prevoir}
				<li>{$materiel.lib}</li>
			{/if}
		{/foreach}
		{if $sortie->materiel_autre}<li>{$sortie->materiel_autre}</li>{/if}
		</ul>
		</p>
		<p><b>Rendez-vous :</b> {$sortie->description_lieu}</p>
		{assign var=point value=$sortie->point()}
	
		{if $point}
			{assign var=commune value=$point->get_commune()}
			<p>
				<b>Coordonnées GPS :</b> {$point->get_x()},{$point->get_y()}
				{if $commune} <b>Commune :</b> {$commune}{/if}
			</p>
		{/if}
		{if $point->get_x()}
		{literal}
		<style>#map { width:100%; height: 350px; }</style>
		<script>
			function aff_carte() {
		{/literal}
				var carte = new Carto('map');
				var latitude = "{$point->get_y()}";
				var longitude = "{$point->get_x()}";
				var point = new OpenLayers.LonLat(longitude,latitude);
				point.transform(carte.map.displayProjection, carte.map.projection);
				var markers = new OpenLayers.Layer.Markers( "Markers" );
				carte.map.addLayer(markers);
				var size = new OpenLayers.Size(169,120);
				var offset = new OpenLayers.Pixel(-152,-116);
				var icon = new OpenLayers.Icon('http://sorties.picardie-nature.org/image/marqueur_sortie.png', size, offset);
				markers.addMarker(new OpenLayers.Marker(point.clone(),icon));
				carte.map.moveTo(point,10);
		{literal}
			}
		{/literal}
		</script>
		<script type="text/javascript" src="http://deco.picardie-nature.org/proj4js/lib/proj4js-compressed.js"></script>
		<script type="text/javascript" src="http://maps.picardie-nature.org/OpenLayers-2.12/OpenLayers.js"></script>
		<script type="text/javascript" src="http://maps.picardie-nature.org/carto.js"></script>
		<div id="map"></div>
		<script>
			aff_carte();
		</script>
		{/if}
	</div>
	<div class="col-md-2">
		{assign var=date_min value=$date_sel|strtotime}
		{assign var=date_min value=$date_min-86400*5}
		{assign var=dates value=$sortie->dates(1)}
		<ul class="list-group">
		{foreach from=$dates item=date}
			{assign var=_date value=$date->date_sortie|strtotime}
			{if $_date > $date_min}
				{if $date->etat >= 3}
				 <li class="list-group-item text-center
				 	{if $date_sel eq $date->date_sortie}active{/if}"> {$date->date_sortie|date_format:"%A<br><b>%e</b><br>%B<br>%Y<br> à %Hh%M "}
					{if $date->etat eq 4}<span class="label label-danger">annulée</span>{/if}
				</li>
				{/if}
			{/if}		 
		{/foreach}
		</ul>
	</div>
</div>
</div>
