-- ============================================ --
-- |        Created on January 2023           | --
-- |  Copyrigth (c) 2023 ISRAEL SANCHEZ       | --
-- |          All rights reserved             | --
-- ============================================ --
-- | Query to do operations on the database   | --
-- ============================================ --

-- Create a donor
DROP PROCEDURE IF EXISTS CreateDonor;
DELIMITER //
CREATE PROCEDURE CreateDonor (
    IN _jsonA JSON
)
BEGIN
    DECLARE _json JSON;
    DECLARE _idUsuario INT;
    DECLARE name CHAR(100);
    DECLARE city CHAR(100);
    DECLARE colony CHAR(100);
    DECLARE organization CHAR(100);
    DECLARE website1 CHAR(100);
    DECLARE website2 CHAR(100);
    DECLARE cfdi CHAR(100);
    DECLARE category INT;

    DECLARE types JSON;
    DECLARE tempType INT;
    DECLARE _count INT DEFAULT 0;
    DECLARE _index INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            SELECT 'ERROR!' AS 'RESULT';

            ROLLBACK;
        END ;

    SET _json = JSON_EXTRACT(_jsonA, '$[0]');
    SET name = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.name'));
    SET city = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.city'));
    SET colony = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.colony'));
    SET organization = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.organization'));
    SET website1 = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.website1'));
    SET website2 = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.website2'));
    SET cfdi = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.cfdi'));
    SET category = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.category'));
    SET types = JSON_EXTRACT(_json, '$.type');

    SET _count = JSON_LENGTH(types) - 1;

    START TRANSACTION ;
        IF (cfdi = 'null') THEN
            INSERT INTO Donor VALUES (0, name, city, colony, organization, website1, website2, null);
        ELSE
            INSERT INTO Donor VALUES (0, name, city, colony, organization, website1, website2, cfdi);
        END IF;

        SELECT LAST_INSERT_ID() INTO _idUsuario;
        IF((SELECT ROW_COUNT()) = 0) THEN
            SELECT CONCAT('No se pudo insertar el usuario') as 'STATUS';
            ROLLBACK ;
        END IF;

        INSERT INTO DonorCategory VALUES (_idUsuario, category);
        IF((SELECT ROW_COUNT()) = 0) THEN
            SELECT CONCAT('No se pudo agregar la categoria') as 'STATUS';
            ROLLBACK ;
        END IF;

        WHILE _count >= 0 DO
            SET _json = JSON_EXTRACT(types, CONCAT('$[',_index,']'));
            SET _index = _index + 1;
            SET tempType = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.id'));
            INSERT INTO DonorType VALUES (_idUsuario, tempType);
            IF((SELECT ROW_COUNT()) = 0) THEN
                SELECT CONCAT('No se pudo agregar el tipo') as 'STATUS';
                ROLLBACK ;
            END IF;
            SET _count = _count -1;
        END WHILE ;
    COMMIT ;
    SELECT 'SUCCESS' AS 'RESULT';


END //

DELIMITER ;

-- Get all donors
DROP PROCEDURE IF EXISTS GetDonors;
DELIMITER //
CREATE PROCEDURE GetDonors()
BEGIN
    SELECT Donor.donor_id, donor_name, donor_city, donor_colony, donor_organization, donor_website1, donor_website2, donor_cfdi, GROUP_CONCAT(DISTINCT product_id) as 'Donations', GROUP_CONCAT(DISTINCT type_id) as "Tipo", category_id
	FROM Donor
    LEFT JOIN DonorCategory DC ON Donor.donor_id = DC.donor_id
    LEFT JOIN DonorType DT on Donor.donor_id = DT.donor_id
    LEFT JOIN DonorProduct DP ON Donor.donor_id = DP.donor_id
    GROUP BY (DC.donor_id);
END//
DELIMITER ;

-- Get specific donor
DROP PROCEDURE IF EXISTS GetDonor;
DELIMITER //
CREATE PROCEDURE GetDonor(
    IN _donor_id INT
)
BEGIN
    SELECT Donor.donor_id, donor_name, donor_city, donor_colony, donor_organization, donor_website1, donor_website2, donor_cfdi, GROUP_CONCAT(DISTINCT product_id) AS 'Donations',GROUP_CONCAT(DISTINCT type_id) as "Tipo", category_id
        FROM Donor
            LEFT JOIN DonorCategory DC ON Donor.donor_id = DC.donor_id
            LEFT JOIN DonorType DT on Donor.donor_id = DT.donor_id
            LEFT JOIN DonorProduct DP ON Donor.donor_id = DP.donor_id
        WHERE Donor.donor_id = _donor_id;
END //
DELIMITER ;

