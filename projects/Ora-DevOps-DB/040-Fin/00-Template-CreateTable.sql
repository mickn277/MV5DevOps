------------------------------------------------------------------
-- Template Usage:
--  Do a find and replace on these names using Case Sensitive and DO NOT Match Whole Words.
--   
--  Change the default names for this table being created.
-- 
--   PrimaryTableName             # This is the name of the main table that we are creating.
--   ColumnNamePK                 # This is the primary key column in PrimaryTableName.
--   ColumnNameUK1, ColumnNameUK2 # These are two Unique Key columns in PrimaryTableName.
--   ColumnNameFK1, ColumnNameFK2 # These are two Foreign Key columns in PrimaryTableName.
--
--   ReferencingTableName1        # This is used to drop and recreate foreign key constraints on another table that references this PrimaryTableName table.
--   ReferencingColumnName1       # This is the Foreign Key column in ReferencingTableName1 that references PrimaryTableName.
--   ReferencingTableName2        # This is used to drop and recreate foreign key constraints on another table that references this PrimaryTableName table.
--   ReferencingColumnName2       # This is the Foreign Key column in ReferencingTableName2 that references PrimaryTableName.
--
--   ReferencedTableName1         # This is the first table referenced by Foreign Key ColumnNameFK1 in PrimaryTableName.
--   ReferencedPK1                # This is the Primary Key of table ReferencedTableName1 referenced by Foreign Key ColumnNameFK1 in PrimaryTableName.
--   ReferencedTableName2         # This is the second table referenced by Foreign Key ColumnNameFK2 in PrimaryTableName.
--   ReferencedPK2                # This is the Primary Key of table ReferencedTableName2 referenced by Foreign Key ColumnNameFK2 in PrimaryTableName.  
--
-- 	Uncomment Quit at the end if running in Oracle SQLPlus.
-- 	Perform Find and Replace using Case Sensitive, and Match Whole Words for best results.
--  Run on a development databaseseveral times, to check that the script correctly drops, then recreates all objects without errors.
--
--  This script modifies referencing table ReferencingTableName1, an existing table that references
--  this new table PrimaryTableName.
--
-- Template History:
-- 	12/04/2005 Mick Wells, Template created.
-- 	24/08/2014 Mick Wells, Lots of changes and improvemetns, should now be able to speed up script creation by performing a find and replace on object names.
--  29/08/2014 Mick Wells, Updated to calculate statistics on tables and indexes after they have been loaded, Reformatted to hopefully make it a little easier to understand.
--  05/08/2016 Mick Wells, Removed redundant code, and a few other changes.
--  07/07/2017 Mick Wells, Removed need for Two CreateTable templates, this one now only drops/adds Foreign Key constraints on other tables so it doesn't fail when other tables reference this one.
--  27/10/2017 Mick Wells, Fix up Referencing Table stuff, removed schema so script is not schema specific.
--  24/09/2019 Mick Wells, Added DROP/ADD foreign keys statement, BugFix: Purge was throwing errors.
--  11/05/2020 Mick Wells, BugFix: Foreign Keys weren't showing up, fixed where clause.
--  29/05/2020 Mick Wells, Removed DEV purge, always have recycle bin for recovery. Manually purge if needed or let Oracle manage it.
--  04/05/2021 Mick Wells, Added option Changed_By_fn to trigger, Added sequence dynamic generation, fixed table exists test near start.
--  30/11/2022 Mick Wells, Recreate Foreign Keys - BugFix: Don't regenerate FKs in this script. 
------------------------------------------------------------------

