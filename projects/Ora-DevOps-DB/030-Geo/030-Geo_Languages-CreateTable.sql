------------------------------------------------------------------
-- Usage:
--
-- Purpose:
--  This script creates new table geo_languages, a new table in the database.
--  Foreign Keys on this new table geo_languages reference ReferencedTableName1, ReferencedTableName2 etc.
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
  AND rdcn.table_name = UPPER('geo_languages')
  AND rgcn.constraint_type = 'R'
)SELECT sqlstmt FROM (
SELECT 1 ORD, '-- Alter REFERENCING tables, add Foreign Key Constraints'  SQLSTMT FROM dual
UNION
SELECT 2 ORD, '     ExecSQL(''ALTER TABLE '||REFRENCING_TABLE_NAME||' DROP CONSTRAINT '||REFRENCING_CONSTRAINT_NAME||''');' SQLSTMT FROM fks
UNION 
SELECT 3 ORD, NULL  SQLSTMT FROM dual
UNION
SELECT 4 ORD, '-- Alter REFERENCING tables DROP Foreign Key Constraints'  SQLSTMT FROM dual
UNION
SELECT 5 ORD, '     ExecSQL(''ALTER TABLE '||REFRENCING_TABLE_NAME||' ADD CONSTRAINT '||REFRENCING_CONSTRAINT_NAME||' FOREIGN KEY ('||REFRENCING_COLUMN_NAME||') REFERENCES '||REFRENCED_TABLE_NAME||' ('||REFERENCED_COLUMN_NAME||') '||REFERENCE_OPTIONS||''');' SQLSTMT FROM fks
)ORDER BY ord;


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
PROMPT 'geo_languages'
-- --------------------
SELECT column_name "Name",
 data_type||'('||NVL(data_precision,data_length)||DECODE(NVL(data_scale,-1),-1,'',','||data_scale)||')' "Type",
 DECODE(nullable, 'N', 'NOT NULL', ' ') "Null"
FROM user_tab_columns
WHERE table_name = UPPER('geo_languages')
ORDER BY table_name, column_id;

-- --------------------
PROMPT 'Constraints on geo_languages'
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
  AND rdcn.table_name = UPPER('geo_languages')
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
     ExecSQL('ALTER TABLE geo_places DROP CONSTRAINT geo_places_fk4');
     ExecSQL('ALTER TABLE geo_places DROP CONSTRAINT geo_places_fk5');
     ExecSQL('ALTER TABLE geo_places DROP CONSTRAINT geo_places_fk6');
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
	ExecSql('DROP TABLE geo_languages');
END;
/

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) after rollback ===================='
------------------------------------------------------------------
-- --------------------
PROMPT 'geo_languages'
-- --------------------
SELECT CASE WHEN table_name IS NULL THEN 'SUCCESS - Table dropped' ELSE 'ERROR '||LOWER(table_name)||' exists' END TABLE_DROPPED
FROM user_tables JOIN dual ON (1=1)
WHERE table_name = UPPER('geo_languages')
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

CREATE TABLE geo_languages (
    -- Primary Key Column
    code VARCHAR2(6) NOT NULL,
    parent_language_code VARCHAR2(3),
    -- Data Columns
    language_name_en VARCHAR2(100) NOT NULL,
    language_usage_millions NUMBER(6,2)
)
PCTFREE 5 PCTUSED 20
COMPRESS FOR ALL OPERATIONS
;

------------------------------------------------------------------
PROMPT '-- (COMMENT) Comment on table columns --'
-- NOTE:
--  Oracle ApEX uses column comments as the Help Text by default.
------------------------------------------------------------------
COMMENT ON TABLE geo_languages IS '';

