INSERT INTO
  ${dbSchema}.t_ili2db_basket
VALUES
  (-1, null, 'AV-Daten importiert per Db2Db-Step', null, '-')
ON CONFLICT DO NOTHING
;
