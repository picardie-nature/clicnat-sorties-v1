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
if (!isset($_SERVER['REMOTE_ADDR'])) {
	die("Dans un navigateur !\n");
}
switch ($_SERVER['REMOTE_ADDR']) {
	case '127.0.0.1':
	case '::1':
	case '212.85.132.58':
		break;
	default:
		header('HTTP/1.1 403 Forbidden');
		echo "Acces interdit {$_SERVER['REMOTE_ADDR']}";
		exit();
}
if (file_exists('connexion.php')) {
	require_once('connexion.php');
	$mysql_host = HOST;
	$mysql_port = PORT;
	$mysql_user = USER;
	$mysql_password = PASSWORD;
	$mysql_database = DATABASE;
} else {
	$mysql_host = 'localhost';
	$mysql_port = '3306';
	$mysql_user = 'dev';
	$mysql_password = 'pwd';
	$mysql_database = 'spip';
}


$champs = array(
	'id_sortie',
	'date',
	'heure_depart',
	'departement_nom',
	'grille_x',
	'grille_y',
	'materiel_autre',
	'nom',
	'description',
	'heure_depart_bis',
	'description_lieu',
	'commune',
	'lonlat',
	'sortie_type',
	'sortie_public',
	'inscription_prealable',
	'inscription_participants_max',
	'inscription_date_limite',
	'orga_prenom',
	'orga_nom',
	'structure',
	'mail_reservation',
	'contact_reservation',
	'etat_lib',
	'id_utilisateur_propose',
	'date_proposition',
	'adresse',
	'tel',
	'portable',
	'mail',
	'id_espace_point',
	'duree_heure',
	'gestion_picnat',
	'sortie_type_n',
	'sortie_type_picto',
	'accessible_mobilite_reduite',
	'accessible_deficient_auditif',
	'accessible_deficient_visuel',
	'sortie_cadre',
	'materiels',
	'validation_externe',
	'reseau_n',
	'reseau',
	'pole_n',
	'pole',
	'departement',
	'duree',
	'duree_lib',
	'pied',
	'image_personne',
	'illustration',
	'longitude',
	'latitude',
	'pole_couleur',
	'departement_n'
);
const sql_drop = 'drop table if exists SORTIES_IMP';
const sql_ci_1 = 'drop table if exists SORTIES';
const sql_ci_2 = 'alter table SORTIES_IMP rename_to SORTIES';
const sql_create = 'create table if not exists SORTIES_IMP (
	id_sortie integer,
	date datetime,
	heure_depart varchar(20),
	departement_nom varchar(30),
	grille_x varchar(10),
	grille_y varchar(10),
	materiel_autre text,
	nom text,
	description text,
	heure_depart_bis text,
	description_lieu text,
	commune varchar(200),
	lonlat varchar(200),
	sortie_type text,
	sortie_public text,
	inscription_prealable text,
	inscription_participants_max text,
	inscription_date_limite text,
	orga_prenom text,
	orga_nom text,
	structure text,
	mail_reservation text,
	contact_reservation text,
	etat_lib text,
	id_utilisateur_propose integer,
	date_proposition datetime,
	adresse text,
	tel text,
	portable  text,
	mail text,
	id_espace_point integer,
	duree_heure text,
	gestion_picnat text,
	sortie_type_n text,
	sortie_type_picto text,
	accessible_mobilite_reduite text,
	accessible_deficient_auditif text,
	accessible_deficient_visuel text,
	sortie_cadre text,
	materiels text,
	validation_externe text,
	reseau_n text,
	reseau text,
	pole_n text,
	pole text,
	departement text,
	duree text,
	duree_lib text,
	pied text,
	image_personne text,
	illustration text,
	longitude text,
	latitude text,
	pole_couleur text,
	departement_n integer,
	primary key(id_sortie,date)) character set utf8';

try {
	$db = new PDO("mysql:host=$mysql_host;port=$mysql_port;dbname=$mysql_database", $mysql_user, $mysql_password, array(PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"));
	$db->exec(sql_drop);
	if ($db->exec(sql_create) === false) {
		echo "Echec create table";
		echo sql_create;
		exit(1);
	}
	$f = fopen('php://input','r');
	$xml_src = '';
	while ($ligne = fgets($f)) {
		$xml_src.=$ligne;
	}
	$doc = new DocSortie();
	$doc->loadXML($xml_src);

	$sql_champs = '';
	$sql_values = '';
	foreach ($champs as $champ) {
		$sql_champs .= "$champ,";
		$sql_values .= ":$champ,";
	}
	$sql_champs = trim($sql_champs, ',');
	$sql_values = trim($sql_values, ',');
	$sql_insert = "insert into SORTIES_IMP ($sql_champs) values ($sql_values)";
	
	$insert = $db->prepare($sql_insert);

	foreach ($doc->sorties() as $s) {
		foreach ($champs as $champ) {
			$insert->bindValue(":$champ", $s->$champ);
		}
		$n = $insert->execute();
	}
	$db->exec(sql_ci_1);
	$db->exec(sql_ci_2);
} catch (PDOException $e) {
	echo "ERREUR_DB\n";
	print_r($e);
	exit(1);
} catch (Exception $e) {
	echo "ERREUR\n";
	echo "<pre>";
	print_r($e);
	echo "</pre>";
	exit(1);
}
echo "OK";
?>
