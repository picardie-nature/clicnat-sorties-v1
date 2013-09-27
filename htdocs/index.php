<?php
/**
 * Gestion des sorties
 *
 **/

$start_time = microtime(true);
define('CONFIG_FILE', '/etc/baseobs/config.php');
//define('CONFIG_FILE', '/home/domi/etc/baseobs/config.php');

if (!file_exists(CONFIG_FILE))
	die('Ne peut ouvrir le fichier de configuration '.CONFIG_FILE);

require_once(CONFIG_FILE);

if (!file_exists(SMARTY_COMPILE_SORTIES))
	mkdir(SMARTY_COMPILE_SORTIES);

define('SESS', 'SORTIE');

define('LOCALE', 'fr_FR.UTF-8');

require_once(OBS_DIR.'smarty.php');
require_once(OBS_DIR.'utilisateur.php');
require_once(OBS_DIR.'espace.php');
require_once(OBS_DIR.'sorties.php');

// On ne veut pas de notices dans les sorties CSV ou XML...
$_current_err_reporting = error_reporting();
error_reporting( $_current_err_reporting ^ E_NOTICE );

$context = "sortie";

class ExceptionErrAuth extends Exception {}
class ExceptionReglement extends Exception {}

class Sortie extends clicnat_smarty {
	const admins = '2204,2819,2109,2033,3021,3102,3230,3224';

	private function is_admin($id) {
		$admins = explode(',', self::admins);
		return array_search($id, $admins) !== false;
	}

	function __construct($db) {
		parent::__construct($db, SMARTY_TEMPLATE_SORTIES, SMARTY_COMPILE_SORTIES, SMARTY_CONFIG_SORTIES);
		$this->cache_dir = '/tmp/cache_sortie';
		if (!file_exists('/tmp/cache_sortie')) mkdir('/tmp/cache_sortie');
		$this->bobs_msgs = array();
	}
	
	private function template($selection_tpl = false) {
		$template = (empty($_POST['t'])?(empty($_GET['t'])?'accueil':$_GET['t']):$_POST['t']);
		return $template;
	}

	protected function default_assign() {
 	}

	protected function session() {
		session_start();
		$this->assign('auth_ok', false);
		if (array_key_exists(SESS, $_SESSION)) {
			if (array_key_exists('auth_ok', $_SESSION[SESS]))
				if ($_SESSION[SESS]['auth_ok']) 
					$this->assign('auth_ok', true);
		} else {
			$_SESSION[SESS] = array('auth_ok' => false);
		}
	}

	private function get_user_session($reset=false) {
		if ($this->authok()) {
			if (!empty($_SESSION[SESS]['id_utilisateur']) || $reset)				
				return new bobs_utilisateur($this->db, $_SESSION[SESS]['id_utilisateur']);
			else
				throw new ExceptionErrAuth();
		}
		return false;
	}

	public function before_accueil() {
		$_POST['act']=array_key_exists('act', $_POST)?self::cls($_POST['act']):null;
		$_POST['username']=array_key_exists('username', $_POST)?self::cls($_POST['username']):null;
		$_POST['password']=array_key_exists('password', $_POST)?self::cls($_POST['password']):null;

		if ($this->authok()) {
			$u = $this->get_user_session();
			if (isset($_GET['supprimer_brouillon'])) {
				$sortie = new clicnat_sortie($this->db, $_GET['supprimer_brouillon']);
				if ($sortie->id_utilisateur_propose == $u->id_utilisateur) {
					$sortie->supprimer();
					$this->redirect('?t=accueil');
				}
			}
			$this->assign_by_ref('sans_dates', clicnat_sortie::sans_dates($this->db, $u->id_utilisateur));
			$this->assign_by_ref('en_attente', clicnat_sortie_date::en_attente($this->db, $u->id_utilisateur));
			$this->assign_by_ref('pas_retenues', clicnat_sortie_date::pas_retenues($this->db, $u->id_utilisateur));
			$this->assign_by_ref('valides', clicnat_sortie_date::valides($this->db, $u->id_utilisateur));
			$this->assign_by_ref('annulees', clicnat_sortie_date::annulees($this->db, $u->id_utilisateur));
		}

		if ($_POST['act'] == 'login') {
			if (empty($_POST['username']))
				return;
			$u = bobs_utilisateur::by_login($this->db, $_POST['username']);
			if ($u && $u->auth_ok($_POST['password'])) {
				$this->assign('username', $u->username);
				$this->assign('id_utilisateur', $u->id_utilisateur);
				$this->assign('auth_ok', true);
				$this->bobs_msgs[] =  'Bienvenue';
				$redir = '?t=accueil';
				if (!empty($_POST['redir']))
					$redir = str_replace('"', '', $_POST['redir']);
				$this->assign('redir', $redir);
				$_SESSION[SESS]['auth_ok'] = true;
				$_SESSION[SESS]['id_utilisateur'] = $u->id_utilisateur;
				bobs_log(sprintf("login user id %d ok", $u->id_utilisateur));
				$this->redirect($redir);
			} else {
				$_SESSION[SESS]['auth_ok'] = false;
				$this->assign('auth_ok', false);
				$this->bobs_msgs[] = "Nom d'utilisateur ou mot de passe incorrect";
				return;
			}
		} else if (isset($_GET['fermer'])) {
			$this->assign('auth_ok', false);
			$this->bobs_msgs[] =  "Vous êtes déconnecté";
			$_SESSION[SESS]['auth_ok'] = false;
			session_destroy();
			return;
		}
	}

