-- ------------------------------------------------------------------
--  Program Name:   apply_oracle_lab8.sql
--  Lab Assignment: Lab #8
--  Program Author: Benard Oliech
--  Creation Date:  27-June-2020
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
--   sql> @apply_oracle_lab8.sql
--
-- ------------------------------------------------------------------

-- Call library files.
@/home/student/Data/cit225/oracle/lab7/apply_oracle_lab7.sql

-- Open log file.
SPOOL apply_oracle_lab8.txt

-- ... insert lab 8 commands here ...

-------------------------------------------------------------
-- Start Part 1
-------------------------------------------------------------
CREATE SEQUENCE price_s1;

INSERT INTO price
( price_id
, item_id
, price_type
, active_flag
, start_date
, end_date
, amount
, created_by
, creation_date
, last_updated_by
, last_updated_date)
SELECT price_s1.nextval
, i.item_id
, cl.common_lookup_id
, af.active_flag
,  CASE
    WHEN (TRUNC(SYSDATE) - i.release_date) <= 30 OR
     (TRUNC(SYSDATE) - i.release_date) > 30 AND
      af.active_flag = 'N' 
	THEN i.release_date
	ELSE i.release_date + 31
	END AS
,	CASE
	WHEN (TRUNC(SYSDATE) - i.release_date) > 30 AND 
        af.active_flag = 'N' 
	THEN i.release_date + 30
	END AS
,	CASE
	WHEN (TRUNC(SYSDATE) - i.release_date) <= 30 
	THEN
            CASE
		WHEN dr.rental_days = 1 
		THEN 3
		WHEN dr.rental_days = 3 
		THEN 10
		WHEN dr.rental_days = 5 
		THEN 15 --new rentals
			END
		WHEN (TRUNC(SYSDATE) - i.release_date) > 30 AND
		      af.active_flag = 'N' 
	THEN
	  CASE
		WHEN dr.rental_days = 1 
		THEN 3
		WHEN dr.rental_days = 3 
		THEN 10
		WHEN dr.rental_days = 5 
		THEN 15
		     	END
		ELSE
	 CASE
		 WHEN dr.rental_days = 1 
	         THEN 1
		 WHEN dr.rental_days = 3 
		THEN 3
		  WHEN dr.rental_days = 5 
		THEN 5
		     	END
	END AS
, 1
, SYSDATE
, 1
, SYSDATE
FROM		 item i CROSS JOIN
		(SELECT 'Y' AS active_flag FROM dual
		 UNION ALL
 	      	 SELECT 'N' AS active_flag FROM dual) af CROSS JOIN  	     
		(SELECT '1' AS rental_days FROM dual
 	      	 UNION ALL
  	      	 SELECT '3' AS rental_days FROM dual
    	      	 UNION ALL
   	      	 SELECT '5' AS rental_days FROM dual) dr INNER JOIN
  	     	 common_lookup cl ON dr.rental_days = SUBSTR(cl.common_lookup_type,1,1)
WHERE    cl.common_lookup_table = 'PRICE'
AND      cl.common_lookup_column = 'PRICE_TYPE'
AND NOT	 ((af.active_flag = 'N' AND (TRUNC(SYSDATE) - 30) < i.release_date));

