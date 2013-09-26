<?php
if (!isset($argv[1]) || !file_exists($argv[1])) {
	echo "usage: php csv_qgis.php document.xml\n";
	exit(1);
}

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

$output = fopen('php://stdout','w');

fputcsv($output, array("nom","Y","X","date","pole"));
foreach ($doc->sorties() as $s) {
	fputcsv($output, array($s->nom, $s->latitude,$s->longitude, $s->date(), $s->pole_n));
}
?>