	public function before_proposer() {
		$u = $this->get_user_session();
		$nouvelle = clicnat_sortie::nouvelle($this->db, $u->id_utilisateur);
		$this->redirect("?t=editer&sortie={$nouvelle->id_sortie}");
	}
	
	public function before_editer() {
		$u = $this->get_user_session();
		$sortie = new clicnat_sortie($this->db, (int)$_GET['sortie']);
	
		if ($this->is_admin($u->id_utilisateur))
			$this->assign('admin', true);
		else
			$this->assign('admin', false);

		$editable = false;
		if ($sortie->id_utilisateur_propose == $u->id_utilisateur) {
			$editable = true;
		}
		if (!$editable) {
			if ($this->is_admin($u->id_utilisateur))
				$editable = true;
		}
		if ($editable && isset($_GET['annuler_loc'])) {
			$sortie->annuler_localisation();
			$this->redirect("?t=editer&sortie={$sortie->id_sortie}");
		}
		$this->assign('edit', $editable);
		if (isset($_GET['update'])) {
			$champs = explode(',','nom,orga_nom,orga_prenom,adresse,tel,portable,mail,id_sortie_type,id_sortie_public,gestion_picnat,accessible_mobilite_reduite,accessible_deficient_auditif,accessible_deficient_visuel,id_sortie_cadre,description,description_lieu,duree_heure,structure,validation_externe,materiel_autre,id_sortie_pole,id_sortie_reseau');
			$bools_f = explode(',','gestion_picnat,accessible_mobilite_reduite,accessible_deficient_auditif,accessible_deficient_visuel,validation_externe');
			foreach ($bools_f as $k)
				$_POST[$k] = isset($_POST[$k])&&$_POST[$k]==1?'t':'f';
			if (empty($_POST['duree_heure'])) $_POST['duree_heure'] = 0;
			if (empty($_POST['id_sortie_pole'])) $_POST['id_sortie_pole'] = 1;
			foreach (array_keys($_POST) as $k) {
				if (array_search($k, $champs) !== false)
					$sortie->update_field($k, $_POST[$k]);
			}
			if (empty($sortie->id_espace_point)) {
				if (isset($_POST['x']) && isset($_POST['y'])) {
					if (!empty($_POST['x']) && !empty($_POST['y'])) {
						$pt = array(
							'id_utilisateur' => $u->id_utilisateur,
							'reference' => "sortie {$sortie->id_sortie}",
							'nom' => "{$sortie->id_sortie}",
							'x' => $_POST['x'],
							'y' => $_POST['y']
						);
						$id_espace = bobs_espace_point::insert($this->db, $pt);
						$sortie->update_field('id_espace_point', $id_espace);
					}
				}
			}
			
			// on enleve tout pour le remettre après
			$sortie->materiel_vide();
			foreach (array_keys($_POST) as $k) {
				if (preg_match('/^materiel_(\d+)/', $k)) {
					$sortie->materiel_ajoute($_POST[$k]);
				}
			}

			$this->redirect("?t=editer_suiv&id_sortie={$sortie->id_sortie}");

		} else if (isset($_GET['ajouter_date'])) {
			$sortie = new clicnat_sortie($this->db, (int)$_GET['sortie']);
			$sortie->ajoute_date(bobs_element::date_fr2sql($_POST['date']));
			$this->redirect("?t=editer_suiv&id_sortie={$sortie->id_sortie}");
		}
		$sortie = new clicnat_sortie($this->db, (int)$_GET['sortie']);
		$this->assign_by_ref('sortie', $sortie);
	}

