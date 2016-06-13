{literal}
<script src="https://ssl.picardie-nature.org/statique/proj4js/2.3.3/proj4.js"></script>
<script src="https://ssl.picardie-nature.org/statique/OpenLayers-3.11.2/ol.js"></script>
<script src="http://v2.clicnat.fr/js/gpic.js"></script>
<script>
var xorg = 2.80151;
var yorg = 49.69606;
var zorg = 8;

function loadCss(url) {
    var link = document.createElement("link");
    link.type = "text/css";
    link.rel = "stylesheet";
    link.href = url;
    document.getElementsByTagName("head")[0].appendChild(link);
}
loadCss('https://ssl.picardie-nature.org/statique/OpenLayers-3.11.2/ol.css');
function initialiser_carte(div_id) {
	var projection = ol.proj.get('EPSG:3857');
	var p4326 = ol.proj.get('EPSG:4326');
	var layers = [new Gpic.layerBright()];
	return new ol.Map({
		controls: ol.control.defaults().extend([
			new ol.control.ScaleLine({
				units: 'metric'
			}),
			new ol.control.Attribution(),
			new ol.control.Rotate()
		]),
		layers: layers,
		target: div_id,
		view: new ol.View({
			projection: projection,
			center: ol.proj.transform([xorg,yorg], 'EPSG:4326','EPSG:3857'),
			zoom: zorg
		})
	});
}

function Espace(id_espace,x,y,couleur) {
	this.id_espace = id_espace;
	this.x = x;
	this.y = y;
	this.activites = [];
	this.couleur = couleur;
	this.getFeature = function () {
		var f = new ol.Feature({
			geometry: new ol.geom.Point(ol.proj.transform([parseFloat(this.x),parseFloat(this.y)], 'EPSG:4326','EPSG:3857')),
			name: '#'+this.id_espace
		});
		f.setProperties({id_espace: this.id_espace, activites: this.activites, color: this.couleur});
		return f;
	}
}

function olEspaceStyleFunction(feature,resolution) {
	var props = feature.getProperties();
	var s;
	if (props.features.length == 1) {
		feature = props.features[0];
		var color = feature.get('color');
		var text = feature.get('activites').length.toString();
		s = new ol.style.Style({
			image: new ol.style.Circle({
				radius: 12,
				stroke: new ol.style.Stroke({color: color}),
				fill: new ol.style.Fill({color: color})
			}),
			text: new ol.style.Text({
				text: text,
				fill: new ol.style.Fill({color: '#fff'})
			})
		});
	} else {
		var color = 'rgb(180,180,180)';
		var n = 0;
		for (k in props.features) {
			n += props.features[k].get('activites').length;
		}
		s = new ol.style.Style({
			image: new ol.style.Circle({
				radius: 12,
				stroke: new ol.style.Stroke({color: color}),
				fill: new ol.style.Fill({color: color})
			}),
			text: new ol.style.Text({
				text: n.toString(),
				fill: new ol.style.Fill({color: '#fff'})
			})
		});
	}
	return [s];
}

