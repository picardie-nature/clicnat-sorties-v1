// indexOf existe pas sur IE
if (!Array.indexOf) {
	Array.prototype.indexOf = function(obj) {
		for (var i=0; i<this.length; i++) {
			if (this[i]==obj) {
				return i;
			}
		}
		return -1;
	}
}

function saisie_set_marqueur_pos(carte,layer) {
	var p = new OpenLayers.LonLat(document.fcreation.x.value, document.fcreation.y.value);
	for (var i=0; i<layer.markers.length; i++)
		layer.removeMarker(layer.markers[i]);
	p.transform(carte.displayProjection, carte.projection);
	layer_marqueur_ajouter_icone(layer, p, 'image/panoramic.png', 32, 37);
	return p;
}

// debut du valable partout
function carte_ajout_layer_marqueurs(map,titre) {
	var markers = new OpenLayers.Layer.Markers(titre);
	map.addLayer(markers);
	return markers;
}

function carte_ajout_layer_vecteurs(map, titre) {
	var vecteur = new OpenLayers.Layer.Vector(titre);
	map.addLayer(vecteur);
	return vecteur;
}

function carte_ajout_layer_wfs(map, id_liste, titre, mention, style) {
	var lv  = new OpenLayers.Layer.Vector(titre, {
		styleMap: style,
		strategies: [new OpenLayers.Strategy.BBOX()],
		projection: m.displayProjection,
		protocol: new OpenLayers.Protocol.WFS({
			url: "?t=liste_espace_carte_wfs",
			featureType: "liste_espace_"+id_liste,
			featureNS: "http://www.clicnat.org/espace"
		}),
		attribution: mention
	});
	map.addLayer(lv);
	return lv;
}

function layer_marqueur_ajouter_icone(layer, point, image, width, height)
{
	var size = new OpenLayers.Size(width, height);
	var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
	var icon = new OpenLayers.Icon(image, size, offset);
	var marqueur = new OpenLayers.Marker(point, icon);
	layer.addMarker(marqueur);
}

function carte_inserer(imap) {
	var options = {
		projection: new OpenLayers.Projection('EPSG:900913'),
		displayProjection: new OpenLayers.Projection('EPSG:4326'),
		units: "m",
		numZoomLevels: 20,
		maxExtent: new OpenLayers.Bounds(-20037508, -20037508, 20037508, 20037508.34)
	};
	imap = new OpenLayers.Map(imap.id, options);
	var ghyb = new OpenLayers.Layer.Google("Google Hybride", 
				{type: google.maps.MapTypeId.HYBRID, sphericalMercator: true});
	imap.addLayers([ghyb]);
	return imap;
}

function marqueur_existe_et_unique(layer) {
	return layer.markers.length == 1;
}

function marqueur_est_visible(layer) {	
	if (marqueur_existe_et_unique(layer)) {
		var marqueur = layer.markers[0];
		return layer.map.getExtent().containsLonLat(marqueur.lonlat, true);
	}
	return false;
}

/*function selection_commune_affichage(o) {
	lc.removeFeatures(lc.features);
	var geojson_format = new OpenLayers.Format.GeoJSON({
		'internalProjection': lc.map.projection,
		'externalProjection': lc.map.displayProjection
	});
	features = geojson_format.read(o.responseJSON);
	features[0].style = {
	    fillOpacity: 0,
	    strokeWidth: 4,
	    strokeOpacity: 1,
	    strokeDashstyle: 'longdash',
	    strokeColor: '#ff0000'
	};
	lc.addFeatures(features);
	lc.map.zoomToExtent(lc.getDataExtent());
}*/

function selection_commune(id_espace) {
	var url = '?t=json&a=commune&id='+id_espace;
	J('srch_commune').value = '';
	new J.ajax({
		url: '?'+J.param({
			t: 'commune_gml',
			id: id_espace,
			dataType: 'xml'
		}),
		success: function (data, s, xhr) {
			lc.removeFeatures(lc.features);
			var format = new OpenLayers.Format.GML({
				'internalProjection': lc.map.projection,
				'externalProjection': lc.map.displayProjection
			});
			var feature = format.parseFeature(data);
			feature.style = {
			    fillOpacity: 0,
			    strokeWidth: 4,
			    strokeOpacity: 1,
			    strokeDashstyle: 'longdash',
			    strokeColor: '#ff0000'
			};
			lc.addFeatures(feature);
			lc.map.zoomToExtent(lc.getDataExtent());
		}
	});
}

function init_search_commune() {
	J('#srch_commune').autocomplete({source: '?t=autocomplete_commune',
		select: function (event,ui) {
			selection_commune(ui.item.value);
		    	event.target.value = '';
			return false;
		}
	});
}

function set_marqueur_pos(carte,layer,x,y) {
	var p = new OpenLayers.LonLat(x,y);
	for (var i=0; i<layer.markers.length; i++)
		layer.removeMarker(layer.markers[i]);
	p.transform(carte.displayProjection, carte.projection);
	layer_marqueur_ajouter_icone(layer, p, 'image/panoramic.png', 32, 37);
	return p;
}
