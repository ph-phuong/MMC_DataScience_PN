CREATE DATABASE Sale_Management;

USE Sale_Management;

CREATE TABLE Customers (
    customer_id                 INT,
    first_name                  VARCHAR(50),
    last_name                   VARCHAR(50),
    email_address               VARCHAR(50),
    numbers_of_complaints       INT
)

CREATE TABLE Sales (
    purchase_number             INT,
    data_of_purchase            DATE,
    customer_id                 INT,
    item_code                   VARCHAR(50)
)

CREATE TABLE Items (
    item_code                   VARCHAR(50),
    item                        VARCHAR(50),
    unit_price_usd              INT,
    company_id                  INT,
    company                     VARCHAR(50),
    headquaters_phone_number    VARCHAR(50)
)

