
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

		<h1>{$sortie}</h1>
		<!--
		{if $sortie_date->etat == 4}
			<h3 class="pull-right"><span class="label label-danger">Sortie annulée</span></h3>
		{/if}
		-->
		<p>{$sortie->description|markdown}</p>
		<p>Durée : {$sortie->duree_lib}</p>
		<p>Rendez-vous : {$sortie->description_lieu}</p>
		{if $sortie_date->inscription_prealable}
		<p>Sur inscription :
			{if $sortie->gestion_picnat}
				Picardie Nature 03.62.72.22.54 - decouverte@picardie-nature.org
			{else}
				{if $sortie->portable}{$sortie->portable}{else}{$sortie->tel}{/if}
			{/if}
		</p>
		{/if}
		<p>Matériel :
		<ul>
		{foreach from=$sortie->materiels() item=materiel}
			{if $materiel.a_prevoir}
				<li>{$materiel.lib}</li>
			{/if}
		{/foreach}
		</ul>
		</p>
		<p>Structure : {if $sortie->structure}{$sortie->structure}{else}Picardie-Nature{/if}</p>
		{assign var=point value=$sortie->point()}
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
				 	{if $date_sel eq $date->date_sortie}active{/if}"> {$date->date_sortie|date_format:"%A<br><b>%e</b><br>%Y<br> %B<br> à %Hh%M "}
					{if $date->etat eq 4}<span class="label label-danger">annulée</span>{/if}
				</li>
				{/if}
			{/if}		 
		{/foreach}
		</ul>
	</div>
</div>
</div>
