use upi_system;


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
	IF (checkLength(ssn, 8) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN has to have 8 Character';
	END IF;
	IF (checkLength(phone_number, 10) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The phone number should be 10 digits only';
	END IF;
	INSERT INTO individual (ssn, first_name, last_name, house_number, street_name, city, state, pin, phone_number, login_password)
    VALUES (ssn, first_name, last_name, house_number, street_name, city, state, pin, phone_number, MD5(login_password));
END//
DELIMITER ;

USE upi_system;
SELECT * FROM individual;
CALL addIndividual("12345678", "Prajwal", "Shenoy", "44", "1209 Boylston St", "Boston", "MA", "02215", "9294219425", "12345");
CALL addIndividual("12345679", "Paarthvi", "Sharma", "18", "143 Park Drive", "Boston", "MA", "02215", "9142336508", "123456");

DROP function if exists checkLength;
DELIMITER //
CREATE FUNCTION checkLength(word VARCHAR(1000), length INT)
RETURNS BOOL
DETERMINISTIC READS SQL DATA
BEGIN
	RETURN IF(LENGTH(word)=length, True, False);
END//
DELIMITER ;