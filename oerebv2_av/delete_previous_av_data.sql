-- Gemeindegrenzen
DELETE FROM ${dbSchema}.dm01vch24lv95dgemeindegrenzen_gemeindegrenze;
DELETE FROM ${dbSchema}.dm01vch24lv95dgemeindegrenzen_gemeinde;
DELETE FROM ${dbSchema}.dm01vch24lv95dgemeindegrenzen_gemnachfuehrung;
-- Liegenschaften
DELETE FROM ${dbSchema}.dm01vch24lv95dliegenschaften_bergwerk;
DELETE FROM ${dbSchema}.dm01vch24lv95dliegenschaften_selbstrecht;
DELETE FROM ${dbSchema}.dm01vch24lv95dliegenschaften_liegenschaft;
DELETE FROM ${dbSchema}.dm01vch24lv95dliegenschaften_grundstueck;
DELETE FROM ${dbSchema}.dm01vch24lv95dliegenschaften_lsnachfuehrung;
-- Gebäudeadressen
DELETE FROM ${dbSchema}.dm01vch24lv95dgebaeudeadressen_gebaeudeeingang;
DELETE FROM ${dbSchema}.dm01vch24lv95dgebaeudeadressen_lokalisationsname;
DELETE FROM ${dbSchema}.dm01vch24lv95dgebaeudeadressen_lokalisation;
DELETE FROM ${dbSchema}.dm01vch24lv95dgebaeudeadressen_gebnachfuehrung;
-- Bodenbedeckung
DELETE FROM ${dbSchema}.dm01vch24lv95dbodenbedeckung_boflaeche;
DELETE FROM ${dbSchema}.dm01vch24lv95dbodenbedeckung_projboflaeche;
DELETE FROM ${dbSchema}.dm01vch24lv95dbodenbedeckung_gebaeudenummer;
DELETE FROM ${dbSchema}.dm01vch24lv95dbodenbedeckung_projgebaeudenummer;
DELETE FROM ${dbSchema}.dm01vch24lv95dbodenbedeckung_bbnachfuehrung;
-- Einzelobjekte
DELETE FROM ${dbSchema}.dm01vch24lv95deinzelobjekte_objektnummer;
DELETE FROM ${dbSchema}.dm01vch24lv95deinzelobjekte_flaechenelement;
DELETE FROM ${dbSchema}.dm01vch24lv95deinzelobjekte_einzelobjekt;
DELETE FROM ${dbSchema}.dm01vch24lv95deinzelobjekte_eonachfuehrung;
-- Nomenklatur
DELETE FROM ${dbSchema}.dm01vch24lv95dnomenklatur_flurname;
DELETE FROM ${dbSchema}.dm01vch24lv95dnomenklatur_nknachfuehrung;
