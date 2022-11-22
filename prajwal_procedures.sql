USE upi_system;

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
	IF (checkLength(branch_id, 5) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Branch ID should be 5 characters';
	END IF;
	INSERT INTO branch (ssn, first_name, last_name, house_number, street_name, city, state, pin, phone_number)
    VALUES (ssn, first_name, last_name, house_number, street_name, city, state, pin, phone_number);
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
	IF (checkLength(ssn, 8) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN should be 8 characters';
	END IF;
	INSERT INTO upi_customer (ssn, account_number, email_id, pin)
	VALUES (ssn, account_number, email_id, pin);
	INSERT INTO consumer (ssn, account_number)
	VALUES (ssn, account_number);
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
    addressPin VARCHAR(6),
    ssn VARCHAR(20),
    account_number VARCHAR(10))
BEGIN
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
END//
DELIMITER ;
	
	
DROP PROCEDURE IF EXISTS depositeMoneyInBank;
DELIMITER //
CREATE PROCEDURE depositeMoneyInBank(
	account_number VARCHAR(10) PRIMARY KEY,
    amount DOUBLE)
BEGIN
	DECLARE currentBalance DOUBLE DEFAULT 0;
	DECLARE newBalance DOUBLE DEFAULT currentBalance;
	IF (amount < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deposite amount should be greater than 0';
	END IF;
	SELECT balance INTO currentBalance FROM bank_account WHERE account_number IS account_number;
	SET newBalance = currentBalance + amount;
	UPDATE bank_account SET balance = newBalance WHERE account_number = account_number; 
	INSERT INTO bank_transactions ()
END//
DELIMITER ;


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	