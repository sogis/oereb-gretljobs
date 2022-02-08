-- Gemeindegrenzen
INSERT INTO live.dm01vch24lv95dgemeindegrenzen_gemnachfuehrung SELECT * FROM stage.dm01vch24lv95dgemeindegrenzen_gemnachfuehrung;
INSERT INTO live.dm01vch24lv95dgemeindegrenzen_gemeinde SELECT * FROM stage.dm01vch24lv95dgemeindegrenzen_gemeinde;
INSERT INTO live.dm01vch24lv95dgemeindegrenzen_gemeindegrenze SELECT * FROM stage.dm01vch24lv95dgemeindegrenzen_gemeindegrenze;
-- Liegenschaften
INSERT INTO live.dm01vch24lv95dliegenschaften_lsnachfuehrung SELECT * FROM stage.dm01vch24lv95dliegenschaften_lsnachfuehrung;
INSERT INTO live.dm01vch24lv95dliegenschaften_grundstueck SELECT * FROM stage.dm01vch24lv95dliegenschaften_grundstueck;
INSERT INTO live.dm01vch24lv95dliegenschaften_liegenschaft SELECT * FROM stage.dm01vch24lv95dliegenschaften_liegenschaft;
INSERT INTO live.dm01vch24lv95dliegenschaften_selbstrecht SELECT * FROM stage.dm01vch24lv95dliegenschaften_selbstrecht;
INSERT INTO live.dm01vch24lv95dliegenschaften_bergwerk SELECT * FROM stage.dm01vch24lv95dliegenschaften_bergwerk;
-- Gebäudeadressen
INSERT INTO live.dm01vch24lv95dgebaeudeadressen_gebnachfuehrung SELECT * FROM stage.dm01vch24lv95dgebaeudeadressen_gebnachfuehrung;
INSERT INTO live.dm01vch24lv95dgebaeudeadressen_lokalisation SELECT * FROM stage.dm01vch24lv95dgebaeudeadressen_lokalisation;
INSERT INTO live.dm01vch24lv95dgebaeudeadressen_lokalisationsname SELECT * FROM stage.dm01vch24lv95dgebaeudeadressen_lokalisationsname;
INSERT INTO live.dm01vch24lv95dgebaeudeadressen_gebaeudeeingang SELECT * FROM stage.dm01vch24lv95dgebaeudeadressen_gebaeudeeingang;
-- Bodenbedeckung
--INSERT INTO live.dm01vch24lv95dbodenbedeckung_bbnachfuehrung SELECT * FROM stage.dm01vch24lv95dbodenbedeckung_bbnachfuehrung;
--INSERT INTO live.dm01vch24lv95dbodenbedeckung_gebaeudenummer SELECT * FROM stage.dm01vch24lv95dbodenbedeckung_gebaeudenummer;
--INSERT INTO live.dm01vch24lv95dbodenbedeckung_projgebaeudenummer SELECT * FROM stage.dm01vch24lv95dbodenbedeckung_projgebaeudenummer;
--INSERT INTO live.dm01vch24lv95dbodenbedeckung_boflaeche SELECT * FROM stage.dm01vch24lv95dbodenbedeckung_boflaeche;
--INSERT INTO live.dm01vch24lv95dbodenbedeckung_projboflaeche SELECT * FROM stage.dm01vch24lv95dbodenbedeckung_projboflaeche;
-- Einzelobjekte
--INSERT INTO live.dm01vch24lv95deinzelobjekte_eonachfuehrung SELECT * FROM stage.dm01vch24lv95deinzelobjekte_eonachfuehrung;
--INSERT INTO live.dm01vch24lv95deinzelobjekte_einzelobjekt SELECT * FROM stage.dm01vch24lv95deinzelobjekte_einzelobjekt;
--INSERT INTO live.dm01vch24lv95deinzelobjekte_flaechenelement SELECT * FROM stage.dm01vch24lv95deinzelobjekte_flaechenelement;
--INSERT INTO live.dm01vch24lv95deinzelobjekte_objektnummer SELECT * FROM stage.dm01vch24lv95deinzelobjekte_objektnummer;
-- Nomenklatur
--INSERT INTO live.dm01vch24lv95dnomenklatur_nknachfuehrung SELECT * FROM stage.dm01vch24lv95dnomenklatur_nknachfuehrung;
--INSERT INTO live.dm01vch24lv95dnomenklatur_flurname SELECT * FROM stage.dm01vch24lv95dnomenklatur_flurname;
