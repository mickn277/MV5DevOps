------------------------------------------------------------------
-- Usage:
--
-- Purpose:
--  This script creates table Fin_Securities, a new table in the database.
--  Foreign Keys on this table Fin_Securities reference ReferencedTableName1, ReferencedTableName2 etc.
--  Foreign Keys on ReferencingTableName1, ReferencingTableName2 reference this table Fin_Securities.
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
    AND rdcn.table_name = UPPER('Fin_Securities')
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
    SELECT DECODE(table_name, null, 0, -1) TABLE_EXISTS INTO V_Exists FROM dual LEFT JOIN user_tables ON (table_name=UPPER('Fin_Securities'));
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
PROMPT 'Fin_Securities'
-- --------------------
SELECT column_name "Name",
    data_type||'('||NVL(data_precision,data_length)||DECODE(NVL(data_scale,-1),-1,'',','||data_scale)||')' "Type",
    DECODE(nullable, 'N', 'NOT NULL', ' ') "Null"
FROM user_tab_columns
WHERE table_name = UPPER('Fin_Securities')
ORDER BY table_name, column_id;

-- --------------------
PROMPT 'Constraints on Fin_Securities'
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
    AND rdcn.table_name = UPPER('Fin_Securities')
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
    ExecSQL('ALTER TABLE fin_security_prices DROP CONSTRAINT fin_security_prices_fk1');
    ExecSQL('ALTER TABLE fin_events DROP CONSTRAINT fin_events_fk1');
    ExecSQL('ALTER TABLE fin_events DROP CONSTRAINT fin_events_fk2');
    ExecSQL('ALTER TABLE fin_events DROP CONSTRAINT fin_events_fk3');
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
    ExecSql('DROP TABLE Fin_HistData_Security');
	ExecSql('DROP TABLE Fin_Securities');
END;
/

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) after rollback ===================='
------------------------------------------------------------------
-- --------------------
PROMPT 'Fin_Securities'
-- --------------------
DECLARE
    v_Exists NUMBER(1) := 0;
BEGIN
    SELECT DECODE(table_name, null, 0, -1) TABLE_EXISTS INTO V_Exists FROM dual LEFT JOIN user_tables ON (table_name=UPPER('Fin_Securities'));
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

CREATE TABLE Fin_Securities (
    -- Primary Key Column
    Code VARCHAR2(10) NOT NULL,
    --
    Short_Desc VARCHAR2(100),
    Currency_Code CHAR(3),
    Place_Code VARCHAR2(6),
    Exchange_Code VARCHAR2(6),
    --
    Comments VARCHAR2(255),
    -- Standard auditing columns (Use 2nd trigger definition):
    Created_Dt DATE NOT NULL,
    Created_By VARCHAR2(100),
    Changed_Dt DATE,
    Changed_By VARCHAR2(100),
    archive NUMBER(1,0) NOT NULL)
PCTFREE 10 PCTUSED 40
COMPRESS FOR ALL OPERATIONS
;

/*
ALTER TABLE Fin_Securities ADD (Short_Desc VARCHAR2(100));
*/
------------------------------------------------------------------
PROMPT '-- (COMMENT) Comment on table columns --'
-- NOTE:
--  Oracle ApEX uses column comments as the Help Text by default.
------------------------------------------------------------------
COMMENT ON TABLE Fin_Securities IS '';

