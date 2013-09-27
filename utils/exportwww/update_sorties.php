<?php
if (file_exists("conf_local.php")) {
	require_once("conf_local.php");
}

define('_ECRIRE_INC_VERSION', 'x'); // pour pouvoir utiliser spip_connect_db()

if (!defined('URL_EXPORT_SORTIES'))
	define('URL_EXPORT_SORTIES', "http://sorties.picardie-nature.org/?t=export_json");

if (!defined('URL_EXPORT_SORTIES_SECRET'))
	define('URL_EXPORT_SORTIES_SECRET', 'coin');

if (!defined('CHEMIN_CONF_SPIP')) {
	define('CHEMIN_CONF_SPIP', '../config/connect.php');
}
$db = false;

function spip_connect_db($host, $port, $user, $passwd, $dbname, $type_db, $prefix) {
	// pas vérifié params port et prefix
	global $db;
	$db = new PDO("mysql:host=$host;dbname=$dbname", $user, $passwd);
}

require_once(CHEMIN_CONF_SPIP);

if (!$db) {
	throw new Exception('Echec connexion à la base');
}

$STDERR = fopen('php://stderr', 'w+');

$cu = curl_init();
curl_setopt($cu, CURLOPT_URL, URL_EXPORT_SORTIES);
curl_setopt($cu, CURLOPT_RETURNTRANSFER, true);
curl_setopt($cu, CURLOPT_POST, true);
curl_setopt($cu, CURLOPT_POSTFIELDS, "key=".URL_EXPORT_SORTIES_SECRET);

$j_data = curl_exec($cu);
if (trim($j_data) == "Restricted access") {
	throw new Exception("Mauvaise clé voir la directive URL_EXPORT_SORTIES_SECRET");
}
$data = json_decode($j_data, true);

/* meme si en vrai myisam le supporte pas.. */
$sql = array();
$sql[] = "START TRANSACTION";