-- Start Test Part 1
SELECT  'OLD Y' AS "Type"
,        COUNT(CASE WHEN amount = 1 THEN 1 END) AS "1-Day"
,        COUNT(CASE WHEN amount = 3 THEN 1 END) AS "3-Day"
,        COUNT(CASE WHEN amount = 5 THEN 1 END) AS "5-Day"
,        COUNT(*) AS "TOTAL"
FROM     price p , item i
WHERE    active_flag = 'Y' AND i.item_id = p.item_id
AND     (TRUNC(SYSDATE) - TRUNC(i.release_date)) > 30
AND      end_date IS NULL
UNION ALL
SELECT  'OLD N' AS "Type"
,        COUNT(CASE WHEN amount =  3 THEN 1 END) AS "1-Day"
,        COUNT(CASE WHEN amount = 10 THEN 1 END) AS "3-Day"
,        COUNT(CASE WHEN amount = 15 THEN 1 END) AS "5-Day"
,        COUNT(*) AS "TOTAL"
FROM     price p , item i
WHERE    active_flag = 'N' AND i.item_id = p.item_id
AND     (TRUNC(SYSDATE) - TRUNC(i.release_date)) > 30
AND NOT end_date IS NULL
UNION ALL
SELECT  'NEW Y' AS "Type"
,        COUNT(CASE WHEN amount =  3 THEN 1 END) AS "1-Day"
,        COUNT(CASE WHEN amount = 10 THEN 1 END) AS "3-Day"
,        COUNT(CASE WHEN amount = 15 THEN 1 END) AS "5-Day"
,        COUNT(*) AS "TOTAL"
FROM     price p , item i
WHERE    active_flag = 'Y' AND i.item_id = p.item_id
AND     (TRUNC(SYSDATE) - TRUNC(i.release_date)) < 31
AND      end_date IS NULL
UNION ALL
SELECT  'NEW N' AS "Type"
,        COUNT(CASE WHEN amount = 1 THEN 1 END) AS "1-Day"
,        COUNT(CASE WHEN amount = 3 THEN 1 END) AS "3-Day"
,        COUNT(CASE WHEN amount = 5 THEN 1 END) AS "5-Day"
,        COUNT(*) AS "TOTAL"
FROM     price p , item i
WHERE    active_flag = 'N' AND i.item_id = p.item_id
AND     (TRUNC(SYSDATE) - TRUNC(i.release_date)) < 31
AND      NOT (end_date IS NULL);
-- End Test Part1
-------------------------------------------------------------
-- End Part 1
-------------------------------------------------------------

-------------------------------------------------------------
-- Start Part 2
-------------------------------------------------------------
ALTER TABLE price
MODIFY price_type CONSTRAINT nn_price_9 NOT NULL;

-- Start Test Part 2
COLUMN CONSTRAINT FORMAT A10
SELECT   TABLE_NAME
,        column_name
,        CASE
           WHEN NULLABLE = 'N' THEN 'NOT NULL'
           ELSE 'NULLABLE'
         END AS CONSTRAINT
FROM     user_tab_columns
WHERE    TABLE_NAME = 'PRICE'
AND      column_name = 'PRICE_TYPE';
-- End Test Part 2

-------------------------------------------------------------
-- End Part 2
-------------------------------------------------------------


-------------------------------------------------------------
-- Start Part 3
-------------------------------------------------------------
UPDATE   rental_item ri
SET      rental_item_price =
          (SELECT   p.amount
           FROM     price p INNER JOIN common_lookup cl1
           ON       p.price_type = cl1.common_lookup_id CROSS JOIN rental r
                    CROSS JOIN common_lookup cl2 
           WHERE    p.item_id = ri.item_id AND ri.rental_id = r.rental_id
           AND      ri.rental_item_type = cl2.common_lookup_id
           AND      cl1.common_lookup_code = cl2.common_lookup_code
           AND      r.check_out_date
                      BETWEEN p.start_date AND NVL(p.end_date,TRUNC(SYSDATE) + 1));
                      
COL customer_name  FORMAT A24  HEADING "Customer Name"
COL city           FORMAT A12  HEADING "City"
COL state          FORMAT A6   HEADING "State"
COL telephone      FORMAT A10  HEADING "Telephone"
SELECT   m.account_number
,        c.last_name||', '||c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name
         END AS customer_name
,        a.city AS city
,        a.state_province AS state
,        t.telephone_number AS telephone
FROM     member m INNER JOIN contact c
ON       m.member_id = c.member_id INNER JOIN address a
ON       c.contact_id = a.contact_id INNER JOIN telephone t
ON       c.contact_id = t.contact_id;                      


COL account_number  FORMAT A10  HEADING "Account|Number"
COL customer_name   FORMAT A22  HEADING "Customer Name"
COL rental_id       FORMAT 9999 HEADING "Rental|ID #"
COL rental_item_id  FORMAT 9999 HEADING "Rental|Item|ID #"
SELECT   m.account_number
,        c.last_name||', '||c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name
         END AS customer_name
