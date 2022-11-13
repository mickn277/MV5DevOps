------------------------------------------------------------------
-- Usage:
--
-- Purpose:
--  This script creates new table Geo_Countries, a new table in the database.
--  Foreign Keys on this new table Geo_Countries reference ReferencedTableName1, ReferencedTableName2 etc.
--
-- Requirements & Known Issues:
--
-- Keywords (Tech, Business, etc):
--
-- History:
--
-- Version:
-- 	$Header$
------------------------------------------------------------------

------------------------------------------------------------------
-- Recreate DROP/ADD Statements for Foreign Keys added by other scripts so they are not lost by running this script.
-- Copy results to correct sections below !
------------------------------------------------------------------
/*
WITH fks AS (
SELECT 
  LOWER(rgcl.constraint_name) REFRENCING_CONSTRAINT_NAME,
  LOWER(rgcl.table_name) REFRENCING_TABLE_NAME,
  LOWER(rgcl.column_name) REFRENCING_COLUMN_NAME,  
  LOWER(rdcn.table_name) REFRENCED_TABLE_NAME,
  LOWER(rdcl.column_name) REFERENCED_COLUMN_NAME,
DECODE(rgcn.delete_rule,'CASCADE','ON DELETE CASCADE','SET NULL','ON DELETE SET NULL',NULL,NULL,'ERROR '||rgcn.delete_rule) REFERENCE_OPTIONS
FROM all_cons_columns rgcl
  JOIN all_constraints rgcn ON rgcl.owner = rgcn.owner AND rgcl.constraint_name = rgcn.constraint_name
  JOIN all_constraints rdcn ON rgcn.r_owner = rdcn.owner AND rgcn.r_constraint_name = rdcn.constraint_name
  JOIN all_cons_columns rdcl ON rdcn.owner = rdcl.owner AND rdcn.constraint_name = rdcl.constraint_name
WHERE rdcn.owner = USER 
  AND rdcn.table_name = UPPER('Geo_Countries')
  AND rgcn.constraint_type = 'R'
)SELECT sqlstmt FROM (
SELECT 1 ORD, '-- Alter REFERENCING tables, add Foreign Key Constraints'  SQLSTMT FROM dual
UNION
SELECT 2 ORD, ' ExecSQL(''ALTER TABLE '||REFRENCING_TABLE_NAME||' DROP CONSTRAINT '||REFRENCING_CONSTRAINT_NAME||''');' SQLSTMT FROM fks
UNION 
SELECT 3 ORD, NULL  SQLSTMT FROM dual
UNION
SELECT 4 ORD, '-- Alter REFERENCING tables DROP Foreign Key Constraints'  SQLSTMT FROM dual
UNION
SELECT 5 ORD, ' ExecSQL(''ALTER TABLE '||REFRENCING_TABLE_NAME||' ADD CONSTRAINT '||REFRENCING_CONSTRAINT_NAME||' FOREIGN KEY ('||REFRENCING_COLUMN_NAME||') REFERENCES '||REFRENCED_TABLE_NAME||' ('||REFERENCED_COLUMN_NAME||') '||REFERENCE_OPTIONS||''');' SQLSTMT FROM fks
)ORDER BY ord;
*/

--BugFix: Don't scan for substitution variables like ampersand in SQLDeveloper:
SET SCAN OFF
--BugFix: Oracle 11g hangs creating a trigger:
ALTER SESSION SET PLSCOPE_SETTINGS = 'IDENTIFIERS:NONE';

SET PAGESIZE 9990
SET LINESIZE 220
COLUMN name FORMAT A30
COLUMN type FORMAT A30
COLUMN null FORMAT A30
COLUMN refrencing_constraint_name FORMAT A30
COLUMN refrencing_table_column_name FORMAT A50
COLUMN refrenced_table_column_name FORMAT A50
COLUMN reference_options FORMAT A18

--PROMPT 'Comment out QUIT; to enable this script.  Make sure script has been tested in development before using in production!'
--QUIT;

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) before rollback ===================='
------------------------------------------------------------------