-- Update donor data
DROP PROCEDURE IF EXISTS UpdateDonor;
DELIMITER //
CREATE PROCEDURE UpdateDonor (
    IN _jsonA JSON
)
BEGIN
    DECLARE _json JSON;
    DECLARE _idUsuario INT;
    DECLARE name CHAR(100);
    DECLARE city CHAR(100);
    DECLARE colony CHAR(100);
    DECLARE organization CHAR(100);
    DECLARE website1 CHAR(100);
    DECLARE website2 CHAR(100);
    DECLARE cfdi CHAR(100);
    DECLARE category INT;
    DECLARE mail CHAR(100);

    DECLARE types JSON;
    DECLARE tempType INT;
    DECLARE _count INT DEFAULT 0;
    DECLARE _index INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'ERROR!' AS 'RESULTADO';
        ROLLBACK;
    END ;

    SET _json = JSON_EXTRACT(_jsonA, '$[0]');
    SET _idUsuario = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.id'));
    SET name = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.name'));
    SET city = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.city'));
    SET colony = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.colony'));
    SET organization = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.organization'));
    SET website1 = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.website1'));
    SET website2 = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.website2'));
    SET cfdi = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.cfdi'));
    SET category = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.category'));
    SET types = JSON_EXTRACT(_json, '$.type');
    SET mail = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.mail'));

    SET _count = JSON_LENGTH(types) - 1;

    START TRANSACTION ;

        IF (cfdi = 'null') THEN
			UPDATE Donor
            SET
				Donor.donor_name = name,
                Donor.donor_city = city,
                Donor.donor_colony = colony,
                Donor.donor_organization = organization,
                Donor.donor_website1 = website1,
                Donor.donor_website2 = website2
			WHERE Donor.donor_id = _idUsuario;
        ELSE
            UPDATE Donor
            SET
				Donor.donor_name = name,
                Donor.donor_city = city,
                Donor.donor_colony = colony,
                Donor.donor_organization = organization,
                Donor.donor_website1 = website1,
                Donor.donor_website2 = website2,
                Donor.donor_cfdi = cfdi
			WHERE Donor.donor_id = _idUsuario;
        END IF;

        IF((SELECT ROW_COUNT()) = 0) THEN
            SELECT CONCAT('No se pudo insertar el usuario') as 'STATUS';
            ROLLBACK ;
        END IF;

        UPDATE DonorCategory
		SET
            DonorCategory.category_id = category
		WHERE
			DonorCategory.donor_id = _idUsuario;

        IF((SELECT ROW_COUNT()) = 0) THEN
            SELECT CONCAT('No se pudo agregar la categoria') as 'STATUS';
            ROLLBACK ;
        END IF;

        IF ((SELECT COUNT(*) FROM DonorMail WHERE donor_id = 1) = 0) THEN
            INSERT INTO DonorMail VALUES (0, _idUsuario, mail);
        ELSE
            UPDATE DonorMail SET
                                 donor_mail = mail
            WHERE donor_id = _idUsuario;
        END IF ;

        IF((SELECT ROW_COUNT()) = 0) THEN
            SELECT CONCAT('No se pudo agregar el correo') as 'STATUS';
            ROLLBACK ;
        END IF;

        DELETE FROM DonorType WHERE donor_id = _idUsuario;
        WHILE _count >= 0 DO
            SET _json = JSON_EXTRACT(types, CONCAT('$[',_index,']'));
            SET _index = _index + 1;
            SET tempType = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.id'));
            INSERT INTO DonorType VALUES (_idUsuario, tempType);
        END WHILE ;

        SELECT 'Usuario actualizado' AS 'STATUS';
    COMMIT ;

END //

DELIMITER ;

-- Add data contact to a donor
DROP PROCEDURE IF EXISTS AddPhoneToDonor;
DELIMITER //
CREATE PROCEDURE AddPhoneToDonor(
	donor_id INT,
	donor_phone CHAR(15)
)
BEGIN
	INSERT INTO DonorPhone VALUES(null, donor_id, donor_phone);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS AddMailToDonor;
DELIMITER //
CREATE PROCEDURE AddMailToDonor(
	donor_id INT,
    donor_mail CHAR(100)
)
BEGIN
	INSERT INTO DonorMail VALUES(null, donor_id, donor_mail);
END //
DELIMITER ;

-- Add products for donators
DROP PROCEDURE IF EXISTS AddProductForDonation;
DELIMITER //
CREATE PROCEDURE AddProductForDonation(
	new_product_name CHAR(25)
)
BEGIN

	IF NOT EXISTS (SELECT product_name FROM Product WHERE product_name = LOWER(new_product_name)) THEN
		INSERT INTO Product VALUES (null, LOWER(new_product_name));
	END IF;
END //
DELIMITER ;

-- Add a new unit
DROP PROCEDURE IF EXISTS AddDonationUnit;
DELIMITER //
CREATE PROCEDURE AddDonationUnit(
	unit_name CHAR(25)
)
BEGIN
	IF NOT EXISTS (SELECT Unit.unit_name FROM Unit WHERE Unit.unit_name = unit_name) THEN
		INSERT INTO Unit VALUES (LOWER(unit_name));
	END IF;
END //
DELIMITER ;

