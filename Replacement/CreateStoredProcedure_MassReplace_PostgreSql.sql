/**
 * Create procedure, which replace text and binary entires.
 */
CREATE OR REPLACE 
    PROCEDURE MassReplace(IN oldValue text, IN newValue text, IN replaceInBinaryColumns boolean = true)
LANGUAGE plpgsql
AS $$
    BEGIN    
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
                        'bytea'
                    )
                    AND information_schema.columns.table_schema = 'public'
                    AND information_schema.views.table_name IS NULL;
    
        	        tbl text;
        	        col text;
                    dtype text;
        	        query text;
        BEGIN
        	OPEN curs;
        	LOOP
                FETCH curs INTO col, tbl, dtype;
    
                IF NOT FOUND 
                    THEN EXIT; 
                END IF;
    
                IF dtype = 'bytea'
                AND replaceInBinaryColumns = true
                THEN
                    query := 'UPDATE "' || tbl || '" SET "' || col || '" = DECODE(REPLACE(ENCODE("' || col || '", ''escape''), ''' || oldValue || ''', ''' || newValue || '''),''escape'') WHERE "' || col || '" LIKE ''%' || oldValue || '%'';';
                ELSIF dtype != 'bytea'
                THEN
           	        query := 'UPDATE "' || tbl || '" SET "' || col || '" = REPLACE("' || col || '", ''' || oldValue || ''', ''' || newValue || ''') WHERE "' || col || '" LIKE ''%' || oldValue || '%'';' ;
                END IF;
    
                IF query IS NOT NULL
                    AND query != ''
                THEN
                    EXECUTE query;
                END IF;    
           	END LOOP;
           	CLOSE curs;
    END;
END $$;