-- --------------------
PROMPT 'Geo_Countries'
-- --------------------
SELECT column_name "Name",
 data_type||'('||NVL(data_precision,data_length)||DECODE(NVL(data_scale,-1),-1,'',','||data_scale)||')' "Type",
 DECODE(nullable, 'N', 'NOT NULL', ' ') "Null"
FROM user_tab_columns
WHERE table_name = UPPER('Geo_Countries')
ORDER BY table_name, column_id;

-- --------------------
PROMPT 'Constraints on Geo_Countries'
-- --------------------
SELECT 
  rgcl.constraint_name REFRENCING_CONSTRAINT_NAME,
  rgcl.table_name||'.'||rgcl.column_name REFRENCING_TABLE_COLUMN_NAME,
  rdcn.table_name||'.'||rdcl.column_name REFRENCED_TABLE_COLUMN_NAME,
DECODE(rgcn.delete_rule,'CASCADE','ON DELETE CASCADE','SET NULL','ON DELETE SET NULL',NULL,NULL,'ERROR '||rgcn.delete_rule) REFERENCE_OPTIONS
FROM all_cons_columns rgcl
  JOIN all_constraints rgcn ON rgcl.owner = rgcn.owner AND rgcl.constraint_name = rgcn.constraint_name
  JOIN all_constraints rdcn ON rgcn.r_owner = rdcn.owner AND rgcn.r_constraint_name = rdcn.constraint_name
  JOIN all_cons_columns rdcl ON rdcn.owner = rdcl.owner AND rdcn.constraint_name = rdcl.constraint_name
WHERE rdcn.owner = USER 
  AND rdcn.table_name = UPPER('Geo_Countries')
  AND rgcn.constraint_type = 'R' 
ORDER BY rgcl.table_name, rgcl.column_name;

------------------------------------------------------------------
PROMPT '==================== ROLLBACK CHANGES MADE BY THIS SCRIPT ===================='
------------------------------------------------------------------
------------------------------------------------------------------
PROMPT '-- (DROP REFERENCING FOREIGN KEY CONSTRAINTS) Drop constraints created in ALTER EXISTING REFERENCING TABLES section --'
--
-- NOTE:
--  Droping Columns is supported by Oracle8i (8.1.5) and above.
--  Don't add/remove other tables indexes, just constraints on this table
------------------------------------------------------------------
DECLARE
    PROCEDURE ExecSql(p_SQL VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE p_SQL;
    EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE IN (-942,-1418,-1917,-2275,-2289,-2443,-4043,-12003,-38307) THEN RETURN; END IF; -- Errors for object does not exist
        RAISE;
    END;
BEGIN
    ExecSql('ALTER TABLE GEO_Currencies DROP CONSTRAINT GEO_Currencies_fk1');
END;
/

------------------------------------------------------------------
PROMPT '-- (DROP OBJECTS) Drop objects created in CREATE TABLE section --'
------------------------------------------------------------------

DECLARE
  v_IsDev NUMBER(1) := 0;
  
  PROCEDURE ExecSql(p_SQL VARCHAR2) IS
  BEGIN
      EXECUTE IMMEDIATE p_SQL;
  EXCEPTION WHEN OTHERS THEN 
    IF SQLCODE IN (-942,-1418,-1917,-2275,-2289,-2443,-4043,-12003,-38307) THEN RETURN; END IF; -- Errors for object does not exist
    RAISE;
  END;
BEGIN
-- REVOKE ... Dropped when table is dropped.
-- DROP TRIGGER ... Dropped when table is dropped.
-- DROP INDEX  ... Dropped when table is dropped.
	ExecSql('DROP SEQUENCE Geo_Countries_sq');
	ExecSql('DROP TABLE Geo_Countries');
END;
/

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) after rollback ===================='
------------------------------------------------------------------
-- --------------------
PROMPT 'Geo_Countries'
-- --------------------
SELECT CASE WHEN table_name IS NULL THEN 'SUCCESS - Table dropped' ELSE 'ERROR '||LOWER(table_name)||' exists' END TABLE_DROPPED
FROM user_tables JOIN dual ON (1=1)
WHERE table_name = UPPER('Geo_Countries')
ORDER BY table_name;