	public function before_calendrier() {
		$u = $this->get_user_session();
		$this->assign('id_utilisateur', $u->id_utilisateur);

		if (!isset($_GET['mois'])) $mois = strftime('%m', mktime());
		else $mois = (int)$_GET['mois'];

		if (!isset($_GET['annee'])) $annee = strftime('%Y', mktime());
		else $annee = (int)$_GET['annee'];

		$this->assign('mois', $mois);
		$this->assign('annee', $annee);

		$ddeb = new DateTime();
		$ddeb->setDate($annee,$mois,1);
		$ddeb->setTime(0,0,0);

		$dfin = clone $ddeb;
		$dfin->add(new DateInterval("P1M"));

		$this->assign('date_deb', $ddeb->format("Y-m-d"));
		$this->assign('date_fin', $dfin->format("Y-m-d"));
		$dmois_prev = clone $ddeb;
		$dmois_prev->sub(new DateInterval("P1D"));
		$dmois_suiv = clone $dfin;
		$dmois_suiv->add(new DateInterval("P1D"));

		$this->assign('url_prev', sprintf("?t=calendrier&mois=%d&annee=%d", $dmois_prev->format("m"), $dmois_prev->format("Y")));
		$this->assign('url_suiv', sprintf("?t=calendrier&mois=%d&annee=%d", $dmois_suiv->format("m"), $dmois_suiv->format("Y")));

		$dates = array();
	
		$dpos = clone $ddeb;

		$i = (intval($ddeb->format("w"))+6)%7;
		while ($i > 0) {
			$dates[] = false;
			$i--;
		}

		while ($dpos->getTimestamp() < $dfin->getTimestamp()) {
			$dates[] = array(
				'date' => $dpos->format("Y-m-d"),
				'sorties' => clicnat_sortie_date::par_date($this->db, $dpos->format("Y-m-d"))
			);
			$dpos->add(new DateInterval("P1D"));
		}
		$this->assign('dates', $dates);
	}

	public function before_suivi() {
		$u = $this->get_user_session();
		if (!$this->is_admin($u->id_utilisateur)) {
			throw new Exception("Vous n'êtes pas administrateur");	
		}
		$this->assign_by_ref('en_attente', clicnat_sortie_date::en_attente($this->db, 0));
		$this->assign_by_ref('dernieres_modifs', clicnat_sortie_date::dernieres_modifs($this->db, 0));
	}

	public function before_sel_xml() {
		$sorties_types = clicnat_sortie::types_sortie();
		$this->assign('sorties_types', $sorties_types);
	}

	public function before_xml() {
		$t = strftime("%Y-%m-%d_%H-%M-%S", mktime());

		$format = $_POST['format']=='xml'?'xml':'csv';

		$date_d = sprintf("%04d-%02d-%02d", $_POST['d_a'], $_POST['d_m'], $_POST['d_j']);
		$date_f = sprintf("%04d-%02d-%02d", $_POST['f_a'], $_POST['f_m'], $_POST['f_j']);
		$etats = $_POST['etats'];
		$types = $_POST['types'];

		if (!is_array($etats)) 
			throw new Exception('Cocher quelques états');

		if (!is_array($types)) 
			throw new Exception('Cocher au moins un type');

		if ($format == 'xml') {
			header ("Content-Type: text/xml");
			header ("Content-disposition: attachment; filename=sorties_$t.xml");
		} else {
			header("Content-Type: text/csv");
			header("Content-disposition: filename=sorties_$t.csv");

		}
		echo clicnat_sortie::sorties_extraction($this->db, $format, $date_d, $date_f, $etats, $types);
		exit();
	}

