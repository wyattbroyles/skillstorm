--Getting Started

CREATE DATABASE asgn1
GO

use asgn1
GO

CREATE TABLE users (
    user_id INT IDENTITY PRIMARY KEY,
    user_first_name VARCHAR(30) NOT NULL,
    user_last_name VARCHAR(30) NOT NULL,
    user_email_id VARCHAR(50) NOT NULL,
    user_email_validated BIT DEFAULT 0,
    user_password VARCHAR(200),
    user_role VARCHAR(1) NOT NULL DEFAULT 'U', --U and A
    is_active BIT DEFAULT 0,
    created_dt DATE DEFAULT GETDATE()
);

--Database Operations
--Excercise 1

CREATE TABLE courses (
	course_id INT IDENTITY,
	course_name VARCHAR(240) NOT NULL,
	course_author VARCHAR(160) NOT NULL,
	course_status VARCHAR(10) CHECK (course_status IN ('published', 'draft', 'inactive')) NOT NULL,
	course_published_dt DATE DEFAULT getdate()
);

ALTER TABLE courses
ADD CONSTRAINT pk_course_id PRIMARY KEY CLUSTERED (course_id)

--Excercise 2
INSERT INTO courses
    (course_name, course_author, course_status, course_published_dt)
VALUES
    ('Programming using Python', 'Bob Dillon',	'published',	'2020-09-30'),
    ('Data Engineering using Python', 'Bob Dillonm', 'published',	'2020-07-15'),
    ('Data Engineering using Scala',	'Elvis Presley',	'draft', NULL),
	('Programming using Scala',	'Elvis Presley',	'published',	'2020-05-12'),
	('Programming using Java',	'Mike Jack',	'inactive',	'2020-08-10'),
	('Web Applications - Python Flask',	'Bob Dillon',	'inactive',	'2020-07-20'),
	('Web Applications - Java Spring',	'Mike Jack',	'draft', NULL),
	('Pipeline Orchestration - Python',	'Bob Dillon',	'draft', NULL),
	('Streaming Pipelines - Python',	'Bob Dillon',	'published',	'2020-10-05'),
	('Web Applications - Scala Play',	'Elvis Presley',	'inactive',	'2020-09-30'),
	('Web Applications - Python Django',	'Bob Dillon',	'published',	'2020-06-23'),
	('Server Automation - Ansible',	'Uncle Sam',	'published',	'2020-07-05');

SELECT * FROM courses

--Excercise 3
UPDATE courses
SET 
	course_status = 'published', 
	course_published_dt = getdate()
WHERE (course_name LIKE '%Python%' OR course_name LIKE '%Scala%') AND course_status = 'draft'

--Excercise 4
DELETE FROM courses WHERE course_status != 'draft' AND course_status != 'published'
--DELETE FROM courses
--WHERE course_status NOT IN ('draft', 'published');

SELECT course_author, COUNT(1) AS course_count
FROM courses
WHERE course_status= 'published'
GROUP BY course_author 
ORDER BY course_count DESC

--Basic SQL Queries
USE retail_db;

SELECT * FROM order_items
SELECT * FROM orders

SELECT * FROM customers
SELECT * FROM departments
SELECT * FROM products
SELECT * FROM categories
--Excercise 1
SELECT 
	c.customer_id,
	c.customer_fname,
	c.customer_lname, 
	COUNT(1) AS [Order Count], 
	format(o.order_date, 'yyyy-MM') AS [Order Month]
FROM 
	customers c
JOIN 
	orders o ON c.customer_id = o.order_customer_id
WHERE 
	FORMAT(o.order_date, 'yyyy-MM') = '2014-01'
GROUP BY 
	FORMAT(o.order_date, 'yyyy-MM'), 
	c.customer_id,
	c.customer_fname, 
	c.customer_lname
ORDER BY 
	[Order Count] DESC, 
	c.customer_id ASC;

--Excercise 2
SELECT * FROM customers c
LEFT JOIN orders o ON c.customer_id = o.order_customer_id
AND FORMAT(o.order_date, 'yyyy-MM') = '2014-01'
WHERE o.order_customer_id IS NULL
ORDER BY c.customer_id ASC

