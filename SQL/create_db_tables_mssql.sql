-- Postgres Table Creation Script
--

--
-- Table structure for table departments
--
CREATE DATABASE retail_db;
GO

USE retail_db3;
GO

-- Table structure for table departments
CREATE TABLE departments (
  department_id INT NOT NULL,
  department_name VARCHAR(45) NOT NULL,
  PRIMARY KEY (department_id)
);

-- Create sequence for departments
CREATE SEQUENCE departments_department_id_seq START WITH 1 INCREMENT BY 1;
GO

-- Set default value for department_id using the sequence
ALTER TABLE departments
ADD CONSTRAINT df_department_id DEFAULT NEXT VALUE FOR departments_department_id_seq FOR department_id;
GO

-- Table structure for table categories
CREATE TABLE categories (
  category_id INT NOT NULL,
  category_department_id INT NOT NULL,
  category_name VARCHAR(45) NOT NULL,
  PRIMARY KEY (category_id),
  FOREIGN KEY (category_department_id) REFERENCES departments(department_id)
);

-- Create sequence for categories
CREATE SEQUENCE categories_category_id_seq START WITH 1 INCREMENT BY 1;
GO

-- Set default value for category_id using the sequence
ALTER TABLE categories
ADD CONSTRAINT df_category_id DEFAULT NEXT VALUE FOR categories_category_id_seq FOR category_id;
GO

-- Table structure for table products
CREATE TABLE products (
  product_id INT NOT NULL,
  product_category_id INT NOT NULL,
  product_name VARCHAR(45) NOT NULL,
  product_description VARCHAR(255) NOT NULL,
  product_price FLOAT NOT NULL,
  product_image VARCHAR(255) NOT NULL,
  PRIMARY KEY (product_id),
  FOREIGN KEY (product_category_id) REFERENCES categories(category_id)
);

-- Create sequence for products
CREATE SEQUENCE products_product_id_seq START WITH 1 INCREMENT BY 1;
GO

-- Set default value for product_id using the sequence
ALTER TABLE products
ADD CONSTRAINT df_product_id DEFAULT NEXT VALUE FOR products_product_id_seq FOR product_id;
GO

-- Table structure for table customers
CREATE TABLE customers (
  customer_id INT NOT NULL,
  customer_fname VARCHAR(45) NOT NULL,
  customer_lname VARCHAR(45) NOT NULL,
  customer_email VARCHAR(45) NOT NULL,
  customer_password VARCHAR(45) NOT NULL,
  customer_street VARCHAR(255) NOT NULL,
  customer_city VARCHAR(45) NOT NULL,
  customer_state VARCHAR(45) NOT NULL,
  customer_zipcode VARCHAR(45) NOT NULL,
  PRIMARY KEY (customer_id)
);

-- Create sequence for customers
CREATE SEQUENCE customers_customer_id_seq START WITH 1 INCREMENT BY 1;
GO

-- Set default value for customer_id using the sequence
ALTER TABLE customers
ADD CONSTRAINT df_customer_id DEFAULT NEXT VALUE FOR customers_customer_id_seq FOR customer_id;
GO

-- Table structure for table orders
CREATE TABLE orders (
  order_id INT NOT NULL,
  order_date DATETIME NOT NULL,
  order_customer_id INT NOT NULL,
  order_status VARCHAR(45) NOT NULL,
  PRIMARY KEY (order_id),
  FOREIGN KEY (order_customer_id) REFERENCES customers(customer_id)
);

-- Create sequence for orders
CREATE SEQUENCE orders_order_id_seq START WITH 1 INCREMENT BY 1;
GO

-- Set default value for order_id using the sequence
ALTER TABLE orders
ADD CONSTRAINT df_order_id DEFAULT NEXT VALUE FOR orders_order_id_seq FOR order_id;
GO

-- Table structure for table order_items
CREATE TABLE order_items (
  order_item_id INT NOT NULL,
  order_item_order_id INT NOT NULL,
  order_item_product_id INT NOT NULL,
  order_item_quantity INT NOT NULL,
  order_item_subtotal FLOAT NOT NULL,
  order_item_product_price FLOAT NOT NULL,
  PRIMARY KEY (order_item_id),
  FOREIGN KEY (order_item_order_id) REFERENCES orders(order_id),
  FOREIGN KEY (order_item_product_id) REFERENCES products(product_id)
);

-- Create sequence for order_items
CREATE SEQUENCE order_items_order_item_id_seq START WITH 1 INCREMENT BY 1;
GO

-- Set default value for order_item_id using the sequence
ALTER TABLE order_items
ADD CONSTRAINT df_order_item_id DEFAULT NEXT VALUE FOR order_items_order_item_id_seq FOR order_item_id;
GO