-- Run this after creating the table to generate a list of table column comments:
--SELECT '-- COMMENT ON COLUMN '||LOWER(table_name)||'.'||LOWER(column_name)||' IS '''';' "STATEMENTS" FROM user_tab_columns WHERE table_name = UPPER('Fin_Securities');

COMMENT ON COLUMN Fin_Securities.Code IS 'PK';

-- COMMENT ON COLUMN Fin_Securities.ColumnNameUK1 IS 'UK 1of2';
-- COMMENT ON COLUMN Fin_Securities.ColumnNameUK2 IS 'UK 2of2';
-- COMMENT ON COLUMN Fin_Securities.ColumnNameFK1 IS 'FK1';
-- COMMENT ON COLUMN Fin_Securities.ColumnNameFK2 IS 'FK2';

COMMENT ON COLUMN Fin_Securities.Created_By IS 'Auditing column';
COMMENT ON COLUMN Fin_Securities.Created_Dt IS 'Auditing column';
COMMENT ON COLUMN Fin_Securities.Changed_By IS 'Auditing column';
COMMENT ON COLUMN Fin_Securities.Changed_Dt IS 'Auditing column';

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add the Column Defaults for this table --'
------------------------------------------------------------------
-- ALTER TABLE Fin_Securities  MODIFY (Code DEFAULT 0);

-- ALTER TABLE Fin_Securities  MODIFY (ColumnNameUK1 DEFAULT 0);
-- ALTER TABLE Fin_Securities  MODIFY (ColumnNameUK2 DEFAULT 0);
-- ALTER TABLE Fin_Securities  MODIFY (ColumnNameFK1 DEFAULT 0);
-- ALTER TABLE Fin_Securities  MODIFY (ColumnNameFK2 DEFAULT 0);

ALTER TABLE Fin_Securities  MODIFY (Created_Dt DEFAULT sysdate);
ALTER TABLE Fin_Securities  MODIFY (archive DEFAULT 0);

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
CREATE UNIQUE INDEX Fin_Securities_pk ON Fin_Securities (Code);

-- Unique Key Index 1
-- CREATE UNIQUE INDEX Fin_Securities_uk1 ON Fin_Securities (ColumnNameUK1, ColumnNameUK2);

-- Foreign Key Index 1
CREATE INDEX Fin_Securities_ix1 ON Fin_Securities (Place_Code);

-- Foreign Key Index 2
CREATE INDEX Fin_Securities_ix2 ON Fin_Securities (Currency_Code);

-- Tuning Index 3
CREATE INDEX Fin_Securities_ix3 ON Fin_Securities (Exchange_Code);

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add Constraints for this table --'
------------------------------------------------------------------
ALTER TABLE Fin_Securities ADD CONSTRAINT Fin_Securities_pk PRIMARY KEY (Code) USING INDEX;

-- ALTER TABLE Fin_Securities ADD CONSTRAINT Fin_Securities_uk1 UNIQUE (ColumnNameUK1, ColumnNameUK2) USING INDEX;

ALTER TABLE Fin_Securities ADD CONSTRAINT Fin_Securities_c1 CHECK (archive IN (0, -1));
--ALTER TABLE Fin_Securities ADD CONSTRAINT Fin_Securities_c2 CHECK (ColumnName IN ('Value1', 'Value2', 'Value3'));

-- ALTER TABLE Fin_Securities ADD CONSTRAINT Fin_Securities_c3 CHECK (ColumnName [<|>|=|!=] Value);

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add the Foreign Keys for this table --'
-- NOTE:
--  Foreign Key Constraints should be created in the referenced
--   tables section of the parent table.
--  Lookup tables shouldn't cascade delete.
--  Only set null if column allows nulls.
--  If you want any records in ReferencedTableName(n) to cascade delete records into Fin_Securities, use "ON DELETE CASCADE".
--  If you want any records in ReferencedTableName(n) to delete records without deleting records in Fin_Securities, use "ON DELETE SET NULL".
--  If you want Fin_Securities to lock ReferencedTableName(n) from deleting records, leave blank.
------------------------------------------------------------------
ALTER TABLE Fin_Securities ADD CONSTRAINT Fin_Securities_fk1 FOREIGN KEY (Place_Code) REFERENCES Geo_Places (Code) ON DELETE SET NULL;
ALTER TABLE Fin_Securities ADD CONSTRAINT Fin_Securities_fk2 FOREIGN KEY (Currency_Code) REFERENCES Geo_Currencies (Code) ON DELETE SET NULL;
--ALTER TABLE Fin_Securities ADD CONSTRAINT Fin_Securities_fk3 FOREIGN KEY (Exchange_Code) REFERENCES Geo_Exchanges (Code) ON DELETE SET NULL;

------------------------------------------------------------------
PROMPT '-- (CREATE SEQUENCE) Create the Sequence for this table --'
------------------------------------------------------------------
-- -- Simple Create Sequence:
-- CREATE SEQUENCE Fin_Securities_sq 
-- MINVALUE 1 MAXVALUE 9999999999999999999999999999 
-- INCREMENT BY 1 START WITH 1 CACHE 10 NOORDER NOCYCLE;

-- -- Rebuild the sequence from table max value:
-- SET SERVEROUTPUT ON
-- DECLARE
--     v_START_WITH NUMBER := 1;
--     v_Fin_Securities VARCHAR2(30) := 'Fin_Securities';
-- BEGIN
--     BEGIN
--         EXECUTE IMMEDIATE 'SELECT max(NVL(id,0))+1 FROM dual LEFT JOIN '||v_Fin_Securities||' ON (1=1)' INTO v_START_WITH;
--         DBMS_OUTPUT.PUT_LINE('SEQUENCE '||v_Fin_Securities||'_sq START_WITH='||v_START_WITH);
--     EXCEPTION WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE(SQLERRM);
--     END;
--     BEGIN
--         EXECUTE IMMEDIATE 'DROP SEQUENCE '||v_Fin_Securities||'_sq';
--         DBMS_OUTPUT.PUT_LINE('SEQUENCE '||v_Fin_Securities||'_sq DROPPED');
--     EXCEPTION WHEN OTHERS THEN
--         NULL;
--     END;
--     EXECUTE IMMEDIATE 'CREATE SEQUENCE '||v_Fin_Securities||'_sq MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH '||v_START_WITH||' CACHE 10 NOORDER NOCYCLE';
--     DBMS_OUTPUT.PUT_LINE('SEQUENCE '||v_Fin_Securities||'_sq CREATED');
-- END;
-- /

------------------------------------------------------------------
PROMPT '-- (CREATE TRIGGER) Create Triggers for this table --'
-- NOTE:
--  If the standard auditing columns Created_Dt, Created_By, Changed_Dt, Changed_By are used in the table, uncomment the 2nd Trigger.
------------------------------------------------------------------
CREATE OR REPLACE TRIGGER Fin_Securities_tr1 BEFORE INSERT OR UPDATE ON Fin_Securities FOR EACH ROW
DECLARE
    v_Changed_By VARCHAR2(100);
BEGIN
    v_Changed_By := ChangedBy_fn;

    -- Onle set Created when INSERTING
    IF INSERTING THEN
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

--EXECUTE DBMS_STATS.GATHER_TABLE_STATS(ownname=>USER, tabname=>UPPER('Fin_Securities'), cascade=>TRUE, estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=>'for all columns size auto');

------------------------------------------------------------------
PROMPT '-- (GRANT privleges TO roles) --'
-- NOTE:
--  Objects must individually have privliges granted against roles for users with the
--  role to access them. This doesn't apply to the object owner, who can always access the objects.
------------------------------------------------------------------
--GRANT SELECT ON Fin_Securities TO ReadOnlyRole;
--GRANT SELECT, DELETE, UPDATE, INSERT ON Fin_Securities TO ReadWriteRole;
--GRANT EXECUTE ON PackageName TO ReadWriteRole;

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
    ExecSQL('ALTER TABLE fin_security_prices ADD CONSTRAINT fin_security_prices_fk1 FOREIGN KEY (security_code) REFERENCES fin_securities (code) ON DELETE CASCADE');
    ExecSQL('ALTER TABLE fin_events ADD CONSTRAINT fin_events_fk1 FOREIGN KEY (security_code) REFERENCES fin_securities (code) ON DELETE SET NULL');
    ExecSQL('ALTER TABLE fin_events ADD CONSTRAINT fin_events_fk2 FOREIGN KEY (security_code_2nd) REFERENCES fin_securities (code) ON DELETE SET NULL');
    ExecSQL('ALTER TABLE fin_events ADD CONSTRAINT fin_events_fk3 FOREIGN KEY (security_code_3rd) REFERENCES fin_securities (code) ON DELETE SET NULL');
END;
/

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) after changes ===================='
------------------------------------------------------------------
-- --------------------
PROMPT 'Fin_Securities'
-- --------------------
SELECT column_name "Name",
    data_type||'('||NVL(data_precision,data_length)||DECODE(NVL(data_scale,-1),-1,'',','||data_scale)||')' "Type",
    DECODE(nullable, 'N', 'NOT NULL', ' ') "Null"
FROM user_tab_columns
WHERE table_name = UPPER('Fin_Securities')
ORDER BY table_name, column_id;
-- --------------------
PROMPT 'Constraints on Fin_Securities'
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
    AND rdcn.table_name = UPPER('Fin_Securities')
    AND rgcn.constraint_type = 'R' 
ORDER BY rgcl.table_name, rgcl.column_name;

------------------------------------------------------------------
PROMPT '==================== END ===================='
------------------------------------------------------------------

-- Quit the SQLPlus environment.
--QUIT;