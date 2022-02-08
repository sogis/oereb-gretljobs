INSERT INTO
    ${dbSchema}.t_ili2db_basket 
    (
        t_id, 
        dataset, 
        topic, 
        t_ili_tid, 
        attachmentkey, 
        domains
    )
VALUES
    (
        -1, 
        NULL, 
        'AV-Daten importiert per Db2Db-Step', 
        NULL, 
        '-', 
        NULL
    )
ON CONFLICT DO NOTHING
;
