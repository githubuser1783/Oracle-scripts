/*
UP = User Privileges

Note:
Relevent views:
- user_role_privs - roles granted to current user
- user_sys_privs - system privileges granted to current user
- role_sys_privs - system privileges granted to role. Note. role_sys_privs appears to be a subset of dba_sys_privs
- role_tab_privs - table privileges granted to role

- dba_sys_privs - system privileges granted to users and roles. Note. role_sys_privs appears to be a subset of dba_sys_privs
- dba_tab_privs - table privileges granted to users and roles

- system_privilege_map

Connecting through a proxy user makes no difference. The privileges are for the connected user and not the proxy user.

*/

@saveset

set pagesize 10000
set verify off
set feed off
set timing off
set head off
set serveroutput on

/* Little trick for 'defaulting' argument 1, if not set. */ 
COLUMN 1 NEW_VALUE 1
SELECT '' "1" FROM dual WHERE ROWNUM = 0;

var script_user varchar2(30);
begin
   if '&1' is not null then
      :script_user := '&1';
   else
      :script_user := '&_USER';
   end if;
end;
/

prompt 
exec dbms_output.put_line('Database privileges for ' || :script_user);
exec dbms_output.put_line(rpad('*',length(:script_user) + 24, '*'));

prompt

set feed on
set head on


Prompt role and associated system privileges granted to user
SELECT
   rp.granted_role role,
   sp.privilege,
   sp.admin_option
FROM
   dba_role_privs rp
LEFT JOIN dba_sys_privs sp ON rp.granted_role = sp.grantee
WHERE
   rp.grantee = :script_user
ORDER BY
   rp.granted_role,
   sp.privilege;

/* Often returns too many rows so is commented out

Prompt role and associated table privileged granted to user
SELECT
   rp.granted_role role,
   tp.privilege,
   tp.owner,
   tp.table_name,
   tp.grantable,
   tp.grantor
FROM dba_role_privs rp
LEFT JOIN dba_tab_privs tp ON (rp.granted_role = tp.grantee)
WHERE
   rp.grantee = :script_user
ORDER BY
   1, 3, 4;
*/

prompt System privileges explicitly granted to the user (not through a role)
SELECT
   privilege
FROM dba_sys_privs
WHERE
   grantee = :script_user
ORDER BY
   privilege;

prompt Table privileges granted to the user
SELECT
   owner,
   table_name,
   privilege,
   grantable
FROM dba_tab_privs
WHERE
   grantee = :script_user
ORDER BY
   owner, table_name, privilege;


@loadset

undef 1