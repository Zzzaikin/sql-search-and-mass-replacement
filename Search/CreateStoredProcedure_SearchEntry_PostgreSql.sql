/**
 * Create procedure, which search text, binary and ID entries.
 */
CREATE OR REPLACE
    PROCEDURE SearchEntry(IN entr text, IN searchInBinaryColumns boolean = true)
LANGUAGE plpgsql
AS $$
    DECLARE
    	curs CURSOR FOR 
            SELECT 
                information_schema.columns.column_name,
                information_schema.columns.table_name,
                information_schema.columns.data_type 
            FROM information_schema.columns      
            LEFT JOIN information_schema.views
                ON information_schema.columns.table_name = information_schema.views.table_name
            WHERE
                information_schema.columns.data_type IN (
                    'character varying', 
                    'text',
                    'varchar', 
                    'character',
                    'char',
                    'bytea',
                    'uuid'
                )

                AND information_schema.columns.table_schema = 'public';

    	        tbl text;
    	        col text;
                dtype text;
    	        qry text := 'DO $SearchEntry$ BEGIN ';
    BEGIN
    	OPEN curs;
    	LOOP
            FETCH curs INTO col, tbl, dtype;

            IF NOT FOUND 
                THEN EXIT; 
            END IF;
            
            IF dtype = 'bytea'
            THEN
                qry := CONCAT(qry, 'IF EXISTS(SELECT encode("' || col || '", ''escape'') FROM "' || tbl || '" WHERE encode("' || col || '", ''escape'') LIKE ''%' || entr || '%'') THEN RAISE NOTICE ''Entry exists. Table - ' || tbl || ', column - ' || col || '''; END IF;');
            ELSE
                qry := CONCAT(qry, 'IF EXISTS(SELECT "' || col || '" FROM "' || tbl || '" WHERE "' || col || '" LIKE ''%' || entr || '%'') THEN RAISE NOTICE ''Entry exists. Table - ' || tbl || ', column - ' || col || '''; END IF;');
            END IF;
       	END LOOP;
       	CLOSE curs;

        qry := CONCAT(qry, ' END $SearchEntry$');
        EXECUTE qry;
END $$;