-- Run this after creating the table to generate a list of table column comments:
--SELECT '-- COMMENT ON COLUMN '||LOWER(table_name)||'.'||LOWER(column_name)||' IS '''';' "STATEMENTS" FROM user_tab_columns WHERE table_name = UPPER('geo_languages');

COMMENT ON COLUMN geo_languages.code IS 'PK 1of1';

-- COMMENT ON COLUMN geo_languages.ColumnNameUK1 IS 'UK 1 of 2';
-- COMMENT ON COLUMN geo_languages.ColumnNameUK2 IS 'UK 2 of 2';
COMMENT ON COLUMN geo_languages.parent_language_code IS 'FK';
-- COMMENT ON COLUMN geo_languages.ColumnNameFK2 IS 'FK';

-- COMMENT ON COLUMN geo_languages.Created_By IS 'Auditing column';
-- COMMENT ON COLUMN geo_languages.Created_Dt IS 'Auditing column';
-- COMMENT ON COLUMN geo_languages.Changed_By IS 'Auditing column';
-- COMMENT ON COLUMN geo_languages.Changed_Dt IS 'Auditing column';
-- COMMENT ON COLUMN geo_languages.Archive IS '-1=True, 0=False. Archive records are kept for historical purposes and should be excluded from create record lists, etc.';
-- COMMENT ON COLUMN geo_languages.Archive_Dt IS 'Date record was archived. Archive records are kept for historical purposes and should be excluded from create record lists, etc.';

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add the Column Defaults for this table --'
------------------------------------------------------------------
-- ALTER TABLE geo_languages  MODIFY (code DEFAULT 0);

-- ALTER TABLE geo_languages  MODIFY (ColumnNameUK1 DEFAULT 0);
-- ALTER TABLE geo_languages  MODIFY (ColumnNameUK2 DEFAULT 0);
-- ALTER TABLE geo_languages  MODIFY (ColumnNameFK1 DEFAULT 0);
-- ALTER TABLE geo_languages  MODIFY (ColumnNameFK2 DEFAULT 0);

-- ALTER TABLE geo_languages  MODIFY (Created_Dt DEFAULT sysdate);

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
CREATE UNIQUE INDEX geo_languages_pk ON geo_languages (code);

-- Foreign Key Index 1
CREATE INDEX geo_languages_ix1 ON geo_languages (parent_language_code);

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add Constraints for this table --'
------------------------------------------------------------------
ALTER TABLE geo_languages ADD CONSTRAINT geo_languages_pk PRIMARY KEY (code) USING INDEX;

ALTER TABLE geo_languages ADD CONSTRAINT geo_languages_c1 CHECK (code = UPPER(TRIM(code)));
ALTER TABLE geo_languages ADD CONSTRAINT geo_languages_c2 CHECK (parent_language_code = UPPER(TRIM(parent_language_code)));
ALTER TABLE geo_languages ADD CONSTRAINT geo_languages_c3 CHECK (INSTR(parent_language_code, '-') <= 0);

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add the Foreign Keys for this table --'
-- NOTE:
--  Foreign Key Constraints should be created in the referenced
--   tables section of the parent table.
--  Lookup tables shouldn't cascade delete.
--  Only set null if column allows nulls.
--  If you want any records in ReferencedTableName(n) to cascade delete records into geo_languages, use "ON DELETE CASCADE".
--  If you want any records in ReferencedTableName(n) to delete records without deleting records in geo_languages, use "ON DELETE SET NULL".
--  If you want geo_languages to lock ReferencedTableName(n) from deleting records, leave blank.
------------------------------------------------------------------
ALTER TABLE geo_languages ADD CONSTRAINT geo_languages_fk1 FOREIGN KEY (parent_language_code) REFERENCES geo_languages (code) ON DELETE SET NULL;

------------------------------------------------------------------
PROMPT '-- (CREATE TRIGGER) Create Triggers for this table --'
-- NOTE:
--  If the standard auditing columns Created_Dt, Created_By, Changed_Dt, Changed_By are used in the table, uncomment the 2nd Trigger.
------------------------------------------------------------------
CREATE OR REPLACE TRIGGER geo_languages_tr1 BEFORE INSERT OR UPDATE ON geo_languages FOR EACH ROW
DECLARE
    v_Pos NUMBER(1) := -1;
BEGIN
    :NEW.code := UPPER(TRIM(:NEW.code));
    :NEW.parent_language_code := UPPER(TRIM(:NEW.parent_language_code));
    
    IF (:NEW.parent_language_code IS NULL AND INSTR(:NEW.code, '-') >= 2) THEN
        v_Pos := instr(:NEW.code, '-') - 1;
        IF v_Pos NOT IN (2,3,4) THEN v_Pos := 2; END IF;
        :NEW.parent_language_code := SUBSTR(:NEW.code, 1, v_Pos);
    END IF;
END;
/

------------------------------------------------------------------
PROMPT '-- (INSERT INTO) Insert Values into this table --'
------------------------------------------------------------------
--INSERT INTO geo_languages (code, language_name_en, language_usage_millions) VALUES ('EN', 'English', 450);
--INSERT INTO geo_languages (code, language_name_en, language_usage_millions) VALUES ('CN', 'English', 450);
--INSERT INTO geo_languages (code, language_name_en, language_usage_millions) VALUES ('EN', 'English', 450);
--INSERT INTO geo_languages (code, language_name_en, language_usage_millions) VALUES ('EN', 'English', 450);
--INSERT INTO geo_languages (code, language_name_en, language_usage_millions) VALUES ('EN', 'English', 450);
--COMMIT;
--
--EXECUTE DBMS_STATS.GATHER_TABLE_STATS(ownname=>USER, tabname=>UPPER('geo_languages'), cascade=>TRUE, estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=>'for all columns size auto');

------------------------------------------------------------------
PROMPT '-- (GRANT privleges TO roles) --'
-- NOTE:
--  Objects must individually have privliges granted against roles for users with the
--  role to access them. This doesn't apply to the object owner, who can always access the objects.
------------------------------------------------------------------
-- GRANT SELECT ON geo_languages TO ReadOnlyRole;
-- GRANT SELECT, DELETE, UPDATE, INSERT ON geo_languages TO ReadWriteRole;
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
     ExecSQL('ALTER TABLE geo_places ADD CONSTRAINT geo_places_fk4 FOREIGN KEY (language_first_code) REFERENCES geo_languages (code) ON DELETE SET NULL');
     ExecSQL('ALTER TABLE geo_places ADD CONSTRAINT geo_places_fk5 FOREIGN KEY (language_second_code) REFERENCES geo_languages (code) ON DELETE SET NULL');
     ExecSQL('ALTER TABLE geo_places ADD CONSTRAINT geo_places_fk6 FOREIGN KEY (language_third_code) REFERENCES geo_languages (code) ON DELETE SET NULL');
END;
/

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) after changes ===================='
------------------------------------------------------------------
-- --------------------
PROMPT 'geo_languages'
-- --------------------
SELECT column_name "Name",
 data_type||'('||NVL(data_precision,data_length)||DECODE(NVL(data_scale,-1),-1,'',','||data_scale)||')' "Type",
 DECODE(nullable, 'N', 'NOT NULL', ' ') "Null"
FROM user_tab_columns
WHERE table_name = UPPER('geo_languages')
ORDER BY table_name, column_id;
-- --------------------
PROMPT 'Constraints on geo_languages'
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
  AND rdcn.table_name = UPPER('geo_languages')
  AND rgcn.constraint_type = 'R' 
ORDER BY rgcl.table_name, rgcl.column_name;

------------------------------------------------------------------
PROMPT '==================== END ===================='
------------------------------------------------------------------

-- Quit the SQLPlus environment.
--QUIT;