--Excercise 3
SELECT 
    c.customer_id, 
    c.customer_fname AS customer_first_name, 
    c.customer_lname AS customer_last_name, 
    COALESCE(SUM(oi.order_item_subtotal), 0) AS customer_revenue
FROM 
    customers c
LEFT JOIN 
    orders o ON c.customer_id = o.order_customer_id 
    AND FORMAT(o.order_date, 'yyyy-MM') = '2014-01'
    AND (o.order_status LIKE 'COMPLETE%'
	OR o.order_status LIKE 'CLOSED%')
LEFT JOIN 
    order_items oi ON o.order_id = oi.order_item_order_id
GROUP BY 
    c.customer_id, 
    c.customer_fname, 
    c.customer_lname
ORDER BY 
    customer_revenue DESC, 
    c.customer_id ASC;

--Excercise 4
SELECT 
    ca.category_id, 
    ca.category_department_id, 
    ca.category_name, 
    COALESCE(SUM(oi.order_item_subtotal), 0) AS category_revenue
FROM 
    categories ca
JOIN 
    products p ON ca.category_id = p.product_category_id
JOIN 
    order_items oi ON p.product_id = oi.order_item_product_id
JOIN 
    orders o ON oi.order_item_order_id = o.order_id
WHERE 
    FORMAT(o.order_date, 'yyyy-MM') = '2014-01'
    AND (o.order_status LIKE 'COMPLETE%'
	OR o.order_status LIKE 'CLOSED%')
GROUP BY 
    ca.category_id, 
    ca.category_department_id, 
    ca.category_name
ORDER BY 
    ca.category_id ASC;

--Excercise 5
SELECT
	d.department_id,
	d.department_name,
	COUNT(1) AS product_count
FROM
	products p
JOIN 
	categories c ON p.product_category_id = c.category_id
JOIN
	departments d ON c.category_department_id = d.department_id
GROUP BY
	d.department_id,
	d.department_name
ORDER BY
	d.department_id ASC;

--Managing Database Objects
--create_db_tables_mssql.sql script was altered

USE retail_db

-- For departments
DECLARE @max_department_id INT;
DECLARE @next_department_id INT;
DECLARE @sql NVARCHAR(MAX);

SELECT @max_department_id = MAX(department_id) FROM departments;
SET @next_department_id = @max_department_id + 1;

SET @sql = 'ALTER SEQUENCE departments_department_id_seq RESTART WITH ' + CAST(@next_department_id AS NVARCHAR(10));
EXEC sp_executesql @sql;

-- For categories
DECLARE @max_category_id INT;
DECLARE @next_category_id INT;

SELECT @max_category_id = MAX(category_id) FROM categories;
SET @next_category_id = @max_category_id + 1;

SET @sql = 'ALTER SEQUENCE categories_category_id_seq RESTART WITH ' + CAST(@next_category_id AS NVARCHAR(10));
EXEC sp_executesql @sql;

-- For products
DECLARE @max_product_id INT;
DECLARE @next_product_id INT;

SELECT @max_product_id = MAX(product_id) FROM products;
SET @next_product_id = @max_product_id + 1;

SET @sql = 'ALTER SEQUENCE products_product_id_seq RESTART WITH ' + CAST(@next_product_id AS NVARCHAR(10));
EXEC sp_executesql @sql;

-- For customers
DECLARE @max_customer_id INT;
DECLARE @next_customer_id INT;

SELECT @max_customer_id = MAX(customer_id) FROM customers;
SET @next_customer_id = @max_customer_id + 1;

SET @sql = 'ALTER SEQUENCE customers_customer_id_seq RESTART WITH ' + CAST(@next_customer_id AS NVARCHAR(10));
EXEC sp_executesql @sql;

-- For orders
DECLARE @max_order_id INT;
DECLARE @next_order_id INT;

SELECT @max_order_id = MAX(order_id) FROM orders;
SET @next_order_id = @max_order_id + 1;

