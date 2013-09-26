<?php
class ElemSortie {
	private $elem;

	public function __construct($elem) {
		$this->elem = $elem;
	}

	public function __get($attr) {
		foreach ($this->elem->getElementsByTagName($attr) as $e)
			return $e->nodeValue;
		throw new Exception('attribut inconnu');
	}

	public function __toString() {
		return $this->__get($nom);
	}

	public function date() {
		return $this->elem->getAttribute('date');
	}
}

class DocSortie extends DOMDocument {
	public function sorties() {
		$t = array();
		foreach ($this->getElementsByTagName('sortie') as $sortie) {
			$t[] = new ElemSortie($sortie);
		}
		return $t;
	}
}

$doc = new DocSortie();
$doc->load($argv[1]);
$geojson = array(
	"type" => "FeatureCollection",
	"features" => array()
);

foreach ($doc->sorties() as $s) {
	$geojson['features'][] = array(
		"type" => "Feature",
		"geometry" => array(
			"type" => "Point",
			"coordinates" => array($s->longitude, $s->latitude),
		),
		"properties" => array(
			"date" => $s->date(),
			"date_txt" => $s->date,
			"nom" => $s->nom,
			"description" => $s->description,
			"sortie_type" => $s->sortie_type,
			"sortie_type_n" => $s->sortie_type_n
		)
	);
}

echo json_encode($geojson);
?>
