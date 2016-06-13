drop table if exists sortie_date_document;
drop table if exists sortie_sortie_materiel;
drop table if exists sortie_date;
drop table if exists sortie;
drop table if exists sortie_type;
drop table if exists sortie_public;
drop table if exists sortie_cadre;
drop table if exists sortie_materiel;
drop table if exists sortie_document;

create table sortie_type (
	id_sortie_type serial,
	lib varchar(100),
	primary key (id_sortie_type)
);

insert into sortie_type (lib) values ('sortie nature');
insert into sortie_type (lib) values ('stage de formation');
insert into sortie_type (lib) values ('activité développement durable');
insert into sortie_type (lib) values ('exposition, stand');

create table sortie_public (
	id_sortie_public serial,
	lib varchar(255),
	primary key (id_sortie_public)
);

insert into sortie_public (lib) values ('en famille avec de jeunes enfants');
insert into sortie_public (lib) values ('peut être faite en famille');
insert into sortie_public (lib) values ('réservée aux adultes');
insert into sortie_public (lib) values ('réservée aux naturalistes débutants ou avertis');

create table sortie_cadre (
	id_sortie_cadre serial,
	lib varchar(255),
	primary key (id_sortie_cadre)
);

insert into sortie_cadre (lib) values ('Fête de la nature');
insert into sortie_cadre (lib) values ('Fréquence grenouille');
insert into sortie_cadre (lib) values ('Nuit de la Chouette');
insert into sortie_cadre (lib) values ('Nuit européenne de la Chauve-souris');
insert into sortie_cadre (lib) values (e'Semaine régionale de l\'Environnement');
insert into sortie_cadre (lib) values ('Semaine du développement durable');
insert into sortie_cadre (lib) values ('Semaine européenne de la réduction des déchets');
insert into sortie_cadre (lib) values ('Journée mondiale des zones humides');
insert into sortie_cadre (lib) values ('Autre');

create table sortie_materiel (
	id_sortie_materiel serial,
	lib varchar(100),
	primary key (id_sortie_materiel)
);

insert into sortie_materiel (lib) values ('jumelles');
insert into sortie_materiel (lib) values ('bottes obligatoires');
insert into sortie_materiel (lib) values ('bottes recommandées');
insert into sortie_materiel (lib) values ('pique-nique');

create table sortie (
	id_sortie serial,
	nom varchar(500),
	id_utilisateur_propose integer references utilisateur (id_utilisateur),
	date_proposition date,
	orga_nom varchar(100),
	orga_prenom varchar(100),
	adresse text,
	tel varchar(15),
	portable varchar(15),
	mail varchar(250),
	description varchar(1500),
	id_espace_point integer,
	description_lieu text,
	duree_heure integer,
	gestion_picnat boolean default true,
	id_sortie_type integer references sortie_type (id_sortie_type),
	id_sortie_public integer references sortie_public (id_sortie_public),
	accessible_mobilite_reduite boolean default false,
	accessible_deficient_auditif boolean default false,
	accessible_deficient_visuel boolean default false,
	id_sortie_cadre integer references sortie_cadre (id_sortie_cadre),
	partenariat varchar(200),
	date_maj timestamp,
	primary key (id_sortie)
);

create table sortie_sortie_materiel (
	id_sortie integer references sortie(id_sortie),
	id_sortie_materiel integer references sortie_materiel(id_sortie_materiel),
	primary key (id_sortie, id_sortie_materiel)
);

create table sortie_date (
	id_sortie integer references sortie(id_sortie),
	date_sortie timestamp,
	etat integer, /* 1 proposé 2 refusé 3 accepté 4 annulé */
	inscription_prealable boolean default false,
	inscription_date_limite date,
	inscription_participants_max integer,
	heure_depart_domicile time,
	heure_arrivee_rdv time,
	heure_debut_sortie time,
	heure_fin_sortie time,
	heure_retour_domicile time,
	participants_adulte integer,
	participants_enfant integer,
	participants_provenance text,
	participants_information text,
	participants_dons numeric(10,2),
	primary key (id_sortie, date_sortie)
);