function Calendrier() {
	this.poles = {};	// tableau associatif des pôles
	this.espaces = {};	// tableau associatif des espaces
	this.pays = {};		// tableau associatif des pays utilisés

	this.appliquer_filtres = function () {
		var id_pole = $('#sel-calendrier-pole').val();

		if (id_pole == 'tous') {
			$('.activite').show();
		} else {
			$('.activite').hide();
			$('.activite[data-pole='+id_pole+']').show();
		}

		var id_pays = $('#sel-calendrier-pays').val();

		if (id_pays != 'tous') {
			$('.activite:visible[data-pays!='+id_pays+']').hide();
		}

		if ($('.activite:visible').length == 0) 
			$('#vide').show();
		else
			$('#vide').hide();
	}

	var acts = $('.activite');
	for (var i=0;i<acts.length;i++) {
		var act = $(acts[i]);
		
		var id_pole = act.attr('data-pole');
		var id_sortie = act.attr('data-id-sortie');
		var id_espace_point = act.attr('data-id-espace-point');
		var id_pays = parseInt(act.attr('data-pays'));

		if (this.poles[id_pole] == undefined) {
			this.poles[id_pole] = liste_poles[id_pole];
		}

		if (this.espaces[id_espace_point] == undefined) {
			var x = act.attr('data-x');
			var y = act.attr('data-y');
			var couleur = act.css('border-color');
			// avec firefox border-color est vide
			if (!couleur)
				couleur = act.css('border-top-color');
			this.espaces[id_espace_point] = new Espace(id_espace_point, x, y, couleur);
		}

		if (id_pays) {
			if (this.pays[id_pays] == undefined) {
				this.pays[id_pays] = liste_pays[id_pays];
			}
		}

		this.espaces[id_espace_point].activites.push(id_sortie);
	}

	// init ui
	select_pole = $('#sel-calendrier-pole');
	select_pole.append("<option value='tous'>Tous les poles</option>");
	for (var id_pole in this.poles) {
		var opt = document.createElement('option');
		$(opt).val(id_pole);
		$(opt).html(this.poles[id_pole]);
		select_pole.append(opt);
	}
	select_pole.change(function (evt) {
		cal.appliquer_filtres();
	});

	select_pays = $('#sel-calendrier-pays');
	for (var id_pays in this.pays) {
		var opt = document.createElement('option');
		$(opt).val(id_pays);
		$(opt).html(this.pays[id_pays]);
		select_pays.append(opt);
	}
	opt_list = select_pays.find('option');
	opt_list.sort(function(a, b) { return $(a).text() > $(b).text() ? 1 : -1; });
	select_pays.html('');
	select_pays.append("<option value='tous'>Tous les pays</option>");
	select_pays.append(opt_list);
	select_pays.val('tous');
	select_pays.change(function (evt) {
		cal.appliquer_filtres();
	});

	// init carto
	this.carte = initialiser_carte("carte");
	var src = new ol.source.Vector();
	for (var id_espace in this.espaces) {
		try {
			src.addFeature(this.espaces[id_espace].getFeature());
		} catch (e) {
			//console.log(e);
		}
	}

	this.layer_v = new ol.layer.Vector({
		source: new ol.source.Cluster({
			distance: 20,
			source: src,
		}),
		style: olEspaceStyleFunction
	});
	this.carte.addLayer(this.layer_v);

	// btn marker sur les boites activités
	$('.btn-activite-map').click(function (e) {
		e.preventDefault();
		document.location.hash = '#carte';
		var x = $(this).attr('data-x');
		var y = $(this).attr('data-y');
		var p = ol.proj.transform([parseFloat(x),parseFloat(y)], 'EPSG:4326','EPSG:3857');
		cal.carte.getView().setCenter(p);
		cal.carte.getView().setZoom(14);
	});

	// clique sur un point
	var select = new ol.interaction.Select({
		layers: [this.layer_v],
		style: olEspaceStyleFunction
	});
	this.carte.addInteraction(select);
	this.popup = new ol.Overlay({
		element: document.getElementById('popup')
	});
	this.carte.addOverlay(this.popup);

	select.on('select', function (evt) {
		var nselect = evt.target.getFeatures().getLength();
		var ncluster = 0;
		if (nselect > 0) {
			var feature_cluster = evt.target.getFeatures().getArray()[0];
			var features = feature_cluster.get('features');
			ncluster = features.length;
		}
		if (nselect > 0 && ncluster > 0) {
			var ele = cal.popup.getElement();
			var coord = evt.selected[0].getGeometry().getCoordinates();
			//var html = '<ul class="list-group">';
			var html="<div class='act-pop-content'>";
			for (idxSel in evt.selected) {
				var features = evt.selected[idxSel].get('features');
				var fait = {};
				for (idFeat in features) {
					var acts = features[idFeat].get('activites');
					for (idxAct in acts) {
						if (fait[acts[idxAct]] == undefined) {
							fait[acts[idxAct]] = 1;
						} else {
							continue;
						}
						var titre = $('.activite[data-id-sortie='+acts[idxAct]+'] span.activite-titre').html();
						html += "<div class='act-item'><a target='_blank' href='?page=sortie_detail&id_sortie="+acts[idxAct]+"'>"+titre+"</a>";
						var dates = $('.activite[data-id-sortie='+acts[idxAct]+'] span.activite-date');
						for (var idxD=0; idxD<dates.length; idxD++) {
							html += "<div>"+$(dates[idxD]).html()+"</div>";
						}

						html += "</div>";
					}
				}
			}
			html += '</div>';
			$(ele).popover('destroy');
			cal.popup.setPosition(coord);
			$(ele).popover({
				'placement': 'top',
				'animation': false,
				'html': true,
				'content': html	
			});
			$(ele).popover('show');
		} else {
			$('#popup').popover('destroy');
		}
	});
}
//{/literal}
var liste_poles = jQuery.parseJSON('{$poles}');
var liste_pays = jQuery.parseJSON('{$pays}');
//{literal}
var cal = undefined;
$(document).ready(function () {
	cal = new Calendrier();
});
</script>
<style>
.act-pop-content {
	overflow: auto;
	max-height: 100px;
	font-size: 12px;
	max-width: 244px;
	width: 244px;
}
.act-item {
	margin-bottom: 7px;
}
#popup {
}
</style>
{/literal}
<div id="carte" style="width: 100%; height: 400px;"></div>
<div class="params">
	<select id="sel-calendrier-pole"></select>
	<select id="sel-calendrier-pays"></select>
