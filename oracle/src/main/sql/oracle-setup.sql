CREATE OR REPLACE
TYPE address_type
  AS OBJECT (
    street VARCHAR(255),
    city VARCHAR(255),
    country VARCHAR(255));
/
CREATE OR REPLACE
TYPE address_table_type
  AS TABLE OF address_type;
/
CREATE OR REPLACE
  TYPE customer_type
    AS OBJECT (
      id NUMBER(10),
      first_name VARCHAR(255),
      last_name VARCHAR(255),
      email_address VARCHAR(255),
      adresses address_table_type);
/
CREATE SEQUENCE customer_seq
  START WITH 1000
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;
/
CREATE TABLE customer (
  id NUMBER(10) PRIMARY KEY,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  email_address VARCHAR(255),
  addresses address_table_type)
  NESTED TABLE addresses
    STORE AS customer_addresses;
/
CREATE OR REPLACE
FUNCTION save_customer (
  in_customer IN customer_type)
  RETURN customer.id%TYPE
AS
  m_id customer.id%TYPE;
BEGIN
  IF in_customer.id IS NULL THEN
    SELECT customer_seq.NEXTVAL INTO m_id FROM DUAL;
    INSERT into customer
      (id, first_name, last_name, email_address)
      VALUES (
        m_id, in_customer.first_name,
        in_customer.last_name, in_customer.email_address);
  ELSE
    m_id := in_customer.id;
    UPDATE customer SET
      first_name = in_customer.first_name,
      last_name = in_customer.last_name,
      email_address = in_customer.email_address
    WHERE id = m_id;
  END IF;
  RETURN m_id;
END;
/
CREATE OR REPLACE
PROCEDURE get_customer (
  in_customer_id IN customer.id%TYPE,
  out_customer OUT customer_type)
AS
BEGIN
  SELECT customer_type(id, first_name, last_name,
                       email_address, addresses)
    INTO out_customer
    FROM customer WHERE id = in_customer_id;
END;
/
CREATE OR REPLACE
PROCEDURE save_addresses (
  in_customer_id IN customer.id%TYPE,
  in_addresses IN address_table_type)
AS
BEGIN
  UPDATE customer SET addresses = in_addresses
   WHERE id = in_customer_id;
END;
/