SET @sql = 'ALTER SEQUENCE orders_order_id_seq RESTART WITH ' + CAST(@next_order_id AS NVARCHAR(10));
EXEC sp_executesql @sql;

-- For order_items
DECLARE @max_order_item_id INT;
DECLARE @next_order_item_id INT;

SELECT @max_order_item_id = MAX(order_item_id) FROM order_items;
SET @next_order_item_id = @max_order_item_id + 1;

SET @sql = 'ALTER SEQUENCE order_items_order_item_id_seq RESTART WITH ' + CAST(@next_order_item_id AS NVARCHAR(10));
EXEC sp_executesql @sql;

--Excercise 2
SELECT o.order_id, o.order_customer_id
FROM orders o
LEFT JOIN customers c ON o.order_customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT oi.order_item_id, oi.order_item_order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_item_order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT oi.order_item_id, oi.order_item_product_id
FROM order_items oi
LEFT JOIN products p ON oi.order_item_product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT p.product_id, p.product_category_id
FROM products p
LEFT JOIN categories c ON p.product_category_id = c.category_id
WHERE c.category_id IS NULL;

SELECT c.category_id, c.category_department_id
FROM categories c
LEFT JOIN departments d ON c.category_department_id = d.department_id
WHERE d.department_id IS NULL;

--Check if primary key constraints are created
SELECT 
    tc.TABLE_NAME, 
    kcu.COLUMN_NAME, 
    tc.CONSTRAINT_NAME
FROM 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
JOIN 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE 
    tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

--Check if foreign key constraints are created
SELECT 
    tc.TABLE_NAME, 
    kcu.COLUMN_NAME, 
    rc.CONSTRAINT_NAME AS FK_CONSTRAINT_NAME, 
    rc.UNIQUE_CONSTRAINT_NAME AS REFERENCED_CONSTRAINT_NAME
FROM 
    INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS rc
JOIN 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
    ON rc.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
JOIN 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE 
    tc.CONSTRAINT_TYPE = 'FOREIGN KEY';

--check if default constraints are created
SELECT 
    c.TABLE_NAME, 
    c.COLUMN_NAME, 
    c.COLUMN_DEFAULT
FROM 
    INFORMATION_SCHEMA.COLUMNS AS c
WHERE 
    c.COLUMN_DEFAULT IS NOT NULL;

--Check if sequences are created
SELECT 
    name AS SEQUENCE_NAME, 
    start_value, 
    current_value
FROM 
    sys.sequences;

-- Partiioning and Indexing
--Exercise 1

--Exercise2

-- Pre-Defined Function
USE retail_db

CREATE TABLE users (
    user_id int PRIMARY KEY IDENTITY,
    user_first_name VARCHAR(30),
    user_last_name VARCHAR(30),
    user_email_id VARCHAR(50),
    user_gender VARCHAR(1),
    user_unique_id VARCHAR(15),
    user_phone_no VARCHAR(20),
    user_dob DATE,
    created_ts DATETIME
);

