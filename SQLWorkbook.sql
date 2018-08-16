-- Part I – Working with an existing database
set schema 'chinook';
-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.

-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
SELECT *
FROM employee;
-- Task – Select all records from the Employee table where last name is King.
SELECT *
FROM employee
WHERE lastname = 'King';
-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT *
FROM employee
WHERE firstname = 'Andrew' AND reportsto IS NULL;
-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.
SELECT *
FROM album
ORDER BY title DESC;
-- Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname
FROM customer
ORDER BY city;
-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
INSERT INTO genre(genreid, name)
VALUES (26, 'Genre1'), (27, 'Genre2');
-- Task – Insert two new records into Employee table
INSERT INTO employee(employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email)
VALUES (9, 'Lindner', 'Adrien', 'Software Engineer', NULL, '1995-11-22 00:00:00', '2018-08-01 00:00:00', '83 Nowhere Avenue', 'Columbus', 'OH', 'United States', 
		'43201', '+1 (850) 555-6544', '+1 (850) 555-3463', 'adrien@chinookcorp.com'), 
	(10, 'Smith', 'John', 'IT Staff', 6, '1984-03-27 00:00:00', '2016-04-12 00:00:00', '534 Nowhere Road', 'Columbus', 'OH', 'United States', 
		'43210', '+1 (555) 555-8723', '+1 (555) 555-9846', 'john@chinookcorp.com');
-- Task – Insert two new records into Customer table
INSERT INTO customer(customerid, firstname, lastname, company, address, city, state, country, postalcode, phone, fax, email, supportrepid)
VALUES (60, 'Leena', 'Laverna', 'Amazon', '5934 Nowhere Circle', 'Columbus', 'OH', 'United States', '43210', '+1 (555) 543-3455', '+1 (555) 543-5654', 'leena@amazon.com', 3),
	(61, 'Erno', 'Maytal', 'Microsoft', '5934 Nowhere Boulevard', 'Columbus', 'OH', 'United States', '43210', '+1 (555) 577-7566', '+1 (555) 876-8764', 'erno@microsoft.com', 5);
-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE customer
SET firstname = 'Robert', lastname = 'Walter'
WHERE firstname = 'Aaron' AND lastname = 'Mitchell';
-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE artist
SET name = 'CCR'
WHERE name = 'Creedence Clearwater Revival';
-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
SELECT *
FROM invoice
WHERE billingaddress LIKE 'T%';
-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
SELECT *
FROM invoice
WHERE total BETWEEN 15 AND 50;
-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT *
FROM employee
WHERE hiredate BETWEEN '2003-06-01' AND '2004-03-01';
-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
DELETE FROM invoiceline
WHERE invoiceid IN(
	SELECT invoiceid
	FROM invoice
	WHERE customerid IN(
		SELECT customerid
		FROM customer
		WHERE firstname = 'Robert' AND lastname = 'Walter'
	)
);
DELETE FROM invoice
WHERE customerid IN(
	SELECT customerid
	FROM customer
	WHERE firstname = 'Robert' AND lastname = 'Walter'
);
DELETE FROM customer
WHERE firstname = 'Robert' AND lastname = 'Walter';

-- 3.0	SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
CREATE OR REPLACE FUNCTION get_time()
RETURNS TIME AS $$
	BEGIN
		RETURN current_time;
	END;
$$ LANGUAGE plpgsql;
-- Task – create a function that returns the length of a mediatype from the mediatype table
CREATE OR REPLACE FUNCTION media_type_length(mediatype_id INTEGER)
RETURNS TABLE(length INT) AS $$
	BEGIN
		RETURN QUERY SELECT LENGTH(name) FROM mediatype WHERE mediatypeid=mediatype_id;
	END;
$$ LANGUAGE plpgsql;
-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
CREATE OR REPLACE FUNCTION average_invoice_total()
RETURNS TABLE(average_total NUMERIC(10,2)) AS $$
	BEGIN
		RETURN QUERY SELECT AVG(total) FROM invoice;
	END;
$$ LANGUAGE plpgsql;
-- Task – Create a function that returns the most expensive track
CREATE OR REPLACE FUNCTION most_expensive_track()
RETURNS SETOF track AS $$
	BEGIN
		RETURN QUERY SELECT * FROM track WHERE unitprice=(SELECT MAX(unitprice) FROM track);
	END;
$$ LANGUAGE plpgsql;
-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION average_invoiceline_price()
RETURNS TABLE(average_total NUMERIC(10,2)) AS $$
	BEGIN
		RETURN QUERY SELECT AVG(unitprice) FROM invoiceline;
	END;