</div>
<div style="display:none;">
	<div id="popup" title="Activités" class="popup"></div>
</div>
<div id="vide" class="panel panel-default panel-info" style="display:none;">
	<div class="panel-heading">Pas de résultat</div>
	<div class="panel-body">Aucune activité correspond à vos critères de recherche</div>
</div>
<!-- {$dates|@count} activités -->
{if $commune} sur la commune de {$commune}{/if}
{foreach from=$dates item=date}
	{if $date->etat > 2}
	{assign var=sortie value=$date->sortie}
	{$sortie->date_sortie}
	{assign var=point value=$sortie->point()}
	{assign var=commune value=$point->get_commune()}
	{assign var=id_espace_point value=""}
	{assign var=x value=""}
	{assign var=y value=""}
	{assign var=pays value=""}
	{if $point}
		{assign var=id_espace_point value=$point->id_espace}
		{assign var=x value=$point->get_x()}
		{assign var=y value=$point->get_y()}
		{if $commune}
			{assign var=pays value=$commune->id_pays}
		{/if}
	{/if}

	<div class="activite panel panel-default panel-cal-pole{$sortie->id_sortie_pole}" data-id-sortie="{$sortie->id_sortie}" data-pole="{$sortie->id_sortie_pole}" data-id-espace-point="{$id_espace_point}" data-x="{$x}" data-y="{$y}" data-pays="{$pays}">
		<div class="panel-heading"> 
			{if $date->etat eq 4}
				<span class="label label-danger pull-right">Sortie annulée</span>
			{/if}
			<span class="activite-titre">{$sortie}</span>
		</div> 
		<div class="panel-body">
			<span class="activite-desc">{$sortie->description|markdown}</span>
			{if $point}
			<a title="placer sur la carte" href="#" data-x="{$x}" data-y="{$y}" class="btn-activite-map pull-right" style="font-size:28px; color:black;"><i class="fa fa-map-marker fa-fw"></i></a>
			{/if}
			<a class="btn btn-default" href="?page=sortie_detail&id_sortie={$sortie->id_sortie}&date={$date->date_sortie|urlencode}">Plus d'informations sur cette activité</a>
		</div>
		<div class="panel-footer">
			<span class="activite-date">{$date->date_sortie|date_format:"%A %e %B à %Hh%M"}</span>
			{if $commune}
				<div class="btn-group pull-right sorties-btn-commune">
					<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
						{$commune} <span class="caret"></span>
					</button>
					<ul class="dropdown-menu" role="menu">
						<li><a href="http://obs.picardie-nature.org/?page=commune&id={$commune->id_espace}">Fiche Clicnat de la commune</a></li>
						<li><a href="?rubrique57&id_commune={$commune->id_espace}">Toutes les activités sur cette commune</a></li>
					</ul>
				</div>
			{/if}
			<div class="clearfix"></div>
		</div>
	</div>
	{/if}
{/foreach}
