# sql-search-and-mass-replacement
Repo with scripts for search and mass replacement entries in database. Supports sql-server and PostgreSQL.

# Using
Execute scripts, which contains in repository directories, for DBMS that you need. These scripts will create stored procedures for search and replacement.

## sql-server

Search entries:
```sql
EXECUTE SearchEntry @entry = 'Example entry', @collateName = 'Cyrillic_General_CS_AS', @searchInBinaryColumns = 1
```
Replacement entries:
```sql
EXECUTE MassReplace @oldValue = 'Example entry', @newValue = 'New example entry', @collateName = 'Cyrillic_General_CS_AS', @replaceInBinaryColumns = 1
```
Also you can choose another collate. Check collates in you server with:
```sql
SELECT name, description
FROM fn_helpcollations();
```
Suffix "CS" in collateName indicates that search/replacement will case sensitive. "CI" indicate reverse - case insensitive.


## PostgreSQL

Search entries:
```sql
CALL SearchEntry('Example entry', true)
```

Replacement entries:
```sql
CALL MassReplace('Example entry', 'New example entry', true);
```
PostgreSQL stored procedures works only with case sensitive.

# Additional
Also you can search uuids in PostgreSQL and uniqueidentifiers in sql-server like that:

sql-server:
```sql
EXECUTE SearchEntry @entry = 'c53s032b-d6c8-40d1-bg3d-01d34984b57c', @collateName = 'Cyrillic_General_CI_AS', @searchInBinaryColumns = 1
```

PostgreSQL:
```sql
CALL SearchEntry('c53s032b-d6c8-40d1-bg3d-01d34984b57c', true)
```
But that's not supported in replacement. Just because it will call primary and foreign key constraint errors.

You can use searchInBinaryColumns\replaceInBinaryColumns parameter for search and replacement in binary columns additionaly.