,        r.rental_id
,        ri.rental_item_id
FROM     member m INNER JOIN contact c
ON       m.member_id = c.member_id INNER JOIN rental r
ON       c.contact_id = r.customer_id INNER JOIN rental_item ri
ON       r.rental_id = ri.rental_id
ORDER BY 3, 4;

COL account_number  FORMAT A10  HEADING "Account|Number"
COL customer_name   FORMAT A22  HEADING "Customer Name"
COL rental_id       FORMAT 9999 HEADING "Rental|ID #"
COL rental_item_id  FORMAT 9999 HEADING "Rental|Item|ID #"
SELECT   m.account_number
,        c.last_name||', '||c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name
         END AS customer_name
,        r.rental_id
,        ri.rental_item_id
FROM     member m INNER JOIN contact c
ON       m.member_id = c.member_id INNER JOIN rental r
ON       c.contact_id = r.customer_id INNER JOIN rental_item ri
ON       r.rental_id = ri.rental_id
ORDER BY 3, 4;

COL common_lookup_table  FORMAT A12 HEADING "Common|Lookup Table"
COL common_lookup_column FORMAT A18 HEADING "Common|Lookup Column"
COL common_lookup_code   FORMAT 999 HEADING "Common|Lookup|Code"
COL total_pk_count       FORMAT 999 HEADING "Foreign|Key|Count"
SELECT   cl.common_lookup_table
,        cl.common_lookup_column
,        TO_NUMBER(cl.common_lookup_code) AS common_lookup_code
,        COUNT(*) AS total_pk_count
FROM     price p INNER JOIN common_lookup cl
ON       p.price_type = cl.common_lookup_id
AND      cl.common_lookup_table = 'PRICE'
AND      cl.common_lookup_column = 'PRICE_TYPE'
GROUP BY cl.common_lookup_table
,        cl.common_lookup_column
,        cl.common_lookup_code
UNION ALL
SELECT   cl.common_lookup_table
,        cl.common_lookup_column
,        TO_NUMBER(cl.common_lookup_code) AS common_lookup_code
,        COUNT(*) AS total_pk_count
FROM     rental_item ri INNER JOIN common_lookup cl
ON       ri.rental_item_type = cl.common_lookup_id
AND      cl.common_lookup_table = 'RENTAL_ITEM'
AND      cl.common_lookup_column = 'RENTAL_ITEM_TYPE'
GROUP BY cl.common_lookup_table
,        cl.common_lookup_column
,        cl.common_lookup_code
ORDER BY 1, 2, 3;


COL customer_name          FORMAT A20  HEADING "Contact|--------|Customer Name"
COL r_rental_id            FORMAT 9999 HEADING "Rental|------|Rental|ID #"
COL amount                 FORMAT 9999 HEADING "Price|------||Amount"
COL price_type_code        FORMAT 9999 HEADING "Price|------|Type|Code"
COL rental_item_type_code  FORMAT 9999 HEADING "Rental|Item|------|Type|Code"
COL needle                 FORMAT A11  HEADING "Rental|--------|Check Out|Date"
COL low_haystack           FORMAT A11  HEADING "Price|--------|Start|Date"
COL high_haystack          FORMAT A11  HEADING "Price|--------|End|Date"
SELECT   c.last_name||', '||c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name
         END AS customer_name
,        ri.rental_id AS ri_rental_id
,        p.amount
,        TO_NUMBER(cl2.common_lookup_code) AS price_type_code
,        TO_NUMBER(cl2.common_lookup_code) AS rental_item_type_code
,        p.start_date AS low_haystack
,        r.check_out_date AS needle
,        NVL(p.end_date,TRUNC(SYSDATE) + 1) AS high_haystack
FROM     price p INNER JOIN common_lookup cl1
ON       p.price_type = cl1.common_lookup_id
AND      cl1.common_lookup_table = 'PRICE'
AND      cl1.common_lookup_column = 'PRICE_TYPE' FULL JOIN rental_item ri 
ON       p.item_id = ri.item_id INNER JOIN common_lookup cl2
ON       ri.rental_item_type = cl2.common_lookup_id
AND      cl2.common_lookup_table = 'RENTAL_ITEM'
AND      cl2.common_lookup_column = 'RENTAL_ITEM_TYPE' RIGHT JOIN rental r
ON       ri.rental_id = r.rental_id FULL JOIN contact c
ON       r.customer_id = c.contact_id
WHERE    cl1.common_lookup_code = cl2.common_lookup_code
AND      p.active_flag = 'Y'  
AND NOT  r.check_out_date
           BETWEEN  p.start_date AND NVL(p.end_date,TRUNC(SYSDATE) + 1)