	public function before_export_json() {
		if (!defined('SORTIES_EXPORT_SECRET')) {
			throw new Exception('définir SORTIES_EXPORT_SECRET dans le fichier de configuration');
		}
		if ($_POST['key'] != SORTIES_EXPORT_SECRET) {
			die('Restricted access');
		}
		if (isset($_POST['datedeb'])) {
			$datedeb = $_POST['datedeb'];
		} else {
			$datedeb = strftime('%Y-%m-%d', time());
		}
		if (isset($_POST['dateall'])) {
			$dateall = true;
		} else {
			$dateall = false;
		}

		header ("Content-Type: application/json");
		header ("Content-disposition: attachment; filename=export_sorties_$t.json");

		$output = array();
		foreach (array('types_sortie', 'publics_sortie', 'poles_sortie', 'cadres_sortie', 'materiels_sortie', 'reseaux_sortie') as $t) {
			$output[$t]= clicnat_sortie::$t();
		}
		$sorties = clicnat_sortie::toutes($this->db);
		$output_sorties = array();
		foreach ($sorties as $s) {
			$date_s_fin = $s->derniere_date()->date_sortie;
			$point = $s->point();
			$departement = $point->get_departement();
			if (!$dateall and ($date_s_fin >= $datedeb)) {
				$sortie = array();
				foreach (clicnat_sortie::sorties_cols() as $c) {
					switch($c) {
						case 'nom_sortie':
							$v = $s->nom;
							break;
						case 'orga_adresse':
						case 'orga_tel':
						case 'orga_portable':
						case 'orga_mail':
							$k = str_replace('orga_', '', $c);
							$v = $s->$k;
							break;
						case 'date_sortie':
							$s_dates = $s->dates();
							$v = array();
							foreach ($s_dates as $date) {
								$v[] = array (
									'id_date_sortie' => $date->id_date_sortie,
									'date_sortie' => $date->date_sortie,
									'etat' => $date->etat,
									'inscription_prealable' => $date->inscription_prealable,
									'inscription_date_limite' => $date->inscription_date_limite,
									'inscription_participants_max' => intval($date->inscription_participants_max),
								);
							}
							break;
						case 'materiels':
							$mats = $s->materiels();
							$v = array();
							foreach ($mats as $m) {
								$v[] = array (
									'id_materiels_sortie' => intval($m['id_sortie_materiel']),
									'a_prevoir' => ($m['a_prevoir'] == 1) ? true : false
								);
							}
							break;
						case 'desc':
							$v = $s->description;
							break;
						case 'pole':
							 $v = intval($s->id_sortie_pole);
							 break;
						case 'reseau_sortie':
							 $v = intval($s->id_sortie_reseau);
							 break;

						case 'xy':
							$v = array (
								'longitude' => floatval($point->get_x()),
								'latitude' => floatval($point->get_y())
							);
							break;
						case 'commune':
							$v = '';
							$commune = $point->get_commune();
							if ($commune) $v = $commune->nom2;
							if (empty($v)) $v = '.';
							break;
						case 'departement':
							$departement = $point->get_departement();
							$v = $departement ? $departement->reference : '';
							break;
						case 'accessible_mobilite_reduite':
							$v = $s->accessible_mobilite_reduite == true;
							break;
						case 'accessible_deficient_auditif':
							$v = $s->accessible_deficient_auditif == true;
							break;
						case 'accessible_deficient_visuel':
							$v = $s->accessible_deficient_visuel == true;
							break;

						case 'date_sortie_en':
						case 'pole_n':
						case 'reseau_sortie_n':
						case 'sortie_type':
						case 'sortie_public':
						case 'sortie_cadre':
						case 'inscription_prealable':
						case 'inscription_date_limite':
						case 'inscription_participants_max':
						case 'etat':
							$v = '--skip--';
							break;

						default:
							if (preg_match('/^id_/', $c)) {
								$v = intval($s->$c);
							} else {
								$v = $s->$c;
							}
							break;
					}
					if ($v != '--skip--') {
						$sortie[$c] = $v;
					}
				}
				array_push($output_sorties, $sortie);
			}
		}
		$output['sorties'] = $output_sorties;
		$output_j = json_encode ($output);
		header ("Content-Length: ". strlen($output_j));
		echo $output_j;
		exit();
	}

	public function before_editer_suiv() {	
		$u = $this->get_user_session();
		$sortie = new clicnat_sortie($this->db, (int)$_GET['id_sortie']);
		$editable = false;
		if ($sortie->id_utilisateur_propose == $u->id_utilisateur) {
			$editable = true;
		}

		if (!$editable) {
			if ($this->is_admin($u->id_utilisateur))
				$editable = true;
		}

		$this->assign('edit', $editable);

		if ($this->is_admin($u->id_utilisateur))
			$this->assign('admin', true);
		else
			$this->assign('admin', false);

		$sortie = new clicnat_sortie($this->db, (int)$_GET['id_sortie']);
		$this->assign_by_ref('sortie', $sortie);
	}


