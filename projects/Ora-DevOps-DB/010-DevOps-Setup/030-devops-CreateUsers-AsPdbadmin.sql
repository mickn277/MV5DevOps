/* --------------------------------------------------------------------------------
Purpose:
  Create devopsp and devopsd users (schema/owner).
Requirements:
  Run as pdbadmin ...
History:
  01/01/2019 Mick277, Wrote script.
--------------------------------------------------------------------------------*/

-- --------------------------------------------------------------------------------
-- devopsp (PROD)
-- --------------------------------------------------------------------------------
CREATE USER devopsp IDENTIFIED BY "#PASSWORD#" DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;

-- System privledges CONNECT and RESOURCE are granted to APPDEV.
GRANT appdba,appdev TO devopsp;

-- BugFix: This is needed for EXECUTE IMMEDIATE 'CREATE...';
GRANT create table TO devopsp;
GRANT create view TO devopsp;

ALTER USER devopsp QUOTA UNLIMITED ON users;

-- --------------------------------------------------------------------------------
-- devopsd (DEV)
-- --------------------------------------------------------------------------------
CREATE USER devopsd IDENTIFIED BY "#PASSWORD#" DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;

-- System privledges CONNECT and RESOURCE are granted to APPDEV.
GRANT appdba,appdev TO devopsd;

-- BugFix: This is needed for EXECUTE IMMEDIATE 'CREATE...';
GRANT create table TO devopsd;
GRANT create view TO devopsd;

ALTER USER devopsd QUOTA 1G ON users;

-- --------------------------------------------------------------------------------
-- ROLLBACK
-- --------------------------------------------------------------------------------
/*
DROP USER devopsp;
DROP USER devopsd;

*/