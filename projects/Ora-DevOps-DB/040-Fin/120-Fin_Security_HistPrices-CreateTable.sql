------------------------------------------------------------------
-- Usage:
--
-- Purpose:
--  This script creates table Fin_Security_HistVal, a new table in the database.
--  Foreign Keys on this table Fin_Security_HistVal reference ReferencedTableName1, ReferencedTableName2 etc.
--  Foreign Keys on ReferencingTableName1, ReferencingTableName2 reference this table Fin_Security_HistVal.
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
    AND rdcn.table_name = UPPER('Fin_Security_HistVal')
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
    SELECT DECODE(table_name, null, 0, -1) TABLE_EXISTS INTO V_Exists FROM dual LEFT JOIN user_tables ON (table_name=UPPER('Fin_Security_HistVal'));
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
PROMPT 'Fin_Security_HistVal'
-- --------------------
SELECT column_name "Name",
    data_type||'('||NVL(data_precision,data_length)||DECODE(NVL(data_scale,-1),-1,'',','||data_scale)||')' "Type",
    DECODE(nullable, 'N', 'NOT NULL', ' ') "Null"
FROM user_tab_columns
WHERE table_name = UPPER('Fin_Security_HistVal')
ORDER BY table_name, column_id;

-- --------------------
PROMPT 'Constraints on Fin_Security_HistVal'
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
    AND rdcn.table_name = UPPER('Fin_Security_HistVal')
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
-- DECLARE
--     PROCEDURE ExecSql(p_SQL VARCHAR2) IS
--     BEGIN
--         EXECUTE IMMEDIATE p_SQL;
--         DBMS_OUTPUT.PUT_LINE('Executed: '||p_SQL);
--     EXCEPTION WHEN OTHERS THEN 
--         IF SQLCODE IN (-942,-1418,-1917,-2275,-2289,-2443,-4043,-12003,-38307) THEN RETURN; END IF; -- Errors for object does not exist
--         RAISE;
--     END;
-- BEGIN
-- --ExecSql('ALTER TABLE ReferencingTableName1 DROP CONSTRAINT ReferencingTableName1_fk10');
-- --ExecSql('ALTER TABLE ReferencingTableName2 DROP CONSTRAINT ReferencingTableName2_fk11');
-- 	NULL;
-- END;
-- /

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
	ExecSql('DROP TABLE Fin_Security_HistVal');
END;
/

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) after rollback ===================='
------------------------------------------------------------------
-- --------------------
PROMPT 'Fin_Security_HistVal'
-- --------------------
DECLARE
    v_Exists NUMBER(1) := 0;
BEGIN
    SELECT DECODE(table_name, null, 0, -1) TABLE_EXISTS INTO V_Exists FROM dual LEFT JOIN user_tables ON (table_name=UPPER('Fin_Security_HistVal'));
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

CREATE TABLE Fin_Security_HistVal (
    -- Unique Key Columns
    Security_Code VARCHAR2 (10) NOT NULL,
    Price_Dt DATE NOT NULL,
    value NUMBER(12,6) NOT NULL,
    --
    comments VARCHAR2(50)
)
PCTFREE 1 PCTUSED 20
COMPRESS FOR ALL OPERATIONS
PARTITION BY RANGE (Security_Code) 
  (PARTITION P01 VALUES LESS THAN ('0'),
   PARTITION P02 VALUES LESS THAN ('2'),
   PARTITION P03 VALUES LESS THAN ('4'),
   PARTITION P04 VALUES LESS THAN ('6'),
   PARTITION P05 VALUES LESS THAN ('8'),
   PARTITION P06 VALUES LESS THAN ('A'),
   PARTITION P07 VALUES LESS THAN ('C'),
   PARTITION P08 VALUES LESS THAN ('E'),
   PARTITION P09 VALUES LESS THAN ('G'),
   PARTITION P10 VALUES LESS THAN ('I'),
   PARTITION P11 VALUES LESS THAN ('K'),
   PARTITION P12 VALUES LESS THAN ('M'),
   PARTITION P13 VALUES LESS THAN ('O'),
   PARTITION P14 VALUES LESS THAN ('Q'),
   PARTITION P15 VALUES LESS THAN ('S'),
   PARTITION P16 VALUES LESS THAN ('U'),
   PARTITION P17 VALUES LESS THAN ('W'),
   PARTITION P18 VALUES LESS THAN ('Y'),
   PARTITION P20 VALUES LESS THAN (MAXVALUE))