	private function __mailing_parser($sortie, $template) {
		$html = '';
		$state = 'template';
		for ($i=0; $i<strlen($template);$i++) {
			switch ($template[$i]) {
				case '{':
					if ($state == "template") {
						$var = '';
						$state = "var";
					} else {
						throw new Exception("erreur invalide { @ car $i");
					}
					break;
				case '}':
					if ($state == "var") {
						$start = strpos($var, '>');
						if ($start > 0) {
							$var = substr($var, $start+1);
						}
						$html .= $sortie->__get($var);
						$state = 'template';
					} else {
						throw new Exception("erreur invalide } @ car $i");
					}
					break;
				default:
					if ($state == "template") {
						$html .= $template[$i];
					} else {
						$var .= $template[$i];
					}
					break;
			}
		}
		return $html;
	}

	private function __mailing_html($doc) {
		$template_head = file_get_contents('http://elliot.picardie-nature.org/~ffrenois/mailing/head.html');
		$template_body = file_get_contents('http://elliot.picardie-nature.org/~ffrenois/mailing/body.html');
		$template_foot = file_get_contents('http://elliot.picardie-nature.org/~ffrenois/mailing/foot.html');
		$html = $template_head;	
		foreach ($doc->sorties() as $sortie) {
			$html .= $this->__mailing_parser($sortie, $template_body);
		}
		$html .= $template_foot;
		return $html;
	}

	public function before_fabric() {
		if (isset($_GET['action'])) {
			switch ($_GET['action']) {
				case 'xml_incoming':
					$f = tempnam("/tmp","mailing_");
					unlink($f);
					move_uploaded_file($_FILES['xml']['tmp_name'], $f);
					$_SESSION['doc_xml'] = $f;
					$this->redirect('?t=fabric');
					break;
			}
		}
		
		if (isset($_SESSION['doc_xml'])) {
			$doc = new clicnat_doc_sorties();
			$doc->load($_SESSION['doc_xml']);
			$this->assign_by_ref('doc', $doc);
		}

	
	}

	public function before_mailing() {
		$u = $this->get_user_session();
		if (!$this->is_admin($u->id_utilisateur)) {
			throw new Exception("Vous n'êtes pas administrateur");	
		}
		
		$doc = false;

		if (isset($_SESSION['doc_xml'])) {
			$doc = new clicnat_doc_sorties();
			$doc->load($_SESSION['doc_xml']);
		}

		if (isset($_GET['action'])) {
			switch ($_GET['action']) {
				case 'xml_incoming':
					$f = tempnam("/tmp","mailing_");
					unlink($f);
					move_uploaded_file($_FILES['xml']['tmp_name'], $f);
					$_SESSION['doc_xml'] = $f;
					$this->redirect('?t=mailing');
					break;
				case 'envoi':
					require_once('Mail.php');
					require_once('Mail/mime.php');
					$destinataire = $_GET['dest'];

					$entetes['From']    = 'communication@picardie-nature.org';
					$entetes['To']      = 'communication@picardie-nature.org';
					$entetes['Subject'] = 'Picardie Nature vous livre des idées de sorties';

					$corps_html = $this->__mailing_html($doc);

					$parametres['sendmail_path'] = '/usr/lib/sendmail';

					// Creer un objet mail en utilisant la methode Mail::factory.
					$objet_mail =& Mail::factory('sendmail', $parametres);

					$params['head_charset'] = "utf-8";
					$params['text_charset'] = "utf-8";
					$params['html_charset'] = "utf-8";

					$mime = new Mail_mime($params);
					$mime->setHTMLBody($corps_html);

					$headers = $mime->headers($entetes);
					
					if ($retourne_mime_seulement)
						return htmlentities($mime->get());

					$r = $objet_mail->send($destinataire, $headers, $mime->get());
					break;
			}
		}
		if ($doc) {
			$this->assign('html', $this->__mailing_html($doc));
		}
	}

