USE upi_system;
-- SET GLOBAL log_bin_trust_function_creators = 1;
-- The above command has to be set;

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
	account_number VARCHAR(10),
    amount DOUBLE,
    date_of_transaction DATE)
BEGIN
	DECLARE currentBalance DOUBLE DEFAULT 0;
	DECLARE newBalance DOUBLE DEFAULT currentBalance;
	DECLARE fetched_branch_id VARCHAR(5);
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
END//
DELIMITER ;

SELECT * FROM bank_transactions;
SELECT * FROM bank_account;
SELECT * FROM branch;

-- USE upi_system;
-- SELECT * FROM branch_transaction_id;
-- SELECT * FROM branch;
-- INSERT INTO branch_transaction_id (branch_id, next_transaction) VALUES ("SBI01", right(CONCAT('00000', cast(1 as char(5))), 5));
-- 
-- UPDATE branch_transaction_id SET next_transaction = CONCAT("SBI01", right(CONCAT('00000', cast(1 as char(5))), 5)) WHERE branch_id = "SBI01";
-- SELECT CAST(next_transaction AS UNSIGNED) as col FROM branch_transaction_id WHERE branch_id = "SBI01";
-- -- right('00000' + cast(Your_Field as varchar(5)), 5);
-- DELETE FROM branch_transaction_id WHERE branch_id = "SBI01";
-- 
-- SELECT * FROM branch_transaction_id WHERE branch_id = "SBI01";
-- SELECT incrementNextTransactionId("SBI01");

-- DROP PROCEDURE IF EXISTS incrementNextTransactionId;
-- DELIMITER //
-- CREATE PROCEDURE incrementNextTransactionId(selected_branch_id VARCHAR(5))
-- BEGIN
-- 	DECLARE current_transaction_id INT;
-- 	IF (SELECT COUNT(branch_id) FROM branch_transaction_id WHERE branch_id = selected_branch_id = 1) THEN
-- 		SELECT CAST(RIGHT(next_transaction, 5) AS UNSIGNED) INTO current_transaction_id FROM branch_transaction_id WHERE branch_id = selected_branch_id;
-- 		SET current_transaction_id = current_transaction_id + 1;
-- 		UPDATE branch_transaction_id SET next_transaction = CONCAT(selected_branch_id, 
-- 			right(CONCAT('00000', cast(current_transaction_id as char(5))), 5)) 
-- 			WHERE branch_id = selected_branch_id;
-- 	ELSE
-- 		IF (SELECT COUNT(branch_id) FROM branch WHERE branch_id = selected_branch_id = 1) THEN
-- 			INSERT INTO branch_transaction_id (branch_id, next_transaction) VALUES (selected_branch_id, 
-- 				CONCAT(selected_branch_id, right(CONCAT('00000', cast(1 as char(5))), 5)));
-- 		ELSE
-- 			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Branch ID is invalid';
-- 		END IF;
-- 	END IF;
-- END//
-- DELIMITER ;

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

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	