;

/*
ALTER TABLE Fin_Security_HistVal ADD (Open_Interest NUMBER(12));
*/

------------------------------------------------------------------
PROMPT '-- (COMMENT) Comment on table columns --'
-- NOTE:
--  Oracle ApEX uses column comments as the Help Text by default.
------------------------------------------------------------------
COMMENT ON TABLE Fin_Security_HistVal IS '';

-- Run this after creating the table to generate a list of table column comments:
--SELECT '-- COMMENT ON COLUMN '||LOWER(table_name)||'.'||LOWER(column_name)||' IS '''';' "STATEMENTS" FROM user_tab_columns WHERE table_name = UPPER('Fin_Security_HistVal');

COMMENT ON COLUMN Fin_Security_HistVal.Security_Code IS 'PK 1 of 2';
COMMENT ON COLUMN Fin_Security_HistVal.Price_Dt IS 'PK 2 of 2';
COMMENT ON COLUMN Fin_Security_HistVal.value  IS 'Required. Stock charts can work with just closing price. If there is only a closing, median or average price, it goes in close.';

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add the Column Defaults for this table --'
------------------------------------------------------------------
-- ALTER TABLE Fin_Security_HistVal  MODIFY (ColumnNamePK DEFAULT 0);

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
CREATE UNIQUE INDEX Fin_Security_HistVal_pk ON Fin_Security_HistVal (Security_Code, Price_Dt) COMPRESS LOCAL;

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add Constraints for this table --'
------------------------------------------------------------------
ALTER TABLE Fin_Security_HistVal ADD CONSTRAINT Fin_Security_HistVal_pk PRIMARY KEY (Security_Code, Price_Dt) USING INDEX;

--ALTER TABLE Fin_Security_HistVal ADD CONSTRAINT Fin_Security_HistVal_c1 CHECK (Year <= 2200);
--ALTER TABLE Fin_Security_HistVal ADD CONSTRAINT Fin_Security_HistVal_c1 CHECK (Month >= 1 AND Month <= 12);

------------------------------------------------------------------
PROMPT '-- (ALTER TABLE) Add the Foreign Keys for this table --'
-- NOTE:
--  Foreign Key Constraints should be created in the referenced
--   tables section of the parent table.
--  Lookup tables shouldn't cascade delete.
--  Only set null if column allows nulls.
--  If you want any records in ReferencedTableName(n) to cascade delete records into Fin_Security_HistVal, use "ON DELETE CASCADE".
--  If you want any records in ReferencedTableName(n) to delete records without deleting records in Fin_Security_HistVal, use "ON DELETE SET NULL".
--  If you want Fin_Security_HistVal to lock ReferencedTableName(n) from deleting records, leave blank.
------------------------------------------------------------------
ALTER TABLE Fin_Security_HistVal ADD CONSTRAINT Fin_Security_HistVal_fk1 FOREIGN KEY (Security_Code) REFERENCES Fin_Securities (Code) ON DELETE CASCADE;

------------------------------------------------------------------
-- PROMPT '-- (CREATE SEQUENCE) Create the Sequence for this table --'
------------------------------------------------------------------

------------------------------------------------------------------
PROMPT '-- (CREATE TRIGGER) Create Triggers for this table --'
-- NOTE:
--  If the standard auditing columns Created_Dt, Created_By, Changed_Dt, Changed_By are used in the table, uncomment the 2nd Trigger.
------------------------------------------------------------------
CREATE OR REPLACE TRIGGER Fin_Security_HistVal_tr1 BEFORE INSERT ON Fin_Security_HistVal FOR EACH ROW
DECLARE
    v_Frequency fin_Securities.Frequency%TYPE;
BEGIN
    SELECT NVL(v_Frequency, 'D') PF
    INTO v_Frequency
    FROM fin_Securities
    WHERE code = :NEW.security_code;
    
    -- Truncate the date/time so that all dates with the same precision will align.
    -- E.g. All yearly, Quaterly 
    
    -- 'Y', 'Q', 'M', 'W', 'D', 'H', 'I', 'S'
    CASE v_Frequency
    WHEN 'Y' THEN
        -- Yearly (YYYY) : 01-JAN 
        :NEW.Price_Dt := TRUNC(:NEW.Price_Dt, 'YYYY');
    WHEN 'Q' THEN
        -- Quaterly (Q) : 01-JAN, 01-APR, 01-JUL, 01-OCT
        :NEW.Price_Dt := TRUNC(:NEW.Price_Dt, 'Q');
    WHEN 'M' THEN
        -- Monthly (MM) : 1st day of the month
        :NEW.Price_Dt :=TRUNC(:NEW.Price_Dt, 'MM');
    WHEN 'W' THEN
        -- Weekly
        --WW : Same day of the week as the first day of the year
        --IW : Same day of the week as the first day of the ISO year
        --W : Same day of the week as the first day of the month
        :NEW.Price_Dt :=TRUNC(:NEW.Price_Dt, 'IW');
    WHEN 'D' THEN
        -- Daily
        :NEW.Price_Dt := TRUNC(:NEW.Price_Dt, 'DD');
    WHEN 'H' THEN 
        :NEW.Price_Dt := TRUNC(:NEW.Price_Dt, 'HH24');
    WHEN 'M' THEN 
        :NEW.Price_Dt := TRUNC(:NEW.Price_Dt, 'MI');
    WHEN 'S' THEN
        -- Can't truncate seconds as date is in seconds
        NULL;
    ELSE
        Raise_Application_Error(-20001, 'fin_Securities.Frequency="'||v_Frequency||'" not coded in Fin_Security_HistVal_tr1.');
    END CASE;
END;
/
------------------------------------------------------------------
PROMPT '-- (INSERT INTO) Insert Values into this table --'
------------------------------------------------------------------
--INSERT INTO Fin_Security_HistVal(SELECT * FROM Fin_Security_HIST_Prices);
--COMMIT;
--EXECUTE DBMS_STATS.GATHER_TABLE_STATS(ownname=>USER, tabname=>UPPER('Fin_Security_HistVal'), cascade=>TRUE, estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt=>'for all columns size auto');

------------------------------------------------------------------
PROMPT '-- (GRANT privleges TO roles) --'
-- NOTE:
--  Objects must individually have privliges granted against roles for users with the
--  role to access them. This doesn't apply to the object owner, who can always access the objects.
------------------------------------------------------------------
--GRANT SELECT ON Fin_Security_HistVal TO ReadOnlyRole;
--GRANT SELECT, DELETE, UPDATE, INSERT ON Fin_Security_HistVal TO ReadWriteRole;
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
--    ExecSql('ALTER TABLE ReferencingTableName2 ADD CONSTRAINT ReferencingTableName2_fk11 FOREIGN KEY (ReferencingColumnName2) REFERENCES Fin_Security_HistVal (ColumnNamePK) [ON DELETE CASCADE]');
--END;
--/

------------------------------------------------------------------
PROMPT '==================== Describe TABLE(S) after changes ===================='
------------------------------------------------------------------
-- --------------------
PROMPT 'Fin_Security_HistVal'
-- --------------------
SELECT column_name "Name",
    data_type||'('||NVL(data_precision,data_length)||DECODE(NVL(data_scale,-1),-1,'',','||data_scale)||')' "Type",
    DECODE(nullable, 'N', 'NOT NULL', ' ') "Null"
FROM user_tab_columns
WHERE table_name = UPPER('Fin_Security_HistVal')
ORDER BY table_name, column_id;
-- --------------------
PROMPT 'Constraints on Fin_Security_HistVal'
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
    AND rdcn.table_name = UPPER('Fin_Security_HistVal')
    AND rgcn.constraint_type = 'R' 
ORDER BY rgcl.table_name, rgcl.column_name;

------------------------------------------------------------------
PROMPT '==================== END ===================='
------------------------------------------------------------------

-- Quit the SQLPlus environment.
--QUIT;