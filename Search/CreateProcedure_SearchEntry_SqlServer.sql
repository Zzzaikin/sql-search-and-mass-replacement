/**
 * Create procedure, which search text, binary and ID entries.
 */
DROP PROCEDURE IF EXISTS SearchEntry
GO

CREATE PROCEDURE SearchEntry
    @entry VARCHAR(MAX),
    @collateName VARCHAR(MAX),
    @searchInBinaryColumns BIT
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
            'binary',
            'varbinary',
            'uniqueidentifier'
        )

    DECLARE @tableName NVARCHAR(MAX)
    DECLARE @columnName NVARCHAR(MAX)
    DECLARE @columnType NVARCHAR(MAX)

    DECLARE @query NVARCHAR(MAX)

    OPEN curs
    FETCH NEXT FROM curs INTO @tableName, @columnName, @columnType

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (@columnType = 'binary'
            OR @columnType = 'varbinary')
        BEGIN
            SET @query = 'IF EXISTS (SELECT [' + @columnName +'] FROM [' + @tableName + '] WHERE CONVERT(VARCHAR(MAX), [' + @columnName + ']) LIKE ''' + '%' + @entry + '%' + ''' COLLATE ' + @collateName + ') PRINT(''Entry exists. Table - ' + @tableName + ', column - ' + @columnName + ''');';
        END

        ELSE
        BEGIN
            SET @query = 'IF EXISTS (SELECT [' + @columnName +'] FROM [' + @tableName + '] WHERE [' + @columnName + '] LIKE ''' + '%' + @entry + '%' + ''' COLLATE ' + @collateName + ') PRINT(''Entry exists. Table - ' + @tableName + ', column - ' + @columnName + ''');';
        END

        EXECUTE(@query);
        FETCH NEXT FROM curs INTO @tableName, @columnName, @columnType
    END

    CLOSE curs
    DEALLOCATE curs