-- Uncomment 'QUIT;' to just rollback changes made by this script.
-- QUIT;

------------------------------------------------------------------
PROMPT '==================== Create TABLE ===================='
------------------------------------------------------------------
------------------------------------------------------------------
PROMPT '-- (CREATE TABLE) Create the table --'
-- Column Notes:
--   NUMBER(p,s)	Precision can range from 1 to 38.	Where p is the precision and s is the scale. For example, NUMBER(3,1) is a number that has 2 digits before the decimal and 1 digit after the decimal.


-- Storage Notes:
--   Default: For OLTP situations when existing rows won't be increased much by update activity after the row is inserted.
--   PCTFREE 10 PCTUSED 40
--
--   Frequent large updates where most data is entered in the update after an insert, to prevent row chaining.
--   Reserve 30% freespace for updates, not used again until used space falls below 40%.
--   PCTFREE 30 PCTUSED 40
--
--   Inserts and Deletes only, no updates, e.g. History tables, read only tables, data load temporary tables, etc.  
--   Reserve 1% freespace for overhead, not used again until used space falls below 20% (better insert performance due to more freespace in blocks put back on the freelist).
--   PCTFREE 1 PCTUSED 20
--
--   Good for larger tables
--   COMPRESS FOR ALL OPERATIONS
------------------------------------------------------------------

CREATE TABLE Geo_Countries (
    -- Primary Key Column
    Code CHAR(3) NOT NULL,
    -- Unique Key Columns
    Country_Code_Alpha2 CHAR(2),
    Country_Code_Numeric3 CHAR(3),
     -- Generic Columns
    Country_Name VARCHAR2(75) NOT NULL,
    Country_Official_Name VARCHAR2(75),
    Country_Name_alt1 VARCHAR2(75),
    Country_Name_alt2 VARCHAR2(75),
    Country_Latitude NUMBER(12,7),
    Country_Longitude NUMBER(12,7),
    Country_TopLevel_Domain VARCHAR2(3),
    Country_Start_Dt DATE,
    Country_End_Dt DATE,
    -- Foreign Key Columns:
    Region_Code CHAR(3),
--    Currency_Code CHAR(3),
--    Previous_Currency_Code CHAR(3),
    Language_First_Code VARCHAR(6),
    Language_Second_Code VARCHAR(6),
    Language_Third_Code VARCHAR(6),
    -- Standard auditing columns:
    Created_Dt DATE DEFAULT sysdate NOT NULL,
    Changed_Dt DATE)
PCTFREE 20 PCTUSED 40
COMPRESS FOR ALL OPERATIONS
;

------------------------------------------------------------------
PROMPT '-- (COMMENT) Comment on table columns --'
-- NOTE:
--  Oracle ApEX uses column comments as the Help Text by default.
------------------------------------------------------------------
COMMENT ON TABLE Geo_Countries IS '';

