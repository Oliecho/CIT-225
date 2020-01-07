SELECT SELECT first_name
|| CASE
WHEN middle_name IS NOT NULL THEN
' ' || middle_name || ' '
ELSE
' '
END
|| last_name AS full_name
FROM contact;
