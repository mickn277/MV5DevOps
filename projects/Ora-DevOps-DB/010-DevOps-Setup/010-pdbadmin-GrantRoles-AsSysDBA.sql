/* --------------------------------------------------------------------------------
Usage:
  # Open a powershell console on Windows.
  # Connect to VM as vagrant:
  vagrant ssh
  # Change to oracle user:
  sudo su - oracle
  # Run SQLPlus as sysdba:
  $ORACLE_HOME/bin/sqlplus '/ as sysdaba'
  # SQL Prompt should appear, then run this script

Purpose:
  This script grants DBA role to pdbadmin so that one user can perform all administrative tasks for the database.

Requirements:
  Run this script sys as sysdba on new Oracle XE database on VM.

History:
  01/01/2019 Mick277, Wrote script.
-------------------------------------------------------------------------------- */

ALTER SESSION SET CONTAINER = XEPDB1;



-- For daily DBA work, the role DBA (on PDB-level) is missing.
GRANT dba TO pdbadmin;

GRANT select ON sys.v_$session TO pdbadmin WITH GRANT OPTION;
GRANT select ON sys.v_$instance TO pdbadmin WITH GRANT OPTION;

SET PAGESIZE 9000
SET LINESIZE 500
COLUMN grantee FORMAT A50
COLUMN priv_role FORMAT A100
COLUMN admin_option FORMAT A12

-- Check PDBADMIN has dba,pdb_dba roles:


SELECT con_id, grantee, type, privilege PRIV_ROLE, admin_option FROM (
    SELECT con_id, grantee, 'ROLE' TYPE, granted_role PRIVILEGE, null ADMIN_OPTION
    FROM cdb_role_privs
    UNION
    SELECT con_id, grantee, 'SYS' TYPE, privilege, admin_option
    FROM cdb_sys_privs
    UNION
    SELECT con_id, grantee, 'TAB' TYPE, LISTAGG(privilege,',') WITHIN GROUP (ORDER BY privilege)||' '||table_name PRIVILEGE, grantable ADMIN_OPTION
    FROM cdb_tab_privs
    GROUP BY con_id, grantee, table_name, grantable
) 
WHERE grantee IN ('PDBADMIN','DBA','PDB_DBA')
ORDER BY con_id, DECODE(grantee,'PDBADMIN','0',grantee), DECODE(type,'ROLE',1,'SYS',2,'TAB',3,4), privilege;