foreach (array_keys($data) as $k) {
	switch ($k) {
		case 'sorties':
			$sql[] = "CREATE TABLE IF NOT EXISTS `sorties` (
				`id_sortie` INTEGER PRIMARY KEY,
				`nom_sortie` VARCHAR(255),
				`orga_nom` VARCHAR(255),
				`orga_prenom` VARCHAR(255),
				`orga_tel` VARCHAR(255),
				`orga_portable` VARCHAR(255),
				`orga_mail` VARCHAR(255),
				`desc` TEXT,
				`commune` VARCHAR(255),
				`departement` INTEGER,
				`longitude` FLOAT,
				`latitude` FLOAT,
				`description_lieu` TEXT,
				`duree_heure` FLOAT,
				`gestion_picnat` INTEGER,
				`accessible_mobilite_reduite` INTEGER,
				`accessible_deficient_auditif` INTEGER,
				`accessible_deficient_visuel` INTEGER,
				`structure` VARCHAR(255),
				`pole` INTEGER,
				`id_sortie_reseau` INTEGER,
				`id_sortie_type` INTEGER,
				`id_sortie_public` INTEGER,
				`id_sortie_cadre` INTEGER,
				`id_sortie_pole` INTEGER
			)";
			$sql[] = "CREATE TABLE IF NOT EXISTS `sortie_materiel_l` (
					id_sortie INTEGER,
					id_sortie_materiel INTEGER,
					a_prevoir INTEGER
			)";
			$sql[] = "CREATE TABLE IF NOT EXISTS `sortie_date` (
					id_date_sortie INTEGER PRIMARY KEY,
					id_sortie INTEGER,
					date_sortie DATETIME,
					etat INTEGER,
					inscription_prealable INTEGER,
					inscription_date_limite DATETIME,
					inscription_participants_max INTEGER
			)";
			$sql[] = "CREATE OR REPLACE VIEW `sortie_dates_v` AS
				SELECT
					sd.id_date_sortie,
					sd.etat,
					sd.inscription_prealable,
					sd.inscription_date_limite,
					sd.inscription_participants_max,
					date(sd.date_sortie) as date_sortie,
					date_sortie as date_heure_sortie,
					s.*
				FROM sortie_date sd,sorties s
				WHERE sd.id_sortie=s.id_sortie";
			$sql[] = "CREATE OR REPLACE VIEW `sortie_dates_resum_v` AS
				SELECT
					date(sd.date_sortie) as date_sortie,
					count(*) as n,
					sp.libelle,
					s.pole
				FROM  sortie_date sd, sorties s,sortie_pole sp
				WHERE sd.id_sortie=s.id_sortie
				AND sp.id_sortie_pole=s.pole
				AND sd.etat = 3
				GROUP BY date(sd.date_sortie), sp.libelle,sp.id_sortie_pole";
			foreach ($data[$k] as $entry) {
				$id_sortie = $entry['id_sortie'];
				$sql_vars = array();
				$sql_values = array ();
				$sql_idx = 0;
				foreach (array_keys($entry) as $ek) {
					$entry_value = $entry[$ek];
					switch ($ek) {
						case 'date_proposition':
						case 'id_utilisateur_propose':
						case 'orga_adresse':
							continue;
							break;
						case 'materiels':
							$sql[] = "DELETE FROM `sortie_materiel_l` WHERE id_sortie={$id_sortie}";
							foreach ($entry[$ek] as $mat) {
								$a_prevoir = $mat['a_prevoir'];
								if (!empty($a_prevoir)) {
									$sql[] = "INSERT INTO `sortie_materiel_l` (
											id_sortie,
											id_sortie_materiel,
											a_prevoir
										) VALUES (
											{$id_sortie},
											{$mat['id_materiels_sortie']},
											{$mat['a_prevoir']}
										)";
								}
							}
							break;
						case 'xy':
							foreach (array_keys($entry_value) as $ll) {
								$sql_vars[$sql_idx] = $ll;
								$sql_values[$sql_idx] = $entry_value[$ll];
								$sql_idx += 1;
							}
							break;
						case 'reseau_sortie':
							$ek = 'id_sortie_reseau';
							break;
						case 'date_sortie':
							$sql[] = "DELETE FROM `sortie_date` WHERE id_sortie={$id_sortie}";
							$n_date = 1;
							foreach ($entry[$ek] as $date) {
								$id_date_sortie = ($id_sortie * 1000) + $n_date; //crapou, mais y'a pas d'id
								$n_date += 1;
								$date_sortie = "'{$date['date_sortie']}'";
								$etat = "'{$date['etat']}'";
								$inscription_prealable = ( empty($date['inscription_prealable']) ? 'NULL' : $date['inscription_prealable'] );
								$inscription_date_limite = ( empty($date['inscription_date_limite']) ? 'NULL' : "'{$date['inscription_date_limite']}'" );
								$inscription_participants_max = ( empty($date['inscription_participants_max']) ? 'NULL' : $date['inscription_participants_max'] );
								$sql[] = "INSERT INTO `sortie_date` (
										id_date_sortie,
										id_sortie,
										date_sortie,
										etat,
										inscription_prealable,
										inscription_date_limite,
										inscription_participants_max
									) VALUES (
										$id_date_sortie,
										$id_sortie,
										$date_sortie,
										$etat,
										$inscription_prealable,
										$inscription_date_limite,
										$inscription_participants_max
									)";
							}
							break;
						case 'nom_sortie':
						case 'orga_nom':
						case 'orga_prenom':
						case 'orga_tel':
						case 'orga_portable':
						case 'orga_mail':
						case 'desc':
						case 'commune':
						case 'departement':
						case 'description_lieu':
						case 'structure':
							$entry_value = "'". str_replace("'", "''", $entry_value). "'";
						case 'gestion_picnat':
						case 'accessible_mobilite_reduite':
						case 'accessible_deficient_auditif':
						case 'accessible_deficient_visuel':
							if (empty($entry_value)) {
								$entry_value = 0;
							}
						default:
							$sql_vars[$sql_idx] = $ek;
							$sql_values[$sql_idx] = $entry_value;
							$sql_idx += 1;
							break;
					}
		                }
				for ($i = 0; $i < count($sql_vars); $i++) {
					$sql_vars[$i] = "`{$sql_vars[$i]}`";
				}
				$sql_1 = join($sql_vars, ',');
				$sql_2 = join($sql_values, ',');
				$sql[] = "REPLACE INTO `sorties` ({$sql_1}) VALUES ({$sql_2})";
			}
			break;
		default:
			fwrite ($STDERR,"Doing $k\n");
			if (preg_match("/^(.+)(s|x)_(.+)$/", $k, $parts)) {
				$table = "{$parts[3]}_{$parts[1]}";
				$id_table = "id_{$table}";
				$sql[] = "CREATE TABLE IF NOT EXISTS `{$table}` (`{$id_table}` INTEGER PRIMARY KEY, `libelle` VARCHAR(255))";
				$sql[] = "DELETE FROM `$table`;\n";
				foreach ($data[$k] as $entry) {
					$libelle = str_replace ("'", "''", $entry['lib']);
					$sql[] = "INSERT INTO `{$table}` (`{$id_table}`, `libelle`) VALUES ({$entry[$id_table]}, '{$libelle}')";
				}
			} else {
				fwrite ($STDERR, "  Unknown...\n");
			}
			break;
	}
}
$sql[] = "COMMIT";
foreach ($sql as $req) {
	if ($db->exec($req) === false) {
		echo "échec : $req\n";
		print_r($db->errorInfo());
	}
}
?>
