-- ------------------------------------------------------------------
--  Program Name:   apply_oracle_lab4.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  17-Jan-2018
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
-- This creates tables, sequences, indexes, and constraints necessary
-- to begin lesson #4. Demonstrates proper process and syntax.
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- The two scripts contain spooling commands, which is why there
-- isn't a spooling command in this script. When you run this file
-- you first connect to the Oracle database with this syntax:
--
--   sqlplus student/student@xe
--
-- Then, you call this script with the following syntax:
--
--   sql> @apply_oracle_lab4.sql
--
-- ------------------------------------------------------------------

-- Open log file.  
SPOOL apply_oracle_lab4.txt

-- Run the prior lab script.
@/home/student/Data/cit225/oracle/lab3/apply_oracle_lab3.sql
@/home/student/Data/cit225/oracle/lib1/seed/seeding.sql
 
-- ------------------------------------------------------------------
-- Call the lab versions of the file.
-- ---------------------------------------------------------------

@@group_account1_lab.sql
@@group_account2_lab.sql
@@group_account3_lab.sql
@@item_inserts_lab.sql
@@create_insert_contacts_lab.sql
@@individual_accounts_lab.sql
@@update_members_lab.sql
@@rental_inserts_lab.sql
@@create_view_lab.sql
 

-- ------------------------------------------------------------------
--  The following queries should be placed here:
-- ------------------------------------------------------------------
--  6(c) diagnostics for the individual_accounts.sql script.
--  7(c) diagnostics for the update_members.sql script.
--  8(c) diagnostics for the rental_inserts.sql script.
--  9(c) diagnostics for the create_view_lab.sql script.
-- ------------------------------------------------------------------
 
-- Close log file.
SPOOL OFF
 
-- Make all changes permanent.
COMMIT;