-- Add donation/products for a donor
DROP PROCEDURE IF EXISTS AddDonationToDonor;
DELIMITER //
CREATE PROCEDURE AddDonationToDonor(
	donor_id INT,
    product_id CHAR(25),
    donation_date TIMESTAMP,
    donation_observation CHAR(200),
    product_quantity FLOAT,
    product_unit CHAR(25)
)
BEGIN
	INSERT INTO DonorProduct VALUES(null, donor_id, product_id, donation_date, donation_observation, product_quantity, product_unit);
END //
DELIMITER ;

-- Delete donor from all tables
DROP PROCEDURE IF EXISTS DeleteDonor;
DELIMITER //
CREATE PROCEDURE DeleteDonor(
	donor_id INT
)
BEGIN
	IF EXISTS (SELECT * FROM DonorPhone WHERE DonorPhone.donor_id = donor_id) THEN
		DELETE FROM DonorPhone WHERE DonorPhone.donor_id = donor_id;
	END IF;
	IF EXISTS (SELECT * FROM DonorMail WHERE DonorMail.donor_id = donor_id) THEN
		DELETE FROM DonorMail WHERE DonorMail.donor_id = donor_id;
	END IF;
    IF EXISTS (SELECT * FROM DonorProduct WHERE DonorProduct.donor_id = donor_id) THEN
		DELETE FROM DonorProduct WHERE DonorProduct.donor_id = donor_id;
    END IF;
	DELETE FROM Donor WHERE Donor.donor_id = donor_id;
END //
DELIMITER ;


-- Filter: Donors by name of product
DROP PROCEDURE IF EXISTS FilterDonors;
DELIMITER //
CREATE PROCEDURE FilterDonors(
	search CHAR(100)
)
BEGIN
    SET search = CONCAT('%', search, '%');
    IF((SELECT COUNT(*) FROM Donor WHERE donor_name LIKE search) > 0) THEN
        BEGIN
            SELECT Donor.donor_id
                FROM Donor
                WHERE donor_name LIKE search;
        END;
    ELSE IF ((SELECT COUNT(*) FROM DonorProduct LEFT JOIN Product ON DonorProduct.product_id = Product.product_id WHERE product_name LIKE search) > 0) THEN
        BEGIN
            SELECT DISTINCT Donor.donor_id
                FROM Donor
                LEFT JOIN DonorProduct DP ON Donor.donor_id = DP.donor_id
                LEFT JOIN Product P on DP.product_id = P.product_id
                WHERE product_name LIKE search
                GROUP BY (Donor.donor_id);
        END;
    ELSE
        SELECT 'Not found' AS 'RESULT';
    END IF ;
    END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS FilterProducts;
DELIMITER //
CREATE PROCEDURE FilterProducts(
    search CHAR(100)
)
BEGIN
    SET search = CONCAT('%', search, '%');
    IF ((SELECT COUNT(*) FROM Product WHERE product_name LIKE search) > 0 ) THEN
        SELECT * FROM Product WHERE product_name LIKE search;
    ELSE
        SELECT 'NOT FOUND' AS 'RESULT';
    END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS SetCFDI;
DELIMITER //
CREATE PROCEDURE SetCFDI(
donorID INT,
filePath CHAR(100)
)
BEGIN
    UPDATE Donor SET donor_cfdi = filePath WHERE donor_id = donorID;
END //
DELIMITER ;

-- Export CSV
DROP PROCEDURE IF EXISTS ExportCSV;
DELIMITER //
CREATE PROCEDURE ExportCSV()
BEGIN
    DECLARE name VARCHAR(100);
    DECLARE route VARCHAR(100);
    DECLARE final_name VARCHAR(100);

    SET name = CONCAT('users-',CURTIME() + 0,'.csv');
    SET route = '\'C:/wamp64/tmp/';
    SET final_name = CONCAT(route, name,'\'');
    SET @get_csv = CONCAT('SELECT Donor.donor_id, donor_name, donor_city, donor_colony, donor_organization, donor_website1, donor_website2, donor_cfdi, GROUP_CONCAT(DISTINCT product_name) AS "Productos", GROUP_CONCAT(DISTINCT type_name) AS "Tipo", cat_name
        FROM Donor
        LEFT JOIN DonorCategory DC ON Donor.donor_id = DC.donor_id
        LEFT JOIN DonorType DT on Donor.donor_id = DT.donor_id
        LEFT JOIN DonorProduct DP ON Donor.donor_id = DP.donor_id
        LEFT JOIN Product p on DP.product_id = p.product_id
        LEFT JOIN Type T on DT.type_id = T.type_id
        LEFT JOIN Category C on DC.category_id = C.cat_id
        GROUP BY (DC.donor_id)
        INTO OUTFILE ',
            final_name,
        ' FIELDS ENCLOSED BY \'"\'
        TERMINATED BY \',\'
        LINES TERMINATED BY \'\\r\\n\';');
    SELECT name AS 'NAME';
    PREPARE stmt FROM @get_csv;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;