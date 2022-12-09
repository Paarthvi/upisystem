USE upi_system;

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
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Could not register individual';
		END;
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
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Could not register new branch';
		END;
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
	email_id VARCHAR(50))
BEGIN
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Could not register consumer to UPI';
		END;
	START TRANSACTION;
	IF (checkLength(ssn, 8) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN should be 8 characters';
	END IF;
	INSERT INTO upi_customer (ssn, account_number, email_id)
		VALUES (ssn, account_number, email_id);
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
	gst_number VARCHAR(10),
    fee_percentage FLOAT,
    building_name VARCHAR(50),
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    addressPin VARCHAR(6))
BEGIN
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Could not register merchant to UPI';
		END;
	START TRANSACTION;
	IF (checkLength(ssn, 8) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN should be 8 characters';
	END IF;
	IF (fee_percentage < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fee_percentage should be a greater than or equal to 0';
	END IF;

	INSERT INTO upi_customer (ssn, account_number, email_id)
		VALUES (ssn, account_number, email_id);
	INSERT INTO merchant (gst_number, fee_percentage, building_name, street_name, city, state, pin, ssn, account_number)
		VALUES (gst_number, fee_percentage, building_name, street_name, city, state, addressPin, ssn, account_number);
	COMMIT;
END//
DELIMITER ;
	
	
DROP PROCEDURE IF EXISTS depositeMoneyInBank;
DELIMITER //
CREATE PROCEDURE depositeMoneyInBank(
	selected_account_number VARCHAR(10),
    amount DOUBLE,
    date_of_transaction DATE)
BEGIN
	DECLARE currentBalance DOUBLE DEFAULT 0;
	DECLARE newBalance DOUBLE DEFAULT currentBalance;
	DECLARE fetched_branch_id VARCHAR(5);
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Could not deposite money into bank account';
		END;
	START TRANSACTION;
	IF (checkLength(selected_account_number, 10) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number should be 10 digits long';
	END IF;
	IF (amount < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deposite amount should be greater than 0';
	END IF;
	IF (SELECT COUNT(account_number) != 1 FROM bank_account WHERE account_number = selected_account_number) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number is invalid';
	END IF;
	SELECT balance INTO currentBalance FROM bank_account WHERE account_number = selected_account_number;
	SET newBalance = currentBalance + amount;
	UPDATE bank_account SET balance = newBalance WHERE account_number = selected_account_number;
	SELECT branch_id INTO fetched_branch_id FROM bank_account WHERE account_number = selected_account_number;
	INSERT INTO bank_transactions (SELECT incrementNextTransactionId(fetched_branch_id), "CREDIT", 
		selected_account_number, "InPerDepos", date_of_transaction, amount, "In person deposit", newBalance);
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

DROP FUNCTION IF EXISTS incrementUPITransactionId;
DELIMITER //
CREATE FUNCTION incrementUPITransactionId()
RETURNS CHAR(10)
NOT DETERMINISTIC READS SQL DATA
BEGIN
	DECLARE current_transaction_id INT;
	IF (SELECT COUNT(upi_transaction_id) > 0 FROM upi_transaction) THEN
		SELECT CAST(upi_transaction_id AS UNSIGNED) INTO current_transaction_id FROM upi_transaction ORDER BY upi_transaction_id DESC LIMIT 1;
		SET current_transaction_id = current_transaction_id + 1;
		return right(CONCAT('0000000000', cast(current_transaction_id as char(10))), 10);
	ELSE
		return '0000000001';
	END IF;
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
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Could not register new bank';
		END;
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
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Could not register new bank account';
		END;
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
        amount_to_transfer double,
		date_of_transaction DATE,
        message VARCHAR(50))
BEGIN
	DECLARE source_branch_id VARCHAR(5);
	DECLARE desination_branch_id VARCHAR(5);
	DECLARE sender_old_balance DOUBLE;
	DECLARE receiver_old_balance DOUBLE;
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Could not complete bank to bank transaction';
		END;
	START TRANSACTION;
	IF (checkLength(account_number_sender, 10) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sender Account number should be 10 characters';
	END IF;
	IF (checkLength(account_number_receiver, 10) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Receiver Account number should be 10 digits long';
	END IF;
	IF (amount_to_transfer < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction amount should be greater than 0';
	END IF;
	IF (SELECT COUNT(account_number_receiver) != 1 FROM bank_account WHERE account_number = account_number_receiver) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Receiver Account number is invalid';
	END IF;
	IF (SELECT COUNT(account_number_sender) != 1 FROM bank_account WHERE account_number = account_number_sender) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sender Account number is invalid';
	END IF;
	SELECT branch_id INTO source_branch_id FROM bank_account WHERE account_number = account_number_sender;
	SELECT branch_id INTO desination_branch_id FROM bank_account WHERE account_number = account_number_receiver;
	SELECT balance INTO sender_old_balance FROM bank_account WHERE account_number = account_number_sender;
	SELECT balance INTO receiver_old_balance FROM bank_account WHERE account_number = account_number_receiver;
    UPDATE bank_account SET balance = (receiver_old_balance + amount_to_transfer) WHERE account_number = account_number_receiver;
    UPDATE bank_account SET balance = (sender_old_balance - amount_to_transfer) WHERE account_number = account_number_sender;
    INSERT INTO bank_transactions (SELECT incrementNextTransactionId(source_branch_id), "DEBIT", 
		account_number_sender, account_number_receiver, date_of_transaction, amount_to_transfer, message, sender_old_balance - amount_to_transfer);
	INSERT INTO bank_transactions (SELECT incrementNextTransactionId(desination_branch_id), "CREDIT", 
		account_number_receiver, account_number_sender, date_of_transaction, amount_to_transfer, message, receiver_old_balance + amount_to_transfer);
	COMMIT;
END//
DELIMITER ;

DROP FUNCTION IF EXISTS isMerchant;
DELIMITER //
CREATE FUNCTION isMerchant(selectedEmailId VARCHAR(50))
RETURNS BOOLEAN
NOT DETERMINISTIC READS SQL DATA
BEGIN
	DECLARE to_return BOOLEAN;
	SET to_return = 0;
	IF (SELECT COUNT(email_id) = 1 as joinedTable FROM upi_customer JOIN merchant WHERE upi_customer.account_number = merchant.account_number) THEN
		SET to_return = 1;
	END IF;
	return to_return;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS makeUpiTransaction;
DELIMITER //
CREATE PROCEDURE makeUpiTransaction(
	fromEmailId VARCHAR(50),
	toEmailId VARCHAR(50),
	amount_to_transfer DOUBLE,
	transaction_date DATE)
BEGIN
	DECLARE account_number_sender VARCHAR(10);
    DECLARE account_number_receiver VARCHAR(10);
	DECLARE actual_amount_to_transfer DOUBLE;
	DECLARE commission_fee DOUBLE;
	DECLARE sender_bank_transaction_id VARCHAR(10);
	DECLARE receiver_bank_transaction_id VARCHAR(10);
	DECLARE upi_transaction_id VARCHAR(10);
	DECLARE updated_balance_receiver DOUBLE;
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Could not complete UPI transaction';
		END;
	START TRANSACTION;
	IF (checkIfEmailIfPresentAsUPICustomer(fromEmailId) = 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'From email ID is not registered with UPI';
	END IF;
	SELECT account_number INTO account_number_sender FROM upi_customer WHERE email_id = fromEmailId;
	IF (checkIfEmailIfPresentAsUPICustomer(toEmailId) = 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'To email ID is not registered with UPI';
	END IF;
	SELECT account_number INTO account_number_receiver FROM upi_customer WHERE email_id = toEmailId;
	IF (amount_to_transfer < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction amount should be greater than 0';
	END IF;
	SET actual_amount_to_transfer = amount_to_transfer;
	SELECT incrementUPITransactionId() INTO upi_transaction_id;
	IF (isMerchant(toEmailId)) THEN
		SET commission_fee = (amount_to_transfer * (SELECT fee_percentage FROM merchant WHERE account_number = account_number_receiver)) / 100;
		SET actual_amount_to_transfer = amount_to_transfer - commission_fee;
		CALL bankTransaction(account_number_sender, account_number_receiver, amount_to_transfer, transaction_date, "UPI transaction");
		SELECT balance INTO updated_balance_receiver FROM bank_account WHERE account_number = account_number_receiver;
		SET updated_balance_receiver = updated_balance_receiver - commission_fee;
		UPDATE bank_account SET balance = updated_balance_receiver WHERE account_number = account_number_receiver;
		SELECT bank_transaction_id INTO receiver_bank_transaction_id FROM bank_transactions WHERE personal_account_details = account_number_receiver ORDER BY bank_transaction_id DESC LIMIT 1;
		SELECT bank_transaction_id INTO sender_bank_transaction_id FROM bank_transactions WHERE personal_account_details = account_number_sender ORDER BY bank_transaction_id DESC LIMIT 1;
		UPDATE bank_transactions SET transaction_value = actual_amount_to_transfer WHERE bank_transaction_id = receiver_bank_transaction_id;
		UPDATE bank_transactions SET new_balance = updated_balance_receiver WHERE bank_transaction_id = receiver_bank_transaction_id;
		INSERT INTO upi_transaction (upi_transaction_id, sender_receiver_transaction_id, transaction_date, personal_transaction_id) VALUES
			(upi_transaction_id, receiver_bank_transaction_id, transaction_date, sender_bank_transaction_id);
		INSERT INTO commercial_transaction (upi_transaction_id, transaction_fee) VALUES (upi_transaction_id, commission_fee);
	ELSE
		CALL bankTransaction(account_number_sender, account_number_receiver, amount_to_transfer, transaction_date, "UPI transaction");
		SELECT bank_transaction_id INTO receiver_bank_transaction_id FROM bank_transactions WHERE personal_account_details = account_number_receiver ORDER BY bank_transaction_id DESC LIMIT 1;
		SELECT bank_transaction_id INTO sender_bank_transaction_id FROM bank_transactions WHERE personal_account_details = account_number_sender ORDER BY bank_transaction_id DESC LIMIT 1;
		INSERT INTO upi_transaction (upi_transaction_id, sender_receiver_transaction_id, transaction_date, personal_transaction_id) VALUES
			(upi_transaction_id, receiver_bank_transaction_id, transaction_date, sender_bank_transaction_id);
		INSERT INTO personal_transaction (upi_transaction_id) VALUES (upi_transaction_id);
	END IF;
	COMMIT;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS checkIfEmailIfPresentAsUPICustomer;
DELIMITER //
CREATE FUNCTION checkIfEmailIfPresentAsUPICustomer(selectedEmailId VARCHAR(50))
RETURNS BOOLEAN
NOT DETERMINISTIC READS SQL DATA
BEGIN
	DECLARE to_return BOOLEAN;
	SET to_return = 0;
	IF (SELECT COUNT(email_id) = 1 FROM upi_customer WHERE email_id = selectedEmailId) THEN
		SET to_return = 1;
	END IF;
	return to_return;
END//
DELIMITER ;

DROP FUNCTION IF EXISTS checkIfEmailBelongsToSSN;
DELIMITER //
CREATE FUNCTION checkIfEmailBelongsToSSN(selected_ssn VARCHAR(8), selectedEmailId VARCHAR(50))
RETURNS BOOLEAN
NOT DETERMINISTIC READS SQL DATA
BEGIN
	DECLARE to_return BOOLEAN;
	SET to_return = 0;
	IF (SELECT COUNT(email_id) = 1 FROM upi_customer WHERE email_id = selectedEmailId AND ssn = selected_ssn) THEN
		SET to_return = 1;
	END IF;
	return to_return;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS withdrawMoneyfromBank;
DELIMITER //
CREATE PROCEDURE withdrawMoneyfromBank(
	   selected_account_number VARCHAR(10),
       amount DOUBLE,
       date_of_transaction DATE)
BEGIN
	DECLARE fetched_branch_id VARCHAR(5);
	DECLARE new_balance DOUBLE;
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Could not withdraw money from bank account';
		END;
	START TRANSACTION;
	IF (checkLength(selected_account_number, 10) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number should be 10 digits long';
	END IF;
	IF (amount < 0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Withdrawal amount should be greater than 0';
	END IF;
	IF (SELECT COUNT(account_number) != 1 FROM bank_account WHERE account_number = selected_account_number) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number is invalid';
	END IF;
	IF (SELECT balance < amount FROM bank_account WHERE account_number = selected_account_number) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
	END IF;
	SELECT balance INTO new_balance FROM bank_account WHERE account_number = selected_account_number;
	SET new_balance = new_balance - amount;
    UPDATE bank_account SET balance = new_balance WHERE account_number = selected_account_number;
   	SELECT branch_id INTO fetched_branch_id FROM bank_account WHERE account_number = selected_account_number;
	INSERT INTO bank_transactions (SELECT incrementNextTransactionId(fetched_branch_id), "DEBIT", 
		selected_account_number, "InPerWithd", date_of_transaction, amount, "In person withdrawal", new_balance);
	COMMIT;
END//
DELIMITER ;
    
   

DROP FUNCTION IF EXISTS checkIfAccountBelongsToSSN;
DELIMITER //
CREATE FUNCTION checkIfAccountBelongsToSSN(selected_ssn VARCHAR(8), selected_bank_account VARCHAR(10))
RETURNS BOOLEAN
NOT DETERMINISTIC READS SQL DATA
BEGIN
	DECLARE to_return BOOLEAN;
	SET to_return = 0;
	IF (checkLength(selected_ssn, 8) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN should be 8 characters long';
	END IF;
	IF (checkLength(selected_bank_account, 10) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number should be 10 digits long';
	END IF;
	IF (SELECT COUNT(ssn) = 1 FROM bank_account WHERE ssn = selected_ssn AND account_number = selected_bank_account) THEN
		SET to_return = 1;
	END IF;
	return to_return;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS viewAccountDetails;
DELIMITER //
CREATE PROCEDURE viewAccountDetails(
	fetched_ssn VARCHAR(8))
BEGIN
	IF (checkLength(fetched_ssn, 8) != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN should be 8 digits long';
	END IF;
	IF (SELECT COUNT(account_number) FROM bank_account WHERE account_number = account_number != 1) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No accounts associated with this SSN';
	END IF;
   	SELECT bank_name, branch.branch_id, account_number, balance, branch.building_number, branch.street_name, branch.city, branch.pin 
	FROM bank_account 
    JOIN branch ON  bank_account.branch_id = branch.branch_id
    JOIN bank ON bank.bank_reg_id = branch.bank_reg_id where ssn = fetched_ssn;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS viewTransaction;
DELIMITER //
CREATE PROCEDURE viewTransaction(
	fetched_accountNumber VARCHAR(10))
BEGIN
	SELECT * from bank_transactions where personal_account_details = fetched_accountNumber;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS viewUPITransaction;
DELIMITER //
CREATE PROCEDURE viewUPITransaction(
	fetched_emailID VARCHAR(50))
BEGIN
	SELECT upi_transaction_id, balance, bank_transactions.* from upi_customer
	JOIN bank_account ON upi_customer.account_number = bank_account.account_number
	JOIN bank_transactions ON bank_account.account_number = bank_transactions.personal_account_details
	JOIN upi_transaction ON bank_transactions.bank_transaction_id  =  upi_transaction.personal_transaction_id 
	OR bank_transactions.bank_transaction_id  =  upi_transaction.sender_receiver_transaction_id
	where email_id = fetched_emailID ;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS deleteBankAccount;
DELIMITER //
CREATE PROCEDURE deleteBankAccount(selectedBankAccount VARCHAR(10))
BEGIN
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
		BEGIN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Could not remove bank account from records';
		END;
	START TRANSACTION;
	DELETE FROM bank_account WHERE account_number = selectedBankAccount;
	COMMIT;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS viewUPIConsumerDetailsForSSN;
DELIMITER //
CREATE PROCEDURE viewUPIConsumerDetailsForSSN(fetched_ssn VARCHAR(50))
BEGIN
	select consumer.account_number, email_id from upi_customer
		JOIN consumer on consumer.account_number = upi_customer.account_number where upi_customer.ssn = fetched_ssn;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS viewUPIMerchantDetailsForSSN;
DELIMITER //
CREATE PROCEDURE viewUPIMerchantDetailsForSSN(fetched_ssn VARCHAR(50))
BEGIN
	SELECT merchant.account_number, email_id, gst_number, fee_percentage FROM merchant 
		JOIN upi_customer ON merchant.account_number = upi_customer.account_number where upi_customer.ssn = fetched_ssn;
END//
DELIMITER ;
