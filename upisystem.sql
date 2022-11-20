DROP DATABASE IF EXISTS upi_system;
CREATE DATABASE upi_system;

USE upi_system;

CREATE TABLE individual (
	ssn VARCHAR(20)  PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    house_number VARCHAR(5),
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(6),
    phone_number VARCHAR(10)
);


CREATE TABLE bank (
	bank_name VARCHAR(50),
    bank_reg_id INT PRIMARY KEY,
    routing_number INT UNIQUE,
    building_number INT,
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(6)
);


CREATE TABLE branch (
	branch_id VARCHAR(20) PRIMARY KEY,
    bank_reg_id INT UNIQUE,
    branch_name VARCHAR(50),
    building_number INT,
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(6),
    CONSTRAINT branch_bank_reg_id 
		FOREIGN KEY (bank_reg_id) REFERENCES bank (bank_reg_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE bank_account (
	ssn VARCHAR(20),
	branch_id VARCHAR(20),
	account_number VARCHAR(20) PRIMARY KEY,
    balance DOUBLE,
    CONSTRAINT bank_account_branch_id 
		FOREIGN KEY (branch_id) REFERENCES branch (branch_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT bank_account_ssn
		FOREIGN KEY (ssn) REFERENCES individual (ssn)
        ON UPDATE CASCADE ON DELETE CASCADE
);
    
    
CREATE TABLE bank_transactions (
	bank_transaction_id VARCHAR(60) PRIMARY KEY,
    personal_account_details VARCHAR(20),
    transaction_type ENUM('DEBIT', 'CREDIT'),
    account_number VARCHAR(20),
    sender_receiver_account_details VARCHAR(20),
    transaction_date DATE,
    transaction_value DOUBLE,
    transaction_message VARCHAR(100),
    CONSTRAINT bank_transactions_account_number
		FOREIGN KEY (account_number) REFERENCES bank_account (account_number)
        ON UPDATE CASCADE
);

CREATE TABLE upi_transaction (
	upi_transaction_id VARCHAR(60) PRIMARY KEY,
    sender_receiver_transaction_id VARCHAR(30),
    transaction_date DATE,
    personal_transaction_id VARCHAR(60),
    CONSTRAINT personal_transaction_id_bank_transaction_id
		FOREIGN KEY (personal_transaction_id) REFERENCES bank_transactions (bank_transaction_id)
        ON UPDATE CASCADE,
	CONSTRAINT sender_receiver_transaction_id_bank_transaction_id
		FOREIGN KEY (sender_receiver_transaction_id) REFERENCES bank_transactions (bank_transaction_id)
        ON UPDATE CASCADE
);

CREATE TABLE personal_transaction (
	upi_transaction_id VARCHAR(60) PRIMARY KEY,
    CONSTRAINT personal_transaction_upi_transaction_id
		FOREIGN KEY (upi_transaction_id) REFERENCES upi_transaction (upi_transaction_id)
        ON UPDATE CASCADE
);


CREATE TABLE commercial_transaction (
	upi_transaction_id VARCHAR(60) PRIMARY KEY,
	transaction_fee DOUBLE,
    CONSTRAINT commercial_transaction_upi_transaction_id
		FOREIGN KEY (upi_transaction_id) REFERENCES upi_transaction (upi_transaction_id)
        ON UPDATE CASCADE
);


CREATE TABLE upi_customer (
	ssn VARCHAR(20),
    account_number VARCHAR(20),
    email_id VARCHAR(50),
    pin INT,
    PRIMARY KEY (ssn, account_number),
    CONSTRAINT upi_customer_ssn
		FOREIGN KEY (ssn) REFERENCES individual (ssn)
        ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT upi_customer_account_number
		FOREIGN KEY (account_number) REFERENCES bank_account (account_number)
        ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE consumer (
	ssn VARCHAR(20),
    account_number VARCHAR(20),
    PRIMARY KEY (ssn, account_number),
    CONSTRAINT consumer_primary_key_ssn
		FOREIGN KEY (ssn) REFERENCES upi_customer (ssn)
        ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT consumer_primary_key_account_number
		FOREIGN KEY (account_number) REFERENCES upi_customer (account_number)
        ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE merchant (
	gst_number VARCHAR(30),
    fee_percentage FLOAT,
    building_name VARCHAR(50),
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(6),
    ssn VARCHAR(20),
    account_number VARCHAR(20),
    PRIMARY KEY (ssn, account_number),
    CONSTRAINT merchant_primary_key_ssn
		FOREIGN KEY (ssn) REFERENCES upi_customer (ssn)
        ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT merchant_primary_key_account_number
		FOREIGN KEY (account_number) REFERENCES upi_customer (account_number)
        ON UPDATE CASCADE ON DELETE CASCADE
);
