
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
WHERE grantee LIKE :ENTER_GRANTEE
ORDER BY con_id, DECODE(grantee,'PDBADMIN','0',grantee), DECODE(type,'ROLE',1,'SYS',2,'TAB',3,4), privilege;