ORDER BY 2, 3;
-- Start Test Part 3
-- Widen the display console.
SET LINESIZE 110
 
-- Set the column display values.
COL customer_name          FORMAT A20  HEADING "Contact|--------|Customer Name"
COL contact_id             FORMAT 9999 HEADING "Contact|--------|Contact|ID #"
COL customer_id            FORMAT 9999 HEADING "Rental|--------|Customer|ID #"
COL r_rental_id            FORMAT 9999 HEADING "Rental|------|Rental|ID #"
COL ri_rental_id           FORMAT 9999 HEADING "Rental|Item|------|Rental|ID #"
COL rental_item_id         FORMAT 9999 HEADING "Rental|Item|------||ID #"
COL price_item_id          FORMAT 9999 HEADING "Price|------|Item|ID #"
COL rental_item_item_id    FORMAT 9999 HEADING "Rental|Item|------|Item|ID #"
COL rental_item_price      FORMAT 9999 HEADING "Rental|Item|------||Price"
COL amount                 FORMAT 9999 HEADING "Price|------||Amount"
COL price_type_code        FORMAT 9999 HEADING "Price|------|Type|Code"
COL rental_item_type_code  FORMAT 9999 HEADING "Rental|Item|------|Type|Code"
SELECT   c.last_name||', '||c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name
         END AS customer_name
,        c.contact_id
,        r.customer_id
,        r.rental_id AS r_rental_id
,        ri.rental_id AS ri_rental_id
,        ri.rental_item_id
,        p.item_id AS price_item_id
,        ri.item_id AS rental_item_item_id
,        ri.rental_item_price
,        p.amount
,        TO_NUMBER(cl2.common_lookup_code) AS price_type_code
,        TO_NUMBER(cl2.common_lookup_code) AS rental_item_type_code
FROM     price p INNER JOIN common_lookup cl1
ON       p.price_type = cl1.common_lookup_id
AND      cl1.common_lookup_table = 'PRICE'
AND      cl1.common_lookup_column = 'PRICE_TYPE' FULL JOIN rental_item ri 
ON       p.item_id = ri.item_id INNER JOIN common_lookup cl2
ON       ri.rental_item_type = cl2.common_lookup_id
AND      cl2.common_lookup_table = 'RENTAL_ITEM'
AND      cl2.common_lookup_column = 'RENTAL_ITEM_TYPE' RIGHT JOIN rental r
ON       ri.rental_id = r.rental_id FULL JOIN contact c
ON       r.customer_id = c.contact_id
WHERE    cl1.common_lookup_code = cl2.common_lookup_code
AND      r.check_out_date
BETWEEN  p.start_date AND NVL(p.end_date,TRUNC(SYSDATE) + 1)
ORDER BY 2, 3;
 
-- Reset the column display values to their default value.
SET LINESIZE 90
-- End Test Part 3
-------------------------------------------------------------
-- End Part 3
-------------------------------------------------------------

-------------------------------------------------------------
-- Start Part 4
-------------------------------------------------------------
ALTER TABLE rental_item
MODIFY rental_item_price CONSTRAINT nn_rental_item_8 NOT NULL;

-- Start Test Part 4
COLUMN CONSTRAINT FORMAT A10
SELECT   TABLE_NAME
,        column_name
,        CASE
           WHEN NULLABLE = 'N' THEN 'NOT NULL'
           ELSE 'NULLABLE'
         END AS CONSTRAINT
FROM     user_tab_columns
WHERE    TABLE_NAME = 'RENTAL_ITEM'
AND      column_name = 'RENTAL_ITEM_PRICE';
-- End Test Part 4
-------------------------------------------------------------
-- Start Part 4
-------------------------------------------------------------
SPOOL OFF
