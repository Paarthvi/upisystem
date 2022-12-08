DROP DATABASE IF EXISTS upi_system;
CREATE DATABASE upi_system;

USE upi_system;

CREATE TABLE individual (
	ssn VARCHAR(8)  PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    house_number VARCHAR(5),
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(5),
    phone_number VARCHAR(10) UNIQUE,
    login_password VARCHAR(255)
);

CREATE TABLE bank (
	bank_name VARCHAR(50) UNIQUE,
    bank_reg_id INT PRIMARY KEY,
    routing_number INT UNIQUE,
    building_number INT,
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(5)
);


CREATE TABLE branch (
	branch_id VARCHAR(5) PRIMARY KEY,
    bank_reg_id INT,
    branch_name VARCHAR(50),
    building_number INT,
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(5),
    CONSTRAINT branch_bank_reg_id 
		FOREIGN KEY (bank_reg_id) REFERENCES bank (bank_reg_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE bank_account (
	ssn VARCHAR(8),
	branch_id VARCHAR(5),
	account_number VARCHAR(10) PRIMARY KEY,
    balance DOUBLE,
    CONSTRAINT bank_account_branch_id 
		FOREIGN KEY (branch_id) REFERENCES branch (branch_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT bank_account_ssn
		FOREIGN KEY (ssn) REFERENCES individual (ssn)
        ON UPDATE CASCADE ON DELETE CASCADE
);
    
    
CREATE TABLE bank_transactions (
	bank_transaction_id VARCHAR(10) PRIMARY KEY,
    transaction_type ENUM('DEBIT', 'CREDIT'),
    personal_account_details VARCHAR(10),
    sender_receiver_account_details VARCHAR(10),
    transaction_date DATE,
    transaction_value DOUBLE,
    transaction_message VARCHAR(100),
    CONSTRAINT bank_transactions_account_number
		FOREIGN KEY (personal_account_details) REFERENCES bank_account (account_number)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE upi_transaction (
	upi_transaction_id VARCHAR(10) PRIMARY KEY,
    sender_receiver_transaction_id VARCHAR(10),
    transaction_date DATE,
    personal_transaction_id VARCHAR(10),
    CONSTRAINT personal_transaction_id_bank_transaction_id
		FOREIGN KEY (personal_transaction_id) REFERENCES bank_transactions (bank_transaction_id)
        ON UPDATE CASCADE,
	CONSTRAINT sender_receiver_transaction_id_bank_transaction_id
		FOREIGN KEY (sender_receiver_transaction_id) REFERENCES bank_transactions (bank_transaction_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE personal_transaction (
	upi_transaction_id VARCHAR(10) PRIMARY KEY,
    CONSTRAINT personal_transaction_upi_transaction_id
		FOREIGN KEY (upi_transaction_id) REFERENCES upi_transaction (upi_transaction_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE commercial_transaction (
	upi_transaction_id VARCHAR(10) PRIMARY KEY,
	transaction_fee DOUBLE,
    CONSTRAINT commercial_transaction_upi_transaction_id
		FOREIGN KEY (upi_transaction_id) REFERENCES upi_transaction (upi_transaction_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE upi_customer (
	ssn VARCHAR(8),
    account_number VARCHAR(10),
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
	ssn VARCHAR(8),
    account_number VARCHAR(10),
    PRIMARY KEY (ssn, account_number),
    CONSTRAINT consumer_primary_key_ssn
		FOREIGN KEY (ssn) REFERENCES upi_customer (ssn)
        ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT consumer_primary_key_account_number
		FOREIGN KEY (account_number) REFERENCES upi_customer (account_number)
        ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE merchant (
	gst_number VARCHAR(10),
    fee_percentage FLOAT,
    building_name VARCHAR(50),
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(5),
    ssn VARCHAR(20),
    account_number VARCHAR(10),
    PRIMARY KEY (ssn, account_number),
    CONSTRAINT merchant_primary_key_ssn
		FOREIGN KEY (ssn) REFERENCES upi_customer (ssn)
        ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT merchant_primary_key_account_number
		FOREIGN KEY (account_number) REFERENCES upi_customer (account_number)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE branch_transaction_id ( 
	branch_id VARCHAR(5) PRIMARY KEY,
	next_transaction VARCHAR(10),
	CONSTRAINT branch_transaction_id_branch_id
		FOREIGN KEY (branch_id) REFERENCES branch (branch_id)
		ON UPDATE CASCADE ON DELETE CASCADE
);

DROP PROCEDURE IF EXISTS addIndividual;
DELIMITER //
CREATE PROCEDURE addIndividual(
	ssn VARCHAR(8),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    house_number VARCHAR(5),
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(6),
    phone_number VARCHAR(10),
    login_password VARCHAR(255))
BEGIN
	START TRANSACTION;
	IF (checkLength(ssn, 8) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN should be 8 characters';
	END IF;
	IF (checkLength(pin, 5) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PIN should be 5 characters';
	END IF;
	IF (checkLength(phone_number, 10) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The phone number should be 10 digits only';
	END IF;
	INSERT INTO individual (ssn, first_name, last_name, house_number, street_name, city, state, pin, phone_number, login_password)
    VALUES (ssn, first_name, last_name, house_number, street_name, city, state, pin, phone_number, MD5(login_password));
    COMMIT;
END//
DELIMITER ;


DROP function if exists checkLength;
DELIMITER //
CREATE FUNCTION checkLength(word VARCHAR(1000), length INT)
RETURNS BOOL
DETERMINISTIC READS SQL DATA
BEGIN
	RETURN IF(LENGTH(word)=length, True, False);
END//
DELIMITER ;

DROP function if exists verifyPassword;
DELIMITER //
CREATE FUNCTION verifyPassword(phone_num VARCHAR(10), pass VARCHAR(255))
RETURNS BOOL
DETERMINISTIC READS SQL DATA
BEGIN
	DECLARE fetched_password VARCHAR(255);
	SELECT login_password INTO fetched_password FROM individual WHERE phone_number = phone_num;
	RETURN IF(fetched_password = MD5(pass), True, False);
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS createBranch;
DELIMITER //
CREATE PROCEDURE createBranch(
	branch_id VARCHAR(5),
	branch_name VARCHAR(50),
    bank_name VARCHAR(50),
    building_number INT,
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(6))
BEGIN
	START TRANSACTION;
	IF (checkLength(branch_id, 5) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Branch ID should be 5 characters';
	END IF;
	INSERT INTO branch (ssn, first_name, last_name, house_number, street_name, city, state, pin, phone_number)
    VALUES (ssn, first_name, last_name, house_number, street_name, city, state, pin, phone_number);
   COMMIT;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS registerForUPIConsumer;
DELIMITER //
CREATE PROCEDURE registerForUPIConsumer(
	ssn VARCHAR(8),
	account_number VARCHAR(10),
	email_id VARCHAR(50),
	pin INT)
BEGIN
	START TRANSACTION;
	IF (checkLength(ssn, 8) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN should be 8 characters';
	END IF;
	INSERT INTO upi_customer (ssn, account_number, email_id, pin)
	VALUES (ssn, account_number, email_id, pin);
	INSERT INTO consumer (ssn, account_number)
	VALUES (ssn, account_number);
	COMMIT;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS registerForUPIMerchant;
DELIMITER //
CREATE PROCEDURE registerForUPIMerchant(
	ssn VARCHAR(8),
	account_number VARCHAR(10),
	email_id VARCHAR(50),
	pin INT,
	gst_number VARCHAR(10),
    fee_percentage FLOAT,
    building_name VARCHAR(50),
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    addressPin VARCHAR(6))
BEGIN
	START TRANSACTION;
	IF (checkLength(ssn, 8) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN should be 8 characters';
	END IF;
	IF (fee_percentage < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fee_percentage should be a greater than or equal to 0';
	END IF;

	INSERT INTO upi_customer (ssn, account_number, email_id, pin)
	VALUES (ssn, account_number, email_id, pin);
	INSERT INTO merchant (gst_number, fee_percentage, building_name, street_name, city, state, addressPin, ssn, account_number)
	VALUES (gst_number, fee_percentage, building_name, street_name, city, state, addressPin, ssn, account_number);
	COMMIT;
END//
DELIMITER ;
	
	
DROP PROCEDURE IF EXISTS depositeMoneyInBank;
DELIMITER //
CREATE PROCEDURE depositeMoneyInBank(
	account_number VARCHAR(10),
    amount DOUBLE,
    date_of_transaction DATE)
BEGIN
	DECLARE currentBalance DOUBLE DEFAULT 0;
	DECLARE newBalance DOUBLE DEFAULT currentBalance;
	DECLARE fetched_branch_id VARCHAR(5);
	START TRANSACTION;
	IF (checkLength(account_number, 10) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number should be 10 digits long';
	END IF;
	IF (amount < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deposite amount should be greater than 0';
	END IF;
	IF (SELECT COUNT(account_number) FROM bank_account WHERE account_number = account_number != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number is invalid';
	END IF;
	SELECT balance INTO currentBalance FROM bank_account WHERE account_number = account_number;
	SET newBalance = currentBalance + amount;
	UPDATE bank_account SET balance = newBalance WHERE account_number = account_number;
	SELECT branch_id INTO fetched_branch_id FROM bank_account WHERE account_number = account_number;
	INSERT INTO bank_transactions (SELECT incrementNextTransactionId(fetched_branch_id), "CREDIT", 
		account_number, "InPerDepos", date_of_transaction, amount, "In person deposit");
	COMMIT;
END//
DELIMITER ;


DROP FUNCTION IF EXISTS incrementNextTransactionId;
DELIMITER //
CREATE FUNCTION incrementNextTransactionId(selected_branch_id VARCHAR(5))
RETURNS CHAR(10)
NOT DETERMINISTIC MODIFIES SQL DATA
BEGIN
	DECLARE to_return CHAR(10);
	DECLARE current_transaction_id INT;
	IF (SELECT COUNT(branch_id) FROM branch_transaction_id WHERE branch_id = selected_branch_id = 1) THEN
		SELECT CAST(RIGHT(next_transaction, 5) AS UNSIGNED) INTO current_transaction_id FROM branch_transaction_id WHERE branch_id = selected_branch_id;
		SET current_transaction_id = current_transaction_id + 1;
		UPDATE branch_transaction_id SET next_transaction = CONCAT(selected_branch_id, 
			right(CONCAT('00000', cast(current_transaction_id as char(5))), 5)) 
			WHERE branch_id = selected_branch_id;
		SELECT next_transaction INTO to_return FROM branch_transaction_id WHERE branch_id = selected_branch_id;
	ELSE
		IF (SELECT COUNT(branch_id) FROM branch WHERE branch_id = selected_branch_id = 1) THEN
			INSERT INTO branch_transaction_id (branch_id, next_transaction) VALUES (selected_branch_id, 
				CONCAT(selected_branch_id, right(CONCAT('00000', cast(1 as char(5))), 5)));
			SELECT next_transaction INTO to_return FROM branch_transaction_id WHERE branch_id = selected_branch_id;
		ELSE
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Branch ID is invalid';
		END IF;
	END IF;
	RETURN to_return;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS createBank;
DELIMITER //
CREATE PROCEDURE createBank(
	bank_name VARCHAR(50),
    bank_reg_id INT,
    routing_number INT,
    building_number INT,
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(6))
BEGIN
	START TRANSACTION;
	INSERT INTO bank (bank_name, bank_reg_id, routing_number, building_number, street_name, city, state, pin)
    VALUES (bank_name, bank_reg_id, routing_number, building_number, street_name, city, state, pin);
    COMMIT;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS createBankAccount;
DELIMITER //
CREATE PROCEDURE createBankAccount(
ssn VARCHAR(8),
branch_id VARCHAR(5),
account_number VARCHAR(10),
balance DOUBLE,
date_of_creation DATE)
BEGIN
	START TRANSACTION;
    IF (checkLength(ssn, 8) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN has to have 8 Character';
	END IF;
	IF (checkLength(branch_id, 5) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Branch ID is invalid';
	END IF;
	IF (checkLength(account_number, 10) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number should be 10 digits';
	END IF;
	IF (balance < 0) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deposite money cannot be negative';
	END IF;
    INSERT INTO bank_account (ssn, branch_id, account_number, balance) VALUES (ssn, branch_id, account_number, 0);
   	CALL depositeMoneyInBank(account_number, balance, date_of_creation);
    COMMIT;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS bankTransaction;
DELIMITER //
CREATE PROCEDURE bankTransaction(
        account_number_sender VARCHAR(10),
        account_number_receiver VARCHAR(10),
        amount_to_transfer double)
BEGIN
	START TRANSACTION;
	IF (checkLength(account_number_sender, 10) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number should be 10 characters';
	END IF;
    UPDATE bank_account SET amount = (amount + amount_to_transfer) WHERE account_number = account_number_receiver;
    UPDATE bank_account SET amount = (amount - amount_to_transfer) WHERE account_number = account_number_sender;
    COMMIT;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS withdrawMoneyfromBank;
DELIMITER //
CREATE PROCEDURE withdrawMoneyfromBank(
	account_number VARCHAR(10),
       amount DOUBLE,
       date_of_transaction DATE)
BEGIN
	DECLARE fetched_branch_id VARCHAR(5);
	START TRANSACTION;
	IF (checkLength(account_number, 10) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number should be 10 digits long';
	END IF;
	IF (amount < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Withdrawal amount should be greater than 0';
	END IF;
	IF (SELECT COUNT(account_number) FROM bank_account WHERE account_number = account_number != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number is invalid';
	END IF;
	IF (SELECT balance < amount FROM bank_account WHERE account_number = account_number) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
	END IF;
    UPDATE bank_account SET balance = (balance - amount) WHERE account_number = account_number;
   	SELECT branch_id INTO fetched_branch_id FROM bank_account WHERE account_number = account_number;
	INSERT INTO bank_transactions (SELECT incrementNextTransactionId(fetched_branch_id), "DEBIT", 
		account_number, "InPerWithd", date_of_transaction, amount, "In person withdrawal");
	COMMIT;
END//
DELIMITER ;
    
   