insert into users (
    user_first_name, user_last_name, user_email_id, user_gender, 
    user_unique_id, user_phone_no, user_dob, created_ts
) VALUES
    ('Giuseppe', 'Bode', 'gbode0@imgur.com', 'M', '88833-8759', 
     '+86 (764) 443-1967', '1973-05-31', '2018-04-15 12:13:38'),
    ('Lexy', 'Gisbey', 'lgisbey1@mail.ru', 'N', '262501-029', 
     '+86 (751) 160-3742', '2003-05-31', '2020-12-29 06:44:09'),
    ('Karel', 'Claringbold', 'kclaringbold2@yale.edu', 'F', '391-33-2823', 
     '+62 (445) 471-2682', '1985-11-28', '2018-11-19 00:04:08'),
    ('Marv', 'Tanswill', 'mtanswill3@dedecms.com', 'F', '1195413-80', 
     '+62 (497) 736-6802', '1998-05-24', '2018-11-19 16:29:43'),
    ('Gertie', 'Espinoza', 'gespinoza4@nationalgeographic.com', 'M', '471-24-6869', 
     '+249 (687) 506-2960', '1997-10-30', '2020-01-25 21:31:10'),
    ('Saleem', 'Danneil', 'sdanneil5@guardian.co.uk', 'F', '192374-933', 
     '+63 (810) 321-0331', '1992-03-08', '2020-11-07 19:01:14'),
    ('Rickert', 'O''Shiels', 'roshiels6@wikispaces.com', 'M', '749-27-47-52', 
     '+86 (184) 759-3933', '1972-11-01', '2018-03-20 10:53:24'),
    ('Cybil', 'Lissimore', 'clissimore7@pinterest.com', 'M', '461-75-4198', 
     '+54 (613) 939-6976', '1978-03-03', '2019-12-09 14:08:30'),
    ('Melita', 'Rimington', 'mrimington8@mozilla.org', 'F', '892-36-676-2', 
     '+48 (322) 829-8638', '1995-12-15', '2018-04-03 04:21:33'),
    ('Benetta', 'Nana', 'bnana9@google.com', 'N', '197-54-1646', 
     '+420 (934) 611-0020', '1971-12-07', '2018-10-17 21:02:51'),
    ('Gregorius', 'Gullane', 'ggullanea@prnewswire.com', 'F', '232-55-52-58', 
     '+62 (780) 859-1578', '1973-09-18', '2020-01-14 23:38:53'),
    ('Una', 'Glayzer', 'uglayzerb@pinterest.com', 'M', '898-84-336-6', 
     '+380 (840) 437-3981', '1983-05-26', '2019-09-17 03:24:21'),
    ('Jamie', 'Vosper', 'jvosperc@umich.edu', 'M', '247-95-68-44', 
     '+81 (205) 723-1942', '1972-03-18', '2020-07-23 16:39:33'),
    ('Calley', 'Tilson', 'ctilsond@issuu.com', 'F', '415-48-894-3', 
     '+229 (698) 777-4904', '1987-06-12', '2020-06-05 12:10:50'),
    ('Peadar', 'Gregorowicz', 'pgregorowicze@omniture.com', 'M', '403-39-5-869', 
     '+7 (267) 853-3262', '1996-09-21', '2018-05-29 23:51:31'),
    ('Jeanie', 'Webling', 'jweblingf@booking.com', 'F', '399-83-05-03', 
     '+351 (684) 413-0550', '1994-12-27', '2018-02-09 01:31:11'),
    ('Yankee', 'Jelf', 'yjelfg@wufoo.com', 'F', '607-99-0411', 
     '+1 (864) 112-7432', '1988-11-13', '2019-09-16 16:09:12'),
    ('Blair', 'Aumerle', 'baumerleh@toplist.cz', 'F', '430-01-578-5', 
     '+7 (393) 232-1860', '1979-11-09', '2018-10-28 19:25:35'),
    ('Pavlov', 'Steljes', 'psteljesi@macromedia.com', 'F', '571-09-6181', 
     '+598 (877) 881-3236', '1991-06-24', '2020-09-18 05:34:31'),
    ('Darn', 'Hadeke', 'dhadekej@last.fm', 'M', '478-32-02-87', 
     '+370 (347) 110-4270', '1984-09-04', '2018-02-10 12:56:00'),
    ('Wendell', 'Spanton', 'wspantonk@de.vu', 'F', null, 
     '+84 (301) 762-1316', '1973-07-24', '2018-01-30 01:20:11'),
    ('Carlo', 'Yearby', 'cyearbyl@comcast.net', 'F', null, 
     '+55 (288) 623-4067', '1974-11-11', '2018-06-24 03:18:40'),
    ('Sheila', 'Evitts', 'sevittsm@webmd.com', null, '830-40-5287',
     null, '1977-03-01', '2020-07-20 09:59:41'),
    ('Sianna', 'Lowdham', 'slowdhamn@stanford.edu', null, '778-0845', 
     null, '1985-12-23', '2018-06-29 02:42:49'),
    ('Phylys', 'Aslie', 'paslieo@qq.com', 'M', '368-44-4478', 
     '+86 (765) 152-8654', '1984-03-22', '2019-10-01 01:34:28')

