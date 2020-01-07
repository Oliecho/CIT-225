DROP TABLE my_common;

CREATE TABLE my_common AS 
  SELECT * FROM common_lookup;

  
  ALTER TABLE my_common 
  ADD (my_table   VARCHAR(30))
  ADD (my_column  VARCHAR2(30))
  ADD (my_code    VARCHAR2(30));
  
  UPDATE my_common 
  SET    my_table = common_lookup_context
  ,      my_column = common_lookup_context || '_TYPE'
  WHERE NOT common_lookup_context = 'MULTIPLE';
  
  UPDATE my_common 
  SET    my_table = 'ADDRESS'
  ,      my_column =  'ADDRESS_TYPE'
  WHERE NOT common_lookup_context = 'MULTIPLE';
  
  COL my_table  FORMAT A14
  COL my_column FORMAT A20
  COL common_lookup_context FORMAT A20
  SELECT my_table
  ,      my_column
  ,      common_lookup_context
  FROM my_common;
  
  ALTER TABLE my_common
   MODIFY (my_table VARCHAR2(30) NOT NULL)
   MODIFY (my_column VARCHAR2(30) NOT NULL);
   
   ALTER TABLE my_common
   DROP COLUMN common_lookup_context;
   
   
   UPDATE telephone 
   SET    telephone_type = 
            (SELECT common_lookup_id -- How to find the new primary key.
             FROM my_common
             WHERE my_table = 'TELEPHONE'
             AND my_column = 'TELEPHONE_TYPE')
   WHERE    telephone_type = 
            (SELECT common_lookup_id  -- How to find old primary key.
             FROM my_common
             WHERE my_table = 'TELEPHONE'
             AND my_column = 'TELEPHONE_TYPE')
