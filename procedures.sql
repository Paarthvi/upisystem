use upi_system;
DROP PROCEDURE IF EXISTS addIndividual;
DELIMITER //
CREATE PROCEDURE addIndividual(
	ssn VARCHAR(20),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    house_number VARCHAR(5),
    street_name VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    pin VARCHAR(6),
    phone_number VARCHAR(10))
BEGIN
	IF (checkLength(ssn, 20) != 1) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SSN has to have 20 Character';
	END IF;
	INSERT INTO individual (ssn, first_name, last_name, house_number, street_name, city, state, pin, phone_number)
    VALUES (ssn, first_name, last_name, house_number, street_name, city, state, pin, phone_number);
END//
DELIMITER ;

SELECT * FROM individual;
CALL addIndividual("00000000001234567890", "Paarthvi", "Sharma", "18", "143 Park Drive", "Boston", "MA", "02215", "9142336508");


DROP function if exists checkLength;
DELIMITER //
CREATE FUNCTION checkLength(word VARCHAR(1000), length INT)
RETURNS BOOL
DETERMINISTIC READS SQL DATA
BEGIN
	RETURN IF(LENGTH(word)=length, True, False);
END//
DELIMITER ;