--Exercise 1
SELECT 
	YEAR(created_ts) AS [created_year], 
	COUNT(1) AS [user_count]
FROM 
	users
GROUP BY
	YEAR(created_ts)
ORDER BY 
	YEAR(created_ts) ASC;

--Exercise 2
SELECT 
	user_id,
	user_dob,
	user_email_id,
	DATENAME(dw, user_dob) AS [user_day_of_birth]
FROM
	users
WHERE
	format(user_dob, 'MM') = 05
GROUP BY
	user_id,
	user_dob,
	user_email_id
ORDER BY
	DATENAME(day, user_dob)

--Exercise 3
SELECT
	user_id,
	upper(CONCAT(user_first_name, ' ', user_last_name)) AS [user_name],
	user_email_id,
	YEAR(created_ts) AS [created_year]
FROM 
	users
WHERE
	format(created_ts, 'yyyy') = 2019
ORDER BY
	CONCAT(user_first_name, ' ', user_last_name) ASC

--Exercise 4
SELECT 
	user_gender = CASE user_gender
		WHEN 'M' THEN 'Male'
		WHEN 'F' THEN 'Female'
		WHEN 'N' THEN 'Non-Binary'
		ELSE 'Not Specified'
		END,
	COUNT(1) AS [user_count]
FROM
	users
GROUP BY
	user_gender
ORDER BY
	COUNT(1) DESC

--Exercise 5
SELECT
	user_id,
	user_unique_id,
	CASE 
        WHEN LEN(REPLACE(user_unique_id, '-', '')) < 9 THEN 'Invalid Unique ID'
        WHEN RIGHT(REPLACE(user_unique_id, '-', ''), 4) IS NULL THEN 'Not Specified'
        ELSE RIGHT(REPLACE(user_unique_id, '-', ''), 4)
    END AS user_unique_id_last4
FROM
	users
ORDER BY
	user_id

--Exercise 6
SELECT
	REPLACE(SUBSTRING(user_phone_no, 2, 4), '(', '') AS country_code,
	COUNT(1) AS user_count
FROM
	users
GROUP BY
	REPLACE(SUBSTRING(user_phone_no, 2, 4), '(', '')
ORDER BY
	REPLACE(SUBSTRING(user_phone_no, 2, 4), '(', '') ASC

WITH CleanedNumbers AS (
    SELECT
        user_id,
        -- Initial extraction and cleaning of the substring
        REPLACE(SUBSTRING(user_phone_no, 2, 4), '(', '') AS Initial_Cleaned,
        -- Check if there's a digit-space-digit pattern and clean accordingly
        CASE
            WHEN PATINDEX('%[0-9] [0-9]%', REPLACE(SUBSTRING(user_phone_no, 2, 4), '(', '')) > 0 THEN 
                LEFT(SUBSTRING(user_phone_no, 2, 4), CHARINDEX(' ', SUBSTRING(user_phone_no, 2, 4)) - 1)
            ELSE 
               REPLACE(SUBSTRING(user_phone_no, 2, 4), '(', '')
        END AS country_code
    FROM
        users
)
SELECT
    country_code,
    COUNT(1) AS user_count
FROM 
    CleanedNumbers
WHERE
	country_code IS NOT NULL
GROUP BY 
    country_code
ORDER BY 
    CAST(country_code AS INT);

--Exercise 7
SELECT 
    COUNT(1) AS [Count]
FROM
    order_items
WHERE 
    ROUND(order_item_subtotal, 2) != ROUND(order_item_quantity * order_item_product_price, 2)

--Exercise 8
SELECT
    CASE DATENAME(dw, order_date)
        WHEN 'Saturday' THEN 'Weekend days'
        WHEN 'Sunday' THEN 'Weekend days'
        WHEN 'Monday' THEN 'Week days'
        WHEN 'Tuesday' THEN 'Week days'
        WHEN 'Wednesday' THEN 'Week days'
        WHEN 'Thursday' THEN 'Week days'
        WHEN 'Friday' THEN 'Week days'
        ELSE 'Not Specified'
    END AS day_category,
    COUNT(1) AS [order_count]
