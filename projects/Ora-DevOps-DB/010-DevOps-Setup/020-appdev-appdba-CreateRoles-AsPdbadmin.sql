/* --------------------------------------------------------------------------------
Purpose:
  Create appdev and appdba roles to grant to any created schema/owner.
Requirements:
  Run as pdbadmin after 010-pdbadmin-GrantRoles-AsSysDBA.sql
History:
  01/01/2019 Mick277, Wrote script.
  17/08/2019 Mick277, Added debug grants.
--------------------------------------------------------------------------------*/
SET PAGESIZE 9000
SET LINESIZE 500

COLUMN username FORMAT A30
COLUMN grantee FORMAT A30
COLUMN granted_role FORMAT A30
COLUMN priv_role FORMAT A100

-- Show non-default users
SELECT username 
from all_users 
WHERE username NOT IN ('SYS','AUDSYS','SYSTEM','SYSBACKUP','SYSDG','SYSKM','SYSRAC','OUTLN','XS$NULL','GSMADMIN_INTERNAL','GSMUSER',
    'DIP','REMOTE_SCHEDULER_AGENT','DBSFWUSER','ORACLE_OCM','SYS$UMF','DBSNMP','APPQOSSYS','GSMCATUSER','GGSYS','XDB','ANONYMOUS','WMSYS',
    'DVSYS','OJVMSYS','CTXSYS','ORDSYS','ORDDATA','ORDPLUGINS','SI_INFORMTN_SCHEMA','MDSYS','OLAPSYS','MDDATA','LBACSYS','DVF','HR',
    'APEX_PUBLIC_USER','APEX_190100','FLOWS_FILES','APEX_INSTANCE_ADMIN_USER','APEX_LISTENER','APEX_REST_PUBLIC_USER','ORDS_PUBLIC_USER','ORDS_METADATA');

DECLARE
  PROCEDURE ExecSql(p_SQL VARCHAR2) IS
  BEGIN
      EXECUTE IMMEDIATE p_SQL;
  EXCEPTION WHEN OTHERS THEN 
    IF SQLCODE IN (-942,-1418,-1917,-1919,-2275,-2289,-2443,-4043,-12003,-38307) THEN RETURN; END IF; -- Errors for object does not exist
    RAISE;
  END;
BEGIN
  ExecSql('DROP ROLE appdev');
  ExecSql('DROP ROLE appdba');
END;
/

CREATE ROLE appdev;

GRANT connect, resource TO appdev;
GRANT alter session TO appdev;
GRANT create cluster TO appdev;
GRANT create dimension TO appdev;
GRANT create indextype TO appdev;
GRANT create library TO appdev;
GRANT create materialized view TO appdev;
GRANT create operator TO appdev;
GRANT create procedure TO appdev;
GRANT create sequence TO appdev;
GRANT create session TO appdev;
GRANT create synonym TO appdev;
GRANT create table TO appdev;
GRANT create trigger TO appdev;
GRANT create type TO appdev;
GRANT create view TO appdev;
GRANT query rewrite TO appdev;
GRANT debug connect session TO appdev;
GRANT debug any procedure TO appdev;

CREATE ROLE appdba;

GRANT appdev TO appdba;
GRANT create external job TO appdba;
GRANT create job TO appdba;
GRANT create database link TO appdba;
--SecFix: GRANT select ON sys.v_$session TO appdba;  
GRANT select ON sys.v_$instance TO appdba;

-- Check granted roles:
SELECT con_id, type, grantee, privilege PRIV_ROLE, admin_option FROM (
    SELECT con_id, 'ROLE' TYPE, grantee, granted_role PRIVILEGE, null ADMIN_OPTION
    FROM cdb_role_privs
    UNION
    SELECT con_id, 'SYS' TYPE, grantee, privilege, admin_option
    FROM cdb_sys_privs
    UNION
    SELECT con_id, 'TAB' TYPE, grantee, LISTAGG(privilege,',') WITHIN GROUP (ORDER BY privilege)||' '||table_name PRIVILEGE, grantable ADMIN_OPTION
    FROM cdb_tab_privs
    GROUP BY con_id, grantee, table_name, grantable
) 
WHERE grantee IN ('PDBADMIN','APPDEV','APPDBA','CONNECT','RESOURCE')
ORDER BY con_id, DECODE(type,'ROLE',1,'SYS',2,'TAB',3,4), grantee, privilege;
