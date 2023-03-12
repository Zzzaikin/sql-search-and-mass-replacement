/**
 * Create procedure, which replace text and binary entires.
 */

DROP PROCEDURE IF EXISTS ReplaceThroughoutTheDatabase
GO

CREATE PROCEDURE RebrandThroughoutTheDatabase
    @oldValue VARCHAR(MAX),
    @newValue VARCHAR(MAX),
    @collateName VARCHAR(MAX),
    @rebrandBinaryColumns BIT
AS
    DECLARE curs CURSOR FOR
    SELECT 
        [tables].[name] AS [tableName],
        [columns].[name] AS [columnName],
        [types].[name] AS [columnType]
    FROM [sys].[columns] AS [columns]

    INNER JOIN [sys].[types] AS [types]
    ON [columns].[user_type_id] = [types].[user_type_id]

    INNER JOIN [sys].[tables] AS [tables]
    ON [columns].[object_id] = [tables].[object_id]

    WHERE 
        [types].[name] IN (
            'char',
            'varchar',
            'text',
            'nchar',
            'nvarchar',
            'ntext',
            'varbinary'
        )

    DECLARE @tableName VARCHAR(MAX);
    DECLARE @columnName VARCHAR(MAX);
    DECLARE @columnType VARCHAR(MAX);

    DECLARE @query VARCHAR(MAX);

    OPEN curs;
    FETCH NEXT FROM curs INTO @tableName, @columnName, @columnType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (@columnType = 'varbinary')
        AND @rebrandBinaryColumns = 1
        BEGIN
            SET @query = 'UPDATE [' + @tableName + '] SET [' + @columnName + '] = CONVERT(VARBINARY(MAX), REPLACE(CONVERT(VARCHAR(MAX), [' + @columnName + ']), ''' + @oldValue +  ''', ''' + @newValue + ''' COLLATE ' + @collateName + ')) WHERE [' + @columnName + '] LIKE ''%' + @oldValue + '%'' COLLATE ' + @collateName + ';';
        END

        ELSE IF @columnType NOT IN ('binary', 'varbinary')
        BEGIN
            SET @query = 'UPDATE [' + @tableName + '] SET [' + @columnName + '] = REPLACE([' + @columnName + ']' + ', ''' + @oldValue + ''', ''' + @newValue + ''' COLLATE ' + @collateName + ') WHERE [' + @columnName + '] LIKE ''%' + @oldValue + '%'' COLLATE ' + @collateName + ';';
        END
            IF @query IS NOT NULL 
                AND @query != ''
            BEGIN 
                EXECUTE(@query);
            END

        FETCH NEXT FROM curs INTO @tableName, @columnName, @columnType;
    END

    CLOSE curs;
    DEALLOCATE curs;