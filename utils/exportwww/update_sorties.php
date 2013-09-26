<?php

$url_export_sorties = "http://sorties.picardie-nature.org/?t=export_json";
$key_export_sortie = "LesPetitsOiseauxGazouillent";

$STDERR = fopen('php://stderr', 'w+');

if (0) {
$cu = curl_init();
curl_setopt($cu, CURLOPT_URL, $url_export_sorties);
curl_setopt($cu, CURLOPT_RETURNTRANSFER, true);
curl_setopt($cu, CURLOPT_POST, true);
curl_setopt($cu, CURLOPT_POSTFIELDS, "key=$key_export_sortie");
$j_data = curl_exec($cu);
} else {
$j_data = file_get_contents("data.json");
}
$data = json_decode($j_data, true);

/*
print_r(array_keys($data));
    [0] => types_sortie
    [1] => publics_sortie
    [2] => poles_sortie
    [3] => cadres_sortie
    [4] => materiels_sortie
    [5] => reseaux_sortie
    [6] => sorties
*/

/* meme si en vrai myisam le supporte pas.. */
$sql = "START TRANSACTION;\n";

foreach (array_keys($data) as $k) {
    switch ($k) {
        case 'sorties':
/*
  [id_sortie] => 
  [id_utilisateur_propose] => 
  [date_proposition] => 
  [nom_sortie] => 
  [orga_nom] => 
  [orga_prenom] => 
  [orga_adresse] =>
  [orga_tel] => 
  [orga_portable] =>
  [orga_mail] =>
  [desc] => 
  [commune] => .
  [departement] => .
  [xy] => Array ( [longitude] => 2.4069510829995 [latitude] => 49.258291561971)
  [description_lieu] => 
  [duree_heure] => 
  [gestion_picnat] =>
  [accessible_mobilite_reduite] =>
  [accessible_deficient_auditif] =>
  [accessible_deficient_visuel] =>
  [structure] =>
  [pole] => 1
  [reseau_sortie] =>
  [id_sortie_type] =>
  [id_sortie_public] =>
  [id_sortie_cadre] =>
  [date_sortie] => Array
*/
            $sql .= "CREATE TABLE IF NOT EXISTS `sorties`
                        (`id_sortie` INTEGER PRIMARY KEY, `nom_sortie` VARCHAR(255), 
                         `orga_nom` VARCHAR(255), `orga_prenom` VARCHAR(255), `orga_tel` VARCHAR(255), `orga_portable` VARCHAR(255), `orga_mail` VARCHAR(255),
                         `desc` TEXT, `commune` VARCHAR(255), `departement` INTEGER, `longitude` FLOAT, `latitude` FLOAT, `description_lieu` TEXT, `duree_heure` FLOAT, `gestion_picnat` INTEGER,
                         `accessible_mobilite_reduite` INTEGER, `accessible_deficient_auditif` INTEGER, `accessible_deficient_visuel` INTEGER,
                         `structure` VARCHAR(255), `pole` INTEGER, `id_sortie_reseau` INTEGER, `id_sortie_type` INTEGER, `id_sortie_public` INTEGER, `id_sortie_cadre` INTEGER
                         );\n";
            $sql .= "CREATE TABLE IF NOT EXISTS `sortie_materiel_l` (id_sortie INTEGER, id_sortie_materiel INTEGER, a_prevoir INTEGER);\n";
            $sql .= "CREATE TABLE IF NOT EXISTS `sortie_date` (id_date_sortie INTEGER PRIMARY KEY, id_sortie INTEGER, date_sortie DATETIME, etat INTEGER, inscription_prealable INTEGER, inscription_date_limite DATETIME, inscription_participants_max INTEGER);\n";

            $sql .= "CREATE OR REPLACE VIEW `sortie_dates_v` AS
                        SELECT sd.id_date_sortie,sd.etat,sd.inscription_prealable,sd.inscription_date_limite,sd.inscription_participants_max,s.*
                        FROM sortie_date sd,sorties s
                        WHERE sd.id_sortie=s.id_sortie;\n";
            foreach ($data[$k] as $entry) {
#                print_r($entry);
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
                            $sql .= "DELETE FROM `sortie_materiel_l` WHERE id_sortie={$id_sortie};\n";
                            foreach ($entry[$ek] as $mat) {
                                $a_prevoir = $mat['a_prevoir'];
                                if (!empty($a_prevoir)) {
                                    $sql .= "INSERT INTO `sortie_materiel_l` (id_sortie, id_sortie_materiel, a_prevoir) VALUES ({$id_sortie}, {$mat['id_materiels_sortie']}, {$mat['a_prevoir']});\n";
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
/*
   [date_sortie] => 2012-07-19 00:00:00
   [etat] => 4
   [inscription_prealable] => 
   [inscription_date_limite] => 
   [inscription_participants_max] => 0
*/
                            $sql .= "DELETE FROM `sortie_date` WHERE id_sortie={$id_sortie};\n";
                            $n_date = 1;
                            foreach ($entry[$ek] as $date) {
#                                print_r($date);
                                $id_date_sortie = ($id_sortie * 1000) + $n_date; //crapou, mais y'a pas d'id
                                $n_date += 1;
                                $date_sortie = "'{$date['date_sortie']}'";
                                $etat = "'{$date['etat']}'";
                                $inscription_prealable = ( empty($date['inscription_prealable']) ? 'NULL' : $date['inscription_prealable'] );
                                $inscription_date_limite = ( empty($date['inscription_date_limite']) ? 'NULL' : "'{$date['inscription_date_limite']}'" );
                                $inscription_participants_max = ( empty($date['inscription_participants_max']) ? 'NULL' : $date['inscription_participants_max'] );
                                $sql .= "INSERT INTO `sortie_date` (id_date_sortie, id_sortie, date_sortie, etat, inscription_prealable, inscription_date_limite, inscription_participants_max) VALUES ($id_date_sortie, $id_sortie, $date_sortie, $etat, $inscription_prealable, $inscription_date_limite, $inscription_participants_max);\n";
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
#                print_r($sql_vars);
#                print_r($sql_values);
                for ($i = 0; $i < count($sql_vars); $i++) {
                    $sql_vars[$i] = "`{$sql_vars[$i]}`";
                }
                $sql_1 = join($sql_vars, ',');
                $sql_2 = join($sql_values, ',');
                $sql_i = "REPLACE INTO `sorties` ({$sql_1}) VALUES ({$sql_2});\n";
                $sql .= $sql_i;
            }
            break;
        default:
            fwrite ($STDERR,"Doing $k\n");
            if (preg_match("/^(.+)(s|x)_(.+)$/", $k, $parts)) {
                # print_r($parts);
                $table = "{$parts[3]}_{$parts[1]}";
                $id_table = "id_{$table}";
                $sql .= "CREATE TABLE IF NOT EXISTS `{$table}` (`{$id_table}` INTEGER PRIMARY KEY, `libelle` VARCHAR(255));\n";
                $sql .= "DELETE FROM `$table`;\n";
                foreach ($data[$k] as $entry) {
#                    print_r($entry);
                    $libelle = str_replace ("'", "''", $entry['lib']);
                    $sql .= "INSERT INTO `{$table}` (`{$id_table}`, `libelle`) VALUES ({$entry[$id_table]}, '{$libelle}');\n";
                }
            } else {
                fwrite ($STDERR, "  Unknown...\n");
            }
            break;
    }

}
$sql .= "COMMIT;\n";

print $sql;

?>