FROM
    orders
WHERE
	format(order_date, 'yyyy-MM') = '2014-01'
GROUP BY
    CASE DATENAME(dw, order_date)
        WHEN 'Saturday' THEN 'Weekend days'
        WHEN 'Sunday' THEN 'Weekend days'
        WHEN 'Monday' THEN 'Week days'
        WHEN 'Tuesday' THEN 'Week days'
        WHEN 'Wednesday' THEN 'Week days'
        WHEN 'Thursday' THEN 'Week days'
        WHEN 'Friday' THEN 'Week days'
        ELSE 'Not Specified'
    END
ORDER BY
    day_category;

--Subqueries and CTE Exercises
USE retail_db

SELECT * FROM order_items
SELECT * FROM orders
SELECT * FROM customers
SELECT * FROM products

SELECT * FROM departments

SELECT * FROM categories

--Exercise 1
SELECT * 
FROM categories c
WHERE (SELECT COUNT(1) 
       FROM products p 
       WHERE p.product_category_id = c.category_id) > 5;

--Exercise 2
SELECT *,
	(SELECT COUNT(1)
        FROM orders o
        WHERE c.customer_id = o.order_customer_id) AS [purchase_count]
FROM customers c
WHERE (SELECT COUNT(1)
		FROM orders o
		WHERE c.customer_id = o.order_customer_id) > 10;

--Exercise 3
SELECT p.product_name,
       (SELECT AVG(p2.product_price)
        FROM products p2
        JOIN order_items oi2 ON p2.product_id = oi2.order_item_product_id
        JOIN orders o2 ON oi2.order_item_order_id = o2.order_id
        WHERE FORMAT(o2.order_date, 'yyyy-MM') = '2013-10') AS avg_price
FROM products p
JOIN order_items oi ON p.product_id = oi.order_item_product_id
JOIN orders o ON oi.order_item_order_id = o.order_id
WHERE FORMAT(o.order_date, 'yyyy-MM') = '2013-10'
GROUP BY p.product_name;

--Exercise 4
SELECT o.*,
       (SELECT SUM(oi.order_item_subtotal)
        FROM order_items oi
        WHERE oi.order_item_order_id = o.order_id) AS total_amount,
		(SELECT AVG(total_order_amount)
       FROM (SELECT SUM(oi2.order_item_subtotal) AS total_order_amount
             FROM order_items oi2
             GROUP BY oi2.order_item_order_id) AS subquery) AS avg_amount
FROM orders o
WHERE (SELECT SUM(oi.order_item_subtotal)
       FROM order_items oi
       WHERE oi.order_item_order_id = o.order_id) > 
      (SELECT AVG(total_order_amount)
       FROM (SELECT SUM(oi2.order_item_subtotal) AS total_order_amount
             FROM order_items oi2
             GROUP BY oi2.order_item_order_id) AS subquery);

--Exercise 5
WITH CategoryProductCount AS (
    SELECT c.category_name, COUNT(p.product_id) AS product_count
    FROM categories c
    JOIN products p ON c.category_id = p.product_category_id
    GROUP BY c.category_name
)
SELECT TOP 3 category_name, product_count
FROM CategoryProductCount
ORDER BY product_count DESC;

--Exercise 6
WITH SumPerCustomerSpending AS (
    SELECT c.customer_id, SUM(oi.order_item_subtotal) AS sum_spending
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_item_order_id
    JOIN customers c ON c.customer_id = o.order_customer_id
    WHERE MONTH(o.order_date) = 12
    GROUP BY c.customer_id
),
AboveAverageSpendingCustomers AS (
    SELECT AVG(sum_spending) AS CustomerSpendingAverage
    FROM SumPerCustomerSpending
)
SELECT c.customer_id, c.customer_fname, s.sum_spending
FROM SumPerCustomerSpending s
JOIN customers c ON c.customer_id = s.customer_id
WHERE s.sum_spending > (SELECT CustomerSpendingAverage FROM AboveAverageSpendingCustomers);



--Analytics Functions
CREATE DATABASE hr_db

