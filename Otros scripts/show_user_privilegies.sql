--Prints the current role
select current_role();

--Shows all the privilegies of the specified role
show grants to role public;

--Shows all the properties of the current user
desc user01;

--Shows all the roles of the specified user
show grants to user user01;

--To check who had created this user
show grants on user user01;

--Context function()
select current_account(), current_user(), current_role();

--List all the users and see who created them
use role accountadmin;
show users;