	public function before_editer_date() {
		$u = $this->get_user_session();
		$sortie = new clicnat_sortie($this->db, (int)$_GET['id_sortie']);
		$editable = false;
		if ($sortie->id_utilisateur_propose == $u->id_utilisateur) {
			$editable = true;
		}

		if (!$editable) {
			if ($this->is_admin($u->id_utilisateur))
				$editable = true;
		}

		$this->assign('edit', $editable);

		if ($this->is_admin($u->id_utilisateur))
			$this->assign('admin', true);
		else
			$this->assign('admin', false);

		if ($this->is_admin($u->id_utilisateur)) {
			if (isset($_POST['etat'])) {
				$date = $sortie->date_par_timestamp((int)$_GET['date']);
				$date->update_field('etat', (int)$_POST['etat']);
			}
		}
	
		if ($editable) {
			if (isset($_POST['inscription_date_limite'])) {
				$date = $sortie->date_par_timestamp((int)$_GET['date']);
				if (isset($_POST['inscription_date_limite'])) {
					if (!empty($_POST['inscription_date_limite'])) {
						$date->update_field('inscription_date_limite', bobs_element::date_fr2sql($_POST['inscription_date_limite']));
					} else {
						$date->update_field('inscription_date_limite', null);
					}
				}
				$date->update_field('inscription_prealable', isset($_POST['inscription_prealable'])?'true':'false');
				$date->update_field('inscription_participants_max', (int)$_POST['inscription_participants_max']);
				
				$h = (int)$_POST['date_sortie_h'];
				$m = (int)$_POST['date_sortie_m'];
				$new_date = ((int)strtotime(strftime("%Y-%m-%d", strtotime($date->date_sortie))))+3600*$h+60*$m;
				$date->update_field('date_sortie', strftime("%Y-%m-%d %H:%M:00", $new_date));
				$this->redirect("?t=editer_suiv&id_sortie={$sortie->id_sortie}");
			}
		}

		$sortie = new clicnat_sortie($this->db, (int)$_GET['id_sortie']);
		$date = $sortie->date_par_timestamp((int)$_GET['date']);
		$this->assign_by_ref('sortie', $sortie);
		$this->assign_by_ref('date', $date);

	}

	function authok() {	
		return $_SESSION[SESS]['auth_ok'] == true;
	}

	public function display() {
		global $start_time;
		$this->session();
		$noauth_templates = array ('accueil', 'export_json');
		try {
			$tpl = $this->template();
			if ( !(in_array ($tpl, $noauth_templates)) || ($_SESSION[SESS]['auth_ok'] == true) ) {
				if (!$this->authok())
					throw new ExceptionErrAuth();
				$u = $this->get_user_session();
				$this->assign_by_ref('u', $u);

				# on en a besoin dans le header
				if ($this->is_admin($u->id_utilisateur))
					$this->assign('admin', true);
				else
					$this->assign('admin', false);
			}
			setlocale(LC_ALL, LOCALE);
			$before_func = 'before_'.$this->template();

			if (method_exists($this, $before_func))
				$this->$before_func();

			if ($tpl != 'accueil') {
				$u = $this->get_user_session();
				$this->assign_by_ref('u', $u);
			}
			$this->assign_by_ref('bobs_msgs', $this->bobs_msgs);
		} catch(ExceptionErrAuth $e) {
			$tpl = 'accueil';
			$this->assign('messageinfo', 'Vous avez été déconnecté ou votre session a expiré');
		} catch(Exception $e) {
			$tpl = 'exception';
			$this->assign('ex', $e);
			try {
				$u = $this->get_user_session();
			} catch (Exception $e) { }
			$headers = "From: bobs@picardie-nature.org\r\nContent-Type: text/plain; charset=UTF-8";
			$f = basename($e->getFile()).' ligne '.$e->getLine();
			$msg = "Message : {$e->getMessage()}\nFichier : $f\n";
			$msg .= "Query String : {$_SERVER['QUERY_STRING']}\n";
			$msg .= "Origine : {$_SERVER['HTTP_REFERER']}\n";
			$msg .= "Trace :\n";
			foreach ($e->getTrace() as $ele)
			    $msg .= sprintf("\t%-40s %s%s%s()\n", basename($ele['file'])." +{$ele['line']}",  $ele['class'], $ele['type'], $ele['function']);
			mail('nicolas.damiens@picardie-nature.org', "BOBS ERREUR - {$u->nom} {$u->prenom} ({$u->id_utilisateur})", $msg, $headers);
			$this->assign('msg', htmlentities($msg, ENT_COMPAT | ENT_HTML401, 'UTF-8'));
		}
		$this->assign('tps_exec_avant_display', sprintf('%0.4f', microtime(true) - $start_time));
		parent::display($tpl.'.tpl');
	}
}

require_once(DB_INC_PHP);
get_db($db);
$s = new Sortie($db);
$s->display();
?>