------------------------------------------------------------------
-- Usage:
--
-- Purpose:
--  This script creates table PrimaryTableName, a new table in the database.
--  Foreign Keys on this table PrimaryTableName reference ReferencedTableName1, ReferencedTableName2 etc.
--  Foreign Keys on ReferencingTableName1, ReferencingTableName2 reference this table PrimaryTableName.
--  
-- Requirements & Known Issues:
--
-- Keywords (Tech, Business, etc):
--
-- History:
--
-- Version:
-- 	$Header: http://ironbender.in.telstra.com.au/svn/tcppo/all/comstore/trunk/00-PROPHET-Templates/Oracle-TableTemplate-CreateTable.sql 4446 2017-07-27 08:33:50Z c883802 $
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
    AND rdcn.table_name = UPPER('PrimaryTableName')
    AND rgcl.table_name != rdcn.table_name
    AND rgcn.constraint_type = 'R'
)SELECT sqlstmt FROM (
SELECT 1 ORD, '-- Alter REFERENCING tables, add Foreign Key Constraints'  SQLSTMT FROM dual
UNION
SELECT 2 ORD, '    ExecSQL(''ALTER TABLE '||REFRENCING_TABLE_NAME||' DROP CONSTRAINT '||REFRENCING_CONSTRAINT_NAME||''');' SQLSTMT FROM fks
UNION 
SELECT 3 ORD, NULL  SQLSTMT FROM dual
UNION
SELECT 4 ORD, '-- Alter REFERENCING tables DROP Foreign Key Constraints'  SQLSTMT FROM dual
UNION
SELECT 5 ORD, '    ExecSQL(''ALTER TABLE '||REFRENCING_TABLE_NAME||' ADD CONSTRAINT '||REFRENCING_CONSTRAINT_NAME||' FOREIGN KEY ('||REFRENCING_COLUMN_NAME||') REFERENCES '||REFRENCED_TABLE_NAME||' ('||REFERENCED_COLUMN_NAME||') '||REFERENCE_OPTIONS||''');' SQLSTMT FROM fks
) ORDER BY ord, sqlstmt;
*/

-- Enable output from DBMS_OUTPUT
SET SERVEROUTPUT ON
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

DECLARE
    v_Exists NUMBER(1) := 0;
BEGIN 
    SELECT DECODE(table_name, null, 0, -1) TABLE_EXISTS INTO V_Exists FROM dual LEFT JOIN user_tables ON (table_name=UPPER('PrimaryTableName'));
    IF (v_Exists=-1) THEN
        DBMS_OUTPUT.PUT_LINE('Uncomment "QUIT;" to disable script after creating table in PROD to prevent script from dropping tables in PROD!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Always test in DEV before using in PROD, comment out "QUIT;" here to enable script to run in DEV and PROD!');
    END IF;
END;
/

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) before rollback ===================='
------------------------------------------------------------------

-- --------------------
PROMPT 'PrimaryTableName'
-- --------------------
SELECT column_name "Name",
    data_type||'('||NVL(data_precision,data_length)||DECODE(NVL(data_scale,-1),-1,'',','||data_scale)||')' "Type",
    DECODE(nullable, 'N', 'NOT NULL', ' ') "Null"
FROM user_tab_columns
WHERE table_name = UPPER('PrimaryTableName')
ORDER BY table_name, column_id;

-- --------------------
PROMPT 'Constraints on PrimaryTableName'
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
    AND rdcn.table_name = UPPER('PrimaryTableName')
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
        DBMS_OUTPUT.PUT_LINE('Executed: '||p_SQL);
    EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE IN (-942,-1418,-1917,-2275,-2289,-2443,-4043,-12003,-38307) THEN RETURN; END IF; -- Errors for object does not exist
        RAISE;
    END;
BEGIN
--ExecSql('ALTER TABLE ReferencingTableName1 DROP CONSTRAINT ReferencingTableName1_fk10');
--ExecSql('ALTER TABLE ReferencingTableName2 DROP CONSTRAINT ReferencingTableName2_fk11');
	NULL;
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
        DBMS_OUTPUT.PUT_LINE('Executed: '||p_SQL);
    EXCEPTION WHEN OTHERS THEN 
        IF SQLCODE IN (-942,-1418,-1917,-2275,-2289,-2443,-4043,-12003,-38307) THEN RETURN; END IF; -- Errors for object does not exist
        RAISE;
    END;
BEGIN
--REVOKE ... Dropped when table is dropped.
--DROP TRIGGER ... Dropped when table is dropped.
--DROP INDEX  ... Dropped when table is dropped.
	ExecSql('DROP SEQUENCE PrimaryTableName_sq');
	ExecSql('DROP TABLE PrimaryTableName');
END;
/

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) after rollback ===================='
------------------------------------------------------------------
-- --------------------
PROMPT 'PrimaryTableName'
-- --------------------
DECLARE
    v_Exists NUMBER(1) := 0;
BEGIN
    SELECT DECODE(table_name, null, 0, -1) TABLE_EXISTS INTO V_Exists FROM dual LEFT JOIN user_tables ON (table_name=UPPER('PrimaryTableName'));
    IF (v_Exists=-1) THEN
        DBMS_OUTPUT.PUT_LINE('Uncomment "QUIT;" to disable script after creating table in PROD to prevent script from dropping tables in PROD!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Always test in DEV before using in PROD, comment out "QUIT;" here to enable script to run in DEV and PROD!');
    END IF;
