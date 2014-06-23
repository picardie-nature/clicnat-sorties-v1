# Synchronisation calendrier des sorties

Placer le script sur le serveur où se trouve le SPIP et l'appeler régulièrement.

# Comment ça marche

Le site fournit un tableau encodé en JSON.
Chaque clé du tableau correspond a une table :
 -  types_sortie
 -  publics_sortie
 -  poles_sortie
 -  cadres_sortie
 -  materiels_sortie
 -  reseaux_sortie
 -  sorties

```sql
create view sortie_dates_v as 
	select 
		sd.id_date_sortie AS id_date_sortie,
		sd.date_sortie AS date_sortie,
		sd.etat AS etat,
		sd.inscription_prealable AS inscription_prealable,
		sd.inscription_date_limite AS inscription_date_limite,
		sd.inscription_participants_max AS inscription_participants_max,
		s.id_sortie AS id_sortie,
		s.nom_sortie AS nom_sortie,
		s.orga_nom AS orga_nom,
		s.orga_prenom AS orga_prenom,
		s.orga_tel AS orga_tel,
		s.orga_portable AS orga_portable,
		s.orga_mail AS orga_mail,
		s.desc AS "desc",
		s.commune AS commune,
		s.departement AS departement,
		s.longitude AS longitude,
		s.latitude AS latitude,
		s.description_lieu AS description_lieu,
		s.duree_heure AS duree_heure,
		s.gestion_picnat AS gestion_picnat,
		s.accessible_mobilite_reduite AS accessible_mobilite_reduite,
		s.accessible_deficient_auditif AS accessible_deficient_auditif,
		s.accessible_deficient_visuel AS accessible_deficient_visuel,
		s.structure AS structure,
		s.pole AS pole,
		s.id_sortie_reseau AS id_sortie_reseau,
		s.id_sortie_type AS id_sortie_type,
		s.id_sortie_public AS id_sortie_public,
		s.id_sortie_cadre AS id_sortie_cadre 
	from (sortie_date sd join sorties s) 
	where (sd.id_sortie = s.id_sortie);
```
