-- ============================================ --
-- |        Created on January 2023           | --
-- |  Copyrigth (c) 2023 ISRAEL SANCHEZ       | --
-- |          All rights reserved             | --
-- ============================================ --
-- |         "BAMX" database v3.5.0           | --
-- | Query to create the database and tables  | --
-- ============================================ --

DROP DATABASE IF EXISTS BAMX;
CREATE DATABASE BAMX;
USE BAMX;

DROP TABLE IF EXISTS Donor;
CREATE TABLE Donor(
	donor_id INT NOT NULL AUTO_INCREMENT,
	donor_name CHAR(50),
    donor_city CHAR(50),
    donor_colony CHAR(50),
    donor_organization CHAR(100),
    donor_website1 CHAR(50),
    donor_website2 CHAR(50),
    donor_cfdi CHAR(50),

    PRIMARY KEY(donor_id)
);

DROP TABLE IF EXISTS Product;
CREATE TABLE Product(
	product_id INT NOT NULL AUTO_INCREMENT,
	product_name CHAR(25) NOT NULL,

    PRIMARY KEY(product_id)
);

DROP TABLE IF EXISTS DonorProduct;
CREATE TABLE DonorProduct(
	donation_id INT NOT NULL AUTO_INCREMENT,
	donor_id INT NOT NULL,
    product_id INT NOT NULL,
    donation_date TIMESTAMP,
    donation_observation CHAR(200),
    product_quantity FLOAT,
    unit_id INT,

    PRIMARY KEY(donation_id),
    FOREIGN KEY(donor_id) REFERENCES Donor(donor_id),
    FOREIGN KEY(product_id) REFERENCES Product(product_id),
    FOREIGN KEY(unit_id) REFERENCES Unit(unit_id)
);

DROP TABLE IF EXISTS DonorMail;
CREATE TABLE DonorMail(
	mail_id INT NOT NULL AUTO_INCREMENT,
	donor_id INT NOT NULL,
    donor_mail CHAR(100),

    PRIMARY KEY(mail_id),
    FOREIGN KEY(donor_id) REFERENCES Donor(donor_id)
);

DROP TABLE IF EXISTS DonorPhone;
CREATE TABLE DonorPhone(
	phone_id INT NOT NULL AUTO_INCREMENT,
	donor_id INT NOT NULL,
    donor_phone CHAR(15),

    PRIMARY KEY(phone_id),
    FOREIGN KEY(donor_id) REFERENCES Donor(donor_id)
);

DROP TABLE IF EXISTS DonorType;
CREATE TABLE DonorType(
	donor_id INT NOT NULL,
    type_id INT NOT NULL,

    PRIMARY KEY(donor_id, type_id),
    FOREIGN KEY(donor_id) REFERENCES Donor(donor_id),
    FOREIGN KEY(type_id)  REFERENCES Type(type_id)
);

DROP TABLE IF EXISTS Unit;
CREATE TABLE Unit(
	unit_id INT NOT NULL AUTO_INCREMENT,
	unit_name CHAR(25) NOT NULL,

    PRIMARY KEY(unit_id)
);

DROP TABLE IF EXISTS Type;
CREATE TABLE Type(
	type_id INT NOT NULL AUTO_INCREMENT,
    type_name CHAR(25),

    PRIMARY KEY(type_id)
);

DROP TABLE IF EXISTS Category;
CREATE TABLE Category(
	cat_id INT NOT NULL AUTO_INCREMENT,
    cat_name CHAR(25),

    PRIMARY KEY(cat_id)
);

DROP TABLE IF EXISTS DonorCategory;
CREATE TABLE DonorCategory(
    donor_id INT NOT NULL,
    category_id INT NOT NULL,

    FOREIGN KEY (donor_id) REFERENCES Donor(donor_id),
    FOREIGN KEY (category_id) REFERENCES Category(cat_id),
    PRIMARY KEY (donor_id, category_id)
);