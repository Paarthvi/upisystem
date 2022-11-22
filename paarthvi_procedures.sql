USE upi_system;
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
	INSERT INTO bank (bank_name, bank_reg_id, routing_number, building_number, street_name, city, state, pin)
    VALUES (bank_name, bank_reg_id, routing_number, building_number, street_name, city, state, pin);
END//
DELIMITER ;



SELECT * FROM bank;

CALL createbank("SBI", 1 , 12345 , 12 , "University Road" , "Jammu", "J&K", "180006");

DROP PROCEDURE IF EXISTS createBankAccount;
DELIMITER //
CREATE PROCEDURE createBankAccount(
ssn VARCHAR(8),
branch_id VARCHAR(5),
account_number VARCHAR(10),
balance DOUBLE)
BEGIN
    IF (checkLength(ssn, 8) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN has to have 8 Character';
	END IF;
    INSERT INTO bank_account (ssn, branch_id, account_number, balance)
    VALUES (ssn, branch_id, account_number, balance);
END//
DELIMITER ;


select * from bank_account;

DROP PROCEDURE IF EXISTS bankTransaction;
DELIMITER //
CREATE PROCEDURE bankTransaction(
account_number_sender VARCHAR(10),
account_number_receiver VARCHAR(10),
amount_to_transfer double)
BEGIN
	IF (checkLength(account_number_sender, 10) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number should be 10 characters';
	END IF;
    IF (checkLength(account_number_receiver, 10) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number should be 10 characters';
	END IF;
    UPDATE bank_account SET amount = (amount + amount_to_transfer) WHERE account_number = account_number_receiver;
    UPDATE bank_account SET amount = (amount - amount_to_transfer) WHERE account_number = account_number_sender;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS withdrawMoneyfromBank;
DELIMITER //
CREATE PROCEDURE withdrawMoneyfromBank(
bank_account_number VARCHAR(10),
amount_to_withdraw double
)
BEGIN
	IF (checkLength(bank_account_number, 10) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number should be 10 characters';
	END IF;
    UPDATE bank_account SET amount = (amount - amount_to_withdraw) WHERE account_number = bank_account_number;
END//
DELIMITER ;
    
   