END;
/

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

CREATE TABLE PrimaryTableName (
    -- Primary Key Column
    ColumnNamePK NUMBER (11,0) NOT NULL,
    -- Unique Key Columns
    ColumnNameUK1 NUMBER (11,0) NOT NULL,
    ColumnNameUK2 VARCHAR2 (255) NOT NULL,
    -- Foreign Key Columns:
    ColumnNameFK1 NUMBER (38,127),
    ColumnNameFK2 VARCHAR2 (4000),
    -- Standard auditing columns (Use 2nd trigger definition):
    Created_Dt DATE NOT NULL,
    Created_By VARCHAR2(100),
    Changed_Dt DATE,
    Changed_By VARCHAR2(100),
    archive NUMBER(1,0) NOT NULL)
PCTFREE 10 PCTUSED 40
;

------------------------------------------------------------------
PROMPT '-- (COMMENT) Comment on table columns --'
-- NOTE:
--  Oracle ApEX uses column comments as the Help Text by default.
------------------------------------------------------------------
COMMENT ON TABLE PrimaryTableName IS '';

-- Run this after creating the table to generate a list of table column comments:
--SELECT '-- COMMENT ON COLUMN '||LOWER(table_name)||'.'||LOWER(column_name)||' IS '''';' "STATEMENTS" FROM user_tab_columns WHERE table_name = UPPER('PrimaryTableName');

COMMENT ON COLUMN PrimaryTableName.ColumnNamePK IS 'PK';

-- COMMENT ON COLUMN PrimaryTableName.ColumnNameUK1 IS 'UK 1of2';
-- COMMENT ON COLUMN PrimaryTableName.ColumnNameUK2 IS 'UK 2of2';
-- COMMENT ON COLUMN PrimaryTableName.ColumnNameFK1 IS 'FK1';
-- COMMENT ON COLUMN PrimaryTableName.ColumnNameFK2 IS 'FK2';

COMMENT ON COLUMN PrimaryTableName.Created_By IS 'Auditing column';
COMMENT ON COLUMN PrimaryTableName.Created_Dt IS 'Auditing column';
COMMENT ON COLUMN PrimaryTableName.Changed_By IS 'Auditing column';
COMMENT ON COLUMN PrimaryTableName.Changed_Dt IS 'Auditing column';

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add the Column Defaults for this table --'
------------------------------------------------------------------
-- ALTER TABLE PrimaryTableName  MODIFY (ColumnNamePK DEFAULT 0);

-- ALTER TABLE PrimaryTableName  MODIFY (ColumnNameUK1 DEFAULT 0);
-- ALTER TABLE PrimaryTableName  MODIFY (ColumnNameUK2 DEFAULT 0);
-- ALTER TABLE PrimaryTableName  MODIFY (ColumnNameFK1 DEFAULT 0);
-- ALTER TABLE PrimaryTableName  MODIFY (ColumnNameFK2 DEFAULT 0);

ALTER TABLE PrimaryTableName  MODIFY (Created_Dt DEFAULT sysdate);
ALTER TABLE PrimaryTableName  MODIFY (archive DEFAULT 0);

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
CREATE UNIQUE INDEX PrimaryTableName_pk ON PrimaryTableName (ColumnNamePK);

-- Unique Key Index 1
-- CREATE UNIQUE INDEX PrimaryTableName_uk1 ON PrimaryTableName (ColumnNameUK1, ColumnNameUK2);

-- Foreign Key Index 1
-- CREATE INDEX PrimaryTableName_ix1 ON PrimaryTableName (ColumnNameFK1);

-- Foreign Key Index 2
-- CREATE INDEX PrimaryTableName_ix2 ON PrimaryTableName (ColumnNameFK2);

-- Tuning Index 3
-- CREATE INDEX PrimaryTableName_ix3 ON PrimaryTableName (ColumnName, ColumnName) [TABLESPACE TablespaceName_index];

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add Constraints for this table --'
------------------------------------------------------------------
ALTER TABLE PrimaryTableName ADD CONSTRAINT PrimaryTableName_pk PRIMARY KEY (ColumnNamePK) USING INDEX;

-- ALTER TABLE PrimaryTableName ADD CONSTRAINT PrimaryTableName_uk1 UNIQUE (ColumnNameUK1, ColumnNameUK2) USING INDEX;

-- ALTER TABLE PrimaryTableName ADD CONSTRAINT PrimaryTableName_c1 CHECK (archive IN (0, -1));

-- ALTER TABLE PrimaryTableName ADD CONSTRAINT PrimaryTableName_c2 CHECK (ColumnName IN ('Value1', 'Value2', 'Value3'));

-- ALTER TABLE PrimaryTableName ADD CONSTRAINT PrimaryTableName_c3 CHECK (ColumnName [<|>|=|!=] Value);

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add the Foreign Keys for this table --'
-- NOTE:
--  Foreign Key Constraints should be created in the referenced
--   tables section of the parent table.
--  Lookup tables shouldn't cascade delete.
--  Only set null if column allows nulls.
--  If you want any records in ReferencedTableName(n) to cascade delete records into PrimaryTableName, use "ON DELETE CASCADE".
--  If you want any records in ReferencedTableName(n) to delete records without deleting records in PrimaryTableName, use "ON DELETE SET NULL".
--  If you want PrimaryTableName to lock ReferencedTableName(n) from deleting records, leave blank.
------------------------------------------------------------------
-- ALTER TABLE PrimaryTableName ADD CONSTRAINT PrimaryTableName_fk1 FOREIGN KEY (ColumnNameFK1) REFERENCES ReferencedTableName1 (ReferencedPK1) [ON DELETE SET NULL];

-- ALTER TABLE PrimaryTableName ADD CONSTRAINT PrimaryTableName_fk2 FOREIGN KEY (ColumnNameFK2) REFERENCES ReferencedTableName2 (ReferencedPK2) [ON DELETE CASCADE];

------------------------------------------------------------------
PROMPT '-- (CREATE SEQUENCE) Create the Sequence for this table --'
------------------------------------------------------------------
-- Simple Create Sequence:
CREATE SEQUENCE PrimaryTableName_sq 
MINVALUE 1 MAXVALUE 9999999999999999999999999999 
INCREMENT BY 1 START WITH 1 CACHE 10 NOORDER NOCYCLE;

-- Rebuild the sequence from table max value:
SET SERVEROUTPUT ON
DECLARE
    v_START_WITH NUMBER := 1;
    v_PrimaryTableName VARCHAR2(30) := 'PrimaryTableName';
BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'SELECT max(NVL(id,0))+1 FROM dual LEFT JOIN '||v_PrimaryTableName||' ON (1=1)' INTO v_START_WITH;
        DBMS_OUTPUT.PUT_LINE('SEQUENCE '||v_PrimaryTableName||'_sq START_WITH='||v_START_WITH);
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE '||v_PrimaryTableName||'_sq';
        DBMS_OUTPUT.PUT_LINE('SEQUENCE '||v_PrimaryTableName||'_sq DROPPED');
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    EXECUTE IMMEDIATE 'CREATE SEQUENCE '||v_PrimaryTableName||'_sq MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH '||v_START_WITH||' CACHE 10 NOORDER NOCYCLE';
    DBMS_OUTPUT.PUT_LINE('SEQUENCE '||v_PrimaryTableName||'_sq CREATED');
END;
/

------------------------------------------------------------------
PROMPT '-- (CREATE TRIGGER) Create Triggers for this table --'
-- NOTE:
--  If the standard auditing columns Created_Dt, Created_By, Changed_Dt, Changed_By are used in the table, uncomment the 2nd Trigger.
------------------------------------------------------------------
CREATE OR REPLACE TRIGGER PrimaryTableName_tr1 BEFORE INSERT OR UPDATE ON PrimaryTableName FOR EACH ROW
DECLARE
    v_Changed_By VARCHAR2(100);
BEGIN
    v_Changed_By := ChangedBy_fn;

    -- Onle set Created when INSERTING
    IF INSERTING THEN
        IF (:NEW.ColumnNamePK IS NULL) THEN
            SELECT PrimaryTableName_sq.NEXTVAL INTO :NEW.ColumnNamePK FROM dual; 
        END IF;
        -- Allow Created_Dt, Created_By to be set in the insert statement
        IF (:NEW.Created_Dt IS NULL) THEN
            :NEW.Created_Dt := sysdate;
        END IF;
        IF (:NEW.Created_By IS NULL) THEN
            :NEW.Created_By := v_Changed_By;
        END IF;
    END IF;

    -- Only set Changed when UPDATING BugFix: Added OR because :NEW contains the old value for updates.
    IF UPDATING THEN
        -- Allow Changed_Dt, Changed_By to be set in the update statement
        IF (:NEW.Changed_Dt IS NULL OR :NEW.Changed_Dt = :OLD.Changed_Dt) THEN
            :NEW.Changed_Dt := SYSDATE;
        END IF;
        IF (:NEW.Changed_By IS NULL OR :NEW.Changed_By = :OLD.Changed_By) THEN
            :NEW.Changed_By := v_Changed_By;
        END IF;
    END IF;
END;
/

------------------------------------------------------------------
PROMPT '-- (INSERT INTO) Insert Values into this table --'
------------------------------------------------------------------
--INSERT INTO PrimaryTableName (ColumnNamePK, ColumnNameUK1, ColumnNameUK2, ColumnNameFK1, ColumnNameFK2) VALUES (1, 0, '', 0, '');
--INSERT INTO PrimaryTableName (ColumnNamePK, ColumnNameUK1, ColumnNameUK2, ColumnNameFK1, ColumnNameFK2) VALUES (2, 0, '', 0, '');
--INSERT INTO PrimaryTableName (ColumnNamePK, ColumnNameUK1, ColumnNameUK2, ColumnNameFK1, ColumnNameFK2) VALUES (3, 0, '', 0, '');
--COMMIT;
--
--EXECUTE DBMS_STATS.GATHER_TABLE_STATS(ownname=>USER, tabname=>UPPER('PrimaryTableName'), cascade=>TRUE, estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=>'for all columns size auto');

------------------------------------------------------------------
PROMPT '-- (GRANT privleges TO roles) --'
-- NOTE:
--  Objects must individually have privliges granted against roles for users with the
--  role to access them. This doesn't apply to the object owner, who can always access the objects.
------------------------------------------------------------------
--GRANT SELECT ON PrimaryTableName TO ReadOnlyRole;
--GRANT SELECT, DELETE, UPDATE, INSERT ON PrimaryTableName TO ReadWriteRole;
--GRANT EXECUTE ON PackageName TO ReadWriteRole;

------------------------------------------------------------------
PROMPT '==================== Alter REFERENCING tables, Add Foreign Key Constraints ===================='
-- Alter REFERENCING tables, adding Foreign Key Columns and Indexes should be done in other table script.
--
-- NOTE:
-- Don't add/remove other tables indexes, just constraints on this table
------------------------------------------------------------------
--DECLARE
--    PROCEDURE ExecSql(p_SQL VARCHAR2) IS
--    BEGIN
--        EXECUTE IMMEDIATE p_SQL;
--    EXCEPTION WHEN OTHERS THEN 
--        IF SQLCODE IN (-942,-1418,-1917,-2275,-2289,-2443,-4043,-12003,-38307) THEN RETURN; END IF; -- Errors for object does not exist
--        RAISE;
--    END;
--BEGIN
--    ExecSql('ALTER TABLE ReferencingTableName1 ADD CONSTRAINT ReferencingTableName1_fk10 FOREIGN KEY (ReferencingColumnName1) REFERENCES PrimaryTableName (ColumnNamePK) [ON DELETE SET NULL]');
--    ExecSql('ALTER TABLE ReferencingTableName2 ADD CONSTRAINT ReferencingTableName2_fk11 FOREIGN KEY (ReferencingColumnName2) REFERENCES PrimaryTableName (ColumnNamePK) [ON DELETE CASCADE]');
--END;
--/

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) after changes ===================='
------------------------------------------------------------------
-- --------------------
PROMPT 'PrimaryTableName'
-- --------------------
SELECT column_name "Name",
    data_type||'('||NVL(data_precision,data_length)||DECODE(NVL(data_scale,-1),-1,'',','||data_scale)||')' "Type",
    DECODE(nullable, 'N', 'NOT NULL', ' ') "Null"
FROM user_tab_columns
WHERE table_name = UPPER('PrimaryTableName')
ORDER BY table_name, column_id;
-- --------------------
PROMPT 'Constraints on PrimaryTableName'
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
    AND rdcn.table_name = UPPER('PrimaryTableName')
    AND rgcn.constraint_type = 'R' 
ORDER BY rgcl.table_name, rgcl.column_name;

------------------------------------------------------------------
PROMPT '==================== END ===================='
------------------------------------------------------------------

-- Quit the SQLPlus environment.
--QUIT;