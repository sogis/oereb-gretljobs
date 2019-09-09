-- Gemeindegrenzen
DELETE FROM ${dbSchema}.dm01vch24lv95dgemeindegrenzen_gemeindegrenze;
DELETE FROM ${dbSchema}.dm01vch24lv95dgemeindegrenzen_gemeinde;
DELETE FROM ${dbSchema}.dm01vch24lv95dgemeindegrenzen_gemnachfuehrung;
-- Liegenschaften
DELETE FROM ${dbSchema}.dm01vch24lv95dliegenschaften_liegenschaft;
DELETE FROM ${dbSchema}.dm01vch24lv95dliegenschaften_grundstueck;
DELETE FROM ${dbSchema}.dm01vch24lv95dliegenschaften_lsnachfuehrung;
-- Gebäudeadressen
DELETE FROM ${dbSchema}.dm01vch24lv95dgebaeudeadressen_gebaeudeeingang;
DELETE FROM ${dbSchema}.dm01vch24lv95dgebaeudeadressen_lokalisationsname;
DELETE FROM ${dbSchema}.dm01vch24lv95dgebaeudeadressen_lokalisation;
DELETE FROM ${dbSchema}.dm01vch24lv95dgebaeudeadressen_gebnachfuehrung;
