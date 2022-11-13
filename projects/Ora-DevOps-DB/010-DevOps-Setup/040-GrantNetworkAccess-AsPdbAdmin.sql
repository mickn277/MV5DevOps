-- Enable Network Services in Oracle Database
-- Required For:
-- 	Sending outbound mail in Oracle APEX.
-- 	Consuming web services from APEX.
DECLARE
	v_host VARCHAR2(50);
	v_apex VARCHAR2(30);
BEGIN
	--v_host := 'localhost'; -- Only local network hosts
	v_host  := '*'; -- All hosts
    
	-- Get the latest installed ApEx Version:
	SELECT MAX(owner) INTO v_apex
	FROM all_views WHERE view_name LIKE 'APEX_APPLICATIONS';

	DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
		host => '*',
		ace => xs$ace_type(privilege_list => xs$name_list('connect'),
		principal_name => v_apex,
		principal_type => xs_acl.ptype_db)
	);
END;
/