$$ LANGUAGE plpgsql;
-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
CREATE OR REPLACE FUNCTION employees_born_after_1968()
RETURNS SETOF employee AS $$
	BEGIN
		RETURN QUERY SELECT * FROM employee WHERE birthdate >= '1968-01-01';
	END;
$$ LANGUAGE plpgsql;

-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE FUNCTION employee_names()
RETURNS TABLE(first_name VARCHAR(20), last_name VARCHAR(20)) AS $$
	BEGIN
		RETURN QUERY SELECT firstname, lastname FROM employee;
	END;
$$ LANGUAGE plpgsql;
-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE FUNCTION update_employee_personal_info(employee_id INTEGER, first_name VARCHAR(20), last_name VARCHAR(20), address VARCHAR(70), city VARCHAR(40), 
														 state VARCHAR(40), country VARCHAR(40), postal_code VARCHAR(10), phone VARCHAR(24), fax VARCHAR(24), 
														 email VARCHAR(60))
RETURNS VOID AS $$
	BEGIN
		UPDATE employee SET firstname=first_name, lastname=last_name, address=update_employee_personal_info.address, city=update_employee_personal_info.city,
							state=update_employee_personal_info.state, country=update_employee_personal_info.country, postalcode=postal_code,
							phone=update_employee_personal_info.phone, fax=update_employee_personal_info.fax, email=update_employee_personal_info.email
		WHERE employeeid = employee_id;
	END;
$$ LANGUAGE plpgsql;
-- Task – Create a stored procedure that returns the managers of an employee.
CREATE OR REPLACE FUNCTION manager_of(employee_id INTEGER)
RETURNS SETOF employee AS $$
	BEGIN
		RETURN QUERY SELECT mgr.* FROM employee AS e INNER JOIN employee AS mgr ON e.reportsto = mgr.employeeid WHERE e.employeeid=employee_id;
	END;
$$ LANGUAGE plpgsql;
-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
CREATE OR REPLACE FUNCTION name_and_company_of(customer_id INTEGER)
RETURNS Table(first_name VARCHAR(40), last_name VARCHAR(20), company VARCHAR(80)) AS $$
	BEGIN
		RETURN QUERY SELECT firstname, lastname, customer.company FROM customer WHERE customerid=customer_id;
	END;
$$ LANGUAGE plpgsql;

-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
CREATE OR REPLACE FUNCTION delete_invoice(invoice_id INTEGER)
RETURNS VOID AS $$
	BEGIN
		DELETE FROM invoiceline
		WHERE invoiceid IN(
			SELECT invoiceid
			FROM invoice
			WHERE invoiceid=invoice_id
		);
		DELETE FROM invoice WHERE invoiceid=invoice_id;
	END;
$$ LANGUAGE plpgsql;
-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
CREATE OR REPLACE FUNCTION create_customer(customer_id INT, first_name VARCHAR(40), last_name VARCHAR(20), company VARCHAR(80), address VARCHAR(70), city VARCHAR(40),
    									   state VARCHAR(40), country VARCHAR(40), postal_code VARCHAR(10), phone VARCHAR(24), fax VARCHAR(24), email VARCHAR(60),
										   support_rep_id INT)
RETURNS VOID AS $$
	BEGIN
		INSERT INTO customer(customerid, firstname, lastname, company, address, city, state, country, postalcode, phone, fax, email, supportrepid) 
		VALUES (customer_id, first_name, last_name, create_customer.company, create_customer.address, create_customer.city, create_customer.state,
			   create_customer.country, postal_code, create_customer.phone, create_customer.fax, create_customer.email, support_rep_id);
	END;
$$ LANGUAGE plpgsql;

-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table
-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
-- 6.2 INSTEAD OF
-- Task – Create an instead of trigger that restricts the deletion of any invoice that is priced over 50 dollars.

-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
SELECT firstname, lastname, invoiceid
FROM customer NATURAL JOIN invoice;
-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
SELECT customer.customerid, firstname, lastname, invoiceid, total
FROM customer LEFT OUTER JOIN invoice ON customer.customerid = invoice.customerid;
-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
SELECT artist.name, title
FROM album RIGHT OUTER JOIN artist ON album.artistid = artist.artistid;
-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT *
FROM album CROSS JOIN artist
ORDER BY name;
-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.
SELECT *
FROM employee AS e1 INNER JOIN employee AS e2 ON e1.reportsto = e2.employeeid;