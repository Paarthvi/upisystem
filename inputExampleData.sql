USE upi_system;

INSERT INTO bank (bank_name, bank_reg_id, routing_number, building_number, street_name, city, state, pin)
	VALUES ("Bank of America", 1, 1, 1, "Bank of America St", "Charlotte", "NC", "00001");
INSERT INTO bank (bank_name, bank_reg_id, routing_number, building_number, street_name, city, state, pin)
	VALUES ("Chase Bank", 2, 2, 2, "Chase Bank St", "New York City", "NJ", "00002");
INSERT INTO bank (bank_name, bank_reg_id, routing_number, building_number, street_name, city, state, pin)
	VALUES ("Santander Bank", 3, 3, 3, "Santander St", "Wyomissing", "PA", "00003");


INSERT INTO branch (branch_id, bank_reg_id, branch_name , building_number ,street_name ,city ,state ,pin)
	VALUES ("00001", 1, "Bank of America Branch 1", 1, "1st Street Boston", "Boston", "MA", "02215");
INSERT INTO branch (branch_id, bank_reg_id, branch_name , building_number ,street_name ,city ,state ,pin)
	VALUES ("00002", 1, "Bank of America Branch 2", 43, "72nd Street Boston", "Boston", "MA", "02217");

INSERT INTO branch (branch_id, bank_reg_id, branch_name , building_number ,street_name ,city ,state ,pin)
	VALUES ("00003", 2, "Chase Bank Branch 1", 143, "Boylston St", "Boston", "MA", "02290");
INSERT INTO branch (branch_id, bank_reg_id, branch_name , building_number ,street_name ,city ,state ,pin)
	VALUES ("00004", 2, "Chase Bank Branch 2", 94, "Park Street", "Boston", "MA", "02235");

INSERT INTO branch (branch_id, bank_reg_id, branch_name , building_number ,street_name ,city ,state ,pin)
	VALUES ("00005", 3, "Santander Bank Branch 1", 56, "Huntington Ave", "Boston", "MA", "02238");
INSERT INTO branch (branch_id, bank_reg_id, branch_name , building_number ,street_name ,city ,state ,pin)
	VALUES ("00006", 3, "Santander Bank Branch 1", 76, "Forysth Street", "Boston", "MA", "02264");



CALL addIndividual('12345601','Gagana','Ananda','18','143 Park St','Boston','MA','02215','8573134855','gagana');
CALL addIndividual('12345602','Glen','Aaron Albert','101','1209 Boylston St','Boston','MA','02215','8573132624','glen');
CALL addIndividual('12345678','Prajwal','Shenoy','44','1209 Boylston St','Boston','MA','02215','9294219425','prajwal');
CALL addIndividual('12345679','Paarthvi','Sharma','18','143 Park St','Boston','MA','02215','9142336508','paarthvi');


SELECT bank_name, branch_id, branch.pin FROM bank JOIN branch ON bank.bank_reg_id = branch.bank_reg_id;