drop table sortie_document;
create table sortie_document (
	id_sortie integer references sortie(id_sortie),
	doc_id varchar(13),
	primary key (id_sortie,doc_id)
);

-- a suuprimer
create table sortie_date_document (
	id_sortie integer,
	date_sortie timestamp,
	id_sortie_document integer,
	nb_diffuse integer,
	primary key (id_sortie, date_sortie, id_sortie_document),
	foreign key (id_sortie, date_sortie) references sortie_date (id_sortie, date_sortie)
);

create table sortie_pole (
	id_sortie_pole serial,
	lib varchar(100),
	primary key (id_sortie_pole)
);

insert into sortie_pole (lib) values ('Découverte et animations nature');
insert into sortie_pole (lib) values ('Observatoire faune sauvage');
insert into sortie_pole (lib) values ('Protection faune sauvage');
insert into sortie_pole (lib) values ('Protection environnement');

alter table sortie add column id_sortie_pole integer references sortie_pole (id_sortie_pole);
alter table sortie add column structure varchar(200);
alter table sortie add column validation_externe boolean not null default false;
alter table sortie add column notes_admin text;
alter table sortie add column materiel_autre text;

alter table sortie alter duree_heure type numeric (3,1);

create table sortie_reseau (
	id_sortie_reseau integer,
	lib varchar(100),
	primary key (id_sortie_reseau)
);

insert into sortie_reseau (id_sortie_reseau,lib) values (2,'Amphibien reptiles');
insert into sortie_reseau (id_sortie_reseau,lib) values (3,'Criquets sauterelles');
insert into sortie_reseau (id_sortie_reseau,lib) values (4,'Libellules');
insert into sortie_reseau (id_sortie_reseau,lib) values (5,'Chauves souris');
insert into sortie_reseau (id_sortie_reseau,lib) values (6,'Mollusques');
insert into sortie_reseau (id_sortie_reseau,lib) values (7,'Oiseaux');
insert into sortie_reseau (id_sortie_reseau,lib) values (8,'Mammifères terrestres');
insert into sortie_reseau (id_sortie_reseau,lib) values (9,'Mammifères marins');
insert into sortie_reseau (id_sortie_reseau,lib) values (11,'Phoques');
insert into sortie_reseau (id_sortie_reseau,lib) values (12,'Découverte nature');
insert into sortie_reseau (id_sortie_reseau,lib) values (13,'Busards');
insert into sortie_reseau (id_sortie_reseau,lib) values (14,'Centre de sauvegarde');
insert into sortie_reseau (id_sortie_reseau,lib) values (15,'Environnement');
insert into sortie_reseau (id_sortie_reseau,lib) values (16,'Section Oise');
insert into sortie_reseau (id_sortie_reseau,lib) values (17,'Papillons');
insert into sortie_reseau (id_sortie_reseau,lib) values (19,'Déchets');
insert into sortie_reseau (id_sortie_reseau,lib) values (20,'TMD');
insert into sortie_reseau (id_sortie_reseau,lib) values (21,'Energie');
insert into sortie_reseau (id_sortie_reseau,lib) values (22,'Eau');
insert into sortie_reseau (id_sortie_reseau,lib) values (23,'Agriculture');
insert into sortie_reseau (id_sortie_reseau,lib) values (24,'Mer et littoral');
insert into sortie_reseau (id_sortie_reseau,lib) values (25,'Trame verte et bleue');
insert into sortie_reseau (id_sortie_reseau,lib) values (26,'Coccinelles');
insert into sortie_reseau (id_sortie_reseau,lib) values (27,'Araignées');
insert into sortie_reseau (id_sortie_reseau,lib) values (28,'Agro éco');

alter table sortie add id_sortie_reseau integer references sortie_reseau (id_sortie_reseau);
alter table sortie alter id_sortie_reseau set default 12;
update sortie set id_sortie_reseau=12 where id_sortie_reseau is null;
alter table sortie alter id_sortie_reseau set not null;

insert into sortie_pole (lib) values ('observatoire décharges sauvage');