-- Run this after creating the table to generate a list of table column comments:
--SELECT '-- COMMENT ON COLUMN '||LOWER(table_name)||'.'||LOWER(column_name)||' IS '''';' "STATEMENTS" FROM user_tab_columns WHERE table_name = UPPER('Geo_Countries');

COMMENT ON COLUMN Geo_Countries.Code IS 'PK';

-- COMMENT ON COLUMN Geo_Countries.ColumnNameUK1 IS '';
-- COMMENT ON COLUMN Geo_Countries.ColumnNameUK2 IS '';
COMMENT ON COLUMN Geo_Countries.Region_Code IS 'FK';
--COMMENT ON COLUMN Geo_Countries.Currency_Code IS 'FK';
--COMMENT ON COLUMN Geo_Countries.Previous_Currency_Code IS 'FK';
COMMENT ON COLUMN Geo_Countries.Language_First_Code IS 'FK';
COMMENT ON COLUMN Geo_Countries.Language_Second_Code IS 'FK';
COMMENT ON COLUMN Geo_Countries.Language_Third_Code IS 'FK';

-- COMMENT ON COLUMN Geo_Countries.Created_By IS 'Auditing column';
COMMENT ON COLUMN Geo_Countries.Created_Dt IS 'Auditing column';
-- COMMENT ON COLUMN Geo_Countries.Changed_By IS 'Auditing column';
COMMENT ON COLUMN Geo_Countries.Changed_Dt IS 'Auditing column';

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add the Column Defaults for this table --'
------------------------------------------------------------------
-- ALTER TABLE Geo_Countries  MODIFY (Code DEFAULT 0);

-- ALTER TABLE Geo_Countries  MODIFY (ColumnNameUK1 DEFAULT 0);
-- ALTER TABLE Geo_Countries  MODIFY (ColumnNameUK2 DEFAULT 0);
-- ALTER TABLE Geo_Countries  MODIFY (ColumnNameFK1 DEFAULT 0);
-- ALTER TABLE Geo_Countries  MODIFY (ColumnNameFK2 DEFAULT 0);

-- ALTER TABLE Geo_Countries  MODIFY (Created_Dt DEFAULT sysdate);

------------------------------------------------------------------
PROMPT '-- (CREATE INDEX) Create Index for this table --'
-- NOTE:
--  Creating indexes for Primary and Foreign Key Constraints before they
--   are created will prevent Oracle from using system generated indexes.
--  Foreign Key Columns should be the first column in a composite index
--   or have a seperate single column index.
--   Failing to do this causes updates to the parent tables primary key,
--   or delete of the parent record to perform a full table lock rather than a row lock
--   and can often result in blocking locks.
--   Also for Cascade Delete OR Cascade Set Null relationships each change
--   to the parent tables primary key will cause a full table scan.
--
------------------------------------------------------------------
-- Primary Key Index
CREATE UNIQUE INDEX Geo_Countries_pk ON Geo_Countries (Code);

-- Unique Key Index 1
-- CREATE UNIQUE INDEX Geo_Countries_uk1 ON Geo_Countries (ColumnNameUK1, ColumnNameUK2);

-- Foreign Key Index 1
CREATE INDEX Geo_Countries_ix1 ON Geo_Countries (Region_Code);
--CREATE INDEX Geo_Countries_ix2 ON Geo_Countries (Currency_Code);
--CREATE INDEX Geo_Countries_ix3 ON Geo_Countries (Previous_Currency_Code);
CREATE INDEX Geo_Countries_ix4 ON Geo_Countries (Language_First_Code);
CREATE INDEX Geo_Countries_ix5 ON Geo_Countries (Language_Second_Code);
CREATE INDEX Geo_Countries_ix6 ON Geo_Countries (Language_Third_Code);

-- Tuning Index 3
-- CREATE INDEX Geo_Countries_ix3 ON Geo_Countries (ColumnName, ColumnName) [TABLESPACE TablespaceName_index];

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add Constraints for this table --'
------------------------------------------------------------------
ALTER TABLE Geo_Countries ADD CONSTRAINT Geo_Countries_pk PRIMARY KEY (Code) USING INDEX;

--ALTER TABLE Geo_Countries ADD CONSTRAINT Geo_Countries_uk1 UNIQUE (ColumnNameUK1, ColumnNameUK2) USING INDEX;

ALTER TABLE Geo_Countries ADD CONSTRAINT Geo_Countries_c1 CHECK (Code = UPPER(TRIM(Code)));

-- ALTER TABLE Geo_Countries ADD CONSTRAINT Geo_Countries_c2 CHECK (ColumnName [<|>|=|!=] Value);

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add the Foreign Keys for this table --'
-- NOTE:
--  Foreign Key Constraints should be created in the referenced
--   tables section of the parent table.
--  Lookup tables shouldn't cascade delete.
--  Only set null if column allows nulls.
--  If you want any records in ReferencedTableName(n) to cascade delete records into Geo_Countries, use "ON DELETE CASCADE".
--  If you want any records in ReferencedTableName(n) to delete records without deleting records in Geo_Countries, use "ON DELETE SET NULL".
--  If you want Geo_Countries to lock ReferencedTableName(n) from deleting records, leave blank.
------------------------------------------------------------------
ALTER TABLE Geo_Countries ADD CONSTRAINT Geo_Countries_fk1 FOREIGN KEY (Region_Code) REFERENCES Geo_Regions (Code) ON DELETE SET NULL;
--ALTER TABLE Geo_Countries ADD CONSTRAINT Geo_Countries_fk2 FOREIGN KEY (Currency_Code) REFERENCES ReferencedTableName1 (ReferencedPK1) ON DELETE SET NULL;
-- ALTER TABLE Geo_Countries ADD CONSTRAINT Geo_Countries_fk3 FOREIGN KEY (Currency_Previous_Code) REFERENCES ReferencedTableName1 (ReferencedPK1) ON DELETE SET NULL;
ALTER TABLE Geo_Countries ADD CONSTRAINT Geo_Countries_fk4 FOREIGN KEY (Language_First_Code) REFERENCES Geo_Languages (Code) ON DELETE SET NULL;
ALTER TABLE Geo_Countries ADD CONSTRAINT Geo_Countries_fk5 FOREIGN KEY (Language_Second_Code) REFERENCES Geo_Languages (Code) ON DELETE SET NULL;
ALTER TABLE Geo_Countries ADD CONSTRAINT Geo_Countries_fk6 FOREIGN KEY (Language_Third_Code) REFERENCES Geo_Languages (Code) ON DELETE SET NULL;

------------------------------------------------------------------
PROMPT '-- (CREATE TRIGGER) Create Triggers for this table --'
-- NOTE:
--  If the standard auditing columns Created_Dt, Created_By, Changed_Dt, Changed_By are used in the table, uncomment the 2nd Trigger.
------------------------------------------------------------------
CREATE OR REPLACE TRIGGER Geo_Countries_tr1 BEFORE INSERT OR UPDATE ON Geo_Countries FOR EACH ROW
BEGIN
    :NEW.Code := UPPER(TRIM(:NEW.Code));
    -- Onle set Created when INSERTING
    IF INSERTING THEN
        -- Allow Created_Dt, Created_By to be set in the insert statement
        IF (:NEW.Created_Dt IS NULL) THEN
            :NEW.Created_Dt := TRUNC(sysdate);
        END IF;
    END IF;
    
    -- Only set Changed when UPDATING BugFix: Added OR because :NEW contains the old value for updates.
    IF UPDATING THEN
        -- Allow Changed_Dt, Changed_By to be set in the update statement
        IF (NOT trg_pkg.comp(:OLD.Changed_Dt, :OLD.Changed_Dt)) THEN
            :NEW.Changed_Dt := TRUNC(sysdate);
        END IF;
    END IF;
END;
/

------------------------------------------------------------------
PROMPT '-- (INSERT INTO) Insert Values into this table --'
------------------------------------------------------------------
-- INSERT INTO Geo_Countries (Code, ColumnNameUK1, ColumnNameUK2, ColumnNameFK1, ColumnNameFK2) VALUES (1, 0, '', 0, '');
-- INSERT INTO Geo_Countries (Code, ColumnNameUK1, ColumnNameUK2, ColumnNameFK1, ColumnNameFK2) VALUES (2, 0, '', 0, '');
-- INSERT INTO Geo_Countries (Code, ColumnNameUK1, ColumnNameUK2, ColumnNameFK1, ColumnNameFK2) VALUES (3, 0, '', 0, '');
-- COMMIT;

-- EXECUTE DBMS_STATS.GATHER_TABLE_STATS(ownname=>USER, tabname=>UPPER('Geo_Countries'), cascade=>TRUE, estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=>'for all columns size auto');

------------------------------------------------------------------
PROMPT '-- (GRANT privleges TO roles) --'
-- NOTE:
--  Objects must individually have privliges granted against roles for users with the
--  role to access them. This doesn't apply to the object owner, who can always access the objects.
------------------------------------------------------------------
-- GRANT SELECT ON Geo_Countries TO ReadOnlyRole;
-- GRANT SELECT, DELETE, UPDATE, INSERT ON Geo_Countries TO ReadWriteRole;
-- GRANT EXECUTE ON PackageName TO ReadWriteRole;

------------------------------------------------------------------
PROMPT '==================== Alter REFERENCING tables, Add Foreign Key Constraints ===================='
-- Alter REFERENCING tables, adding Foreign Key Columns and Indexes should be done in other table script.
--
-- NOTE:
-- Don't add/remove other tables indexes, just constraints on this table
------------------------------------------------------------------
DECLARE
  PROCEDURE ExecSql(p_SQL VARCHAR2) IS
  BEGIN
      EXECUTE IMMEDIATE p_SQL;
  EXCEPTION WHEN OTHERS THEN 
    IF SQLCODE IN (-942,-1418,-1917,-2275,-2289,-2443,-4043,-12003,-38307) THEN RETURN; END IF; -- Errors for object does not exist
    RAISE;
  END;
BEGIN
  ExecSql('ALTER TABLE GEO_Currencies ADD CONSTRAINT GEO_Currencies_fk1 FOREIGN KEY (Country_Code) REFERENCES GEO_Countries (Code) ON DELETE SET NULL');
  --ExecSql('ALTER TABLE ReferencingTableName2 ADD CONSTRAINT ReferencingTableName2_fk11 FOREIGN KEY (ReferencingColumnName2) REFERENCES Geo_Countries (Code) [ON DELETE CASCADE]');
END;
/

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) after changes ===================='
------------------------------------------------------------------
-- --------------------
PROMPT 'Geo_Countries'
-- --------------------
SELECT column_name "Name",
 data_type||'('||NVL(data_precision,data_length)||DECODE(NVL(data_scale,-1),-1,'',','||data_scale)||')' "Type",
 DECODE(nullable, 'N', 'NOT NULL', ' ') "Null"
FROM user_tab_columns
WHERE table_name = UPPER('Geo_Countries')
ORDER BY table_name, column_id;
-- --------------------
PROMPT 'Constraints on Geo_Countries'
-- --------------------
SELECT 
  rgcl.constraint_name REFRENCING_CONSTRAINT_NAME,
  rgcl.table_name||'.'||rgcl.column_name REFRENCING_TABLE_COLUMN_NAME,
  rdcn.table_name||'.'||rdcl.column_name REFRENCED_TABLE_COLUMN_NAME,
DECODE(rgcn.delete_rule,'CASCADE','ON DELETE CASCADE','SET NULL','ON DELETE SET NULL',NULL,NULL,'ERROR '||rgcn.delete_rule) REFERENCE_OPTIONS
FROM all_cons_columns rgcl
  JOIN all_constraints rgcn ON rgcl.owner = rgcn.owner AND rgcl.constraint_name = rgcn.constraint_name
  JOIN all_constraints rdcn ON rgcn.r_owner = rdcn.owner AND rgcn.r_constraint_name = rdcn.constraint_name
  JOIN all_cons_columns rdcl ON rdcn.owner = rdcl.owner AND rdcn.constraint_name = rdcl.constraint_name
WHERE rdcn.owner = USER 
  AND rdcn.table_name = UPPER('Geo_Countries')
  AND rgcn.constraint_type = 'R' 
ORDER BY rgcl.table_name, rgcl.column_name;

------------------------------------------------------------------
PROMPT '==================== END ===================='
------------------------------------------------------------------

-- Quit the SQLPlus environment.
--QUIT;