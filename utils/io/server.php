<?php
require_once('/etc/baseobs/config.php');
require_once(DB_INC_PHP);
require_once(OBS_DIR.'espace.php');
require_once(OBS_DIR.'sorties.php');

setlocale(LC_ALL, "fr_FR.UTF8");
get_db($db);
$etats = array(3);
$types = array(1,2,3,4,5,6,7,8,9,10);
$date_deb = strftime("%Y-%m-%d");
$date_fin =  strftime("%Y-%m-%d", mktime()+86400*60);
$url = "http://localhost/picardie-nature.org/nico/www/client.php";

$sorties = clicnat_sortie::sorties_extraction($db, 'xml',$date_deb, $date_fin, $etats, $types);

function envoi($url, $data) {
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
	return curl_exec($ch);
}
$r = envoi($url, $sorties);
print_r($r);
echo "\n";
?>
