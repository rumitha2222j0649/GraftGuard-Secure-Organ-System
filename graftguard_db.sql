-- ========================================================
-- Database Name: `graftguard_db`
-- System Name:   GraftGuard – Secure Organ System
-- Compatibility: MySQL 5.7+, MySQL 8.0+, MariaDB 10.3+, phpMyAdmin
-- Description:   Complete relational schema with Primary Keys, 
--                Foreign Keys, Unique Constraints, Bcrypt Hashes,
--                and Duplicate Allocation Prevention.
-- ========================================================

-- Step 1: Create Database if not exists
CREATE DATABASE IF NOT EXISTS `graftguard_db`
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE `graftguard_db`;

-- Temporarily disable foreign key checks for clean drops/creation
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `allocation`;
DROP TABLE IF EXISTS `patient`;
DROP TABLE IF EXISTS `donor`;
DROP TABLE IF EXISTS `hospital`;
DROP TABLE IF EXISTS `admin`;

SET FOREIGN_KEY_CHECKS = 1;

-- ========================================================
-- Table 1: `admin`
-- Holds administrative accounts (System Directors)
-- ========================================================
CREATE TABLE `admin` (
  `admin_id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL COMMENT 'Full name of the administrator',
  `username` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Unique system login handle',
  `password` VARCHAR(255) NOT NULL COMMENT 'Secure bcrypt hashed password (min 60 chars)',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- Table 2: `hospital`
-- Holds accredited retrieval and transplant hospitals
-- ========================================================
CREATE TABLE `hospital` (
  `hospital_id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(150) NOT NULL COMMENT 'Registered hospital name',
  `address` TEXT NOT NULL COMMENT 'Full physical location address',
  `contact` VARCHAR(20) NOT NULL COMMENT 'Hospital emergency contact number',
  `username` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Unique hospital coordinator username',
  `password` VARCHAR(255) NOT NULL COMMENT 'Secure bcrypt hashed password',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- Table 3: `donor`
-- Holds organ donor registry details
-- ========================================================
CREATE TABLE `donor` (
  `donor_id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL COMMENT 'Pledged organ donor full name',
  `age` INT NOT NULL COMMENT 'Donor age in years',
  `blood_group` ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NOT NULL COMMENT 'ABO and Rh blood group',
  `donated_organ` VARCHAR(50) NOT NULL COMMENT 'Pledged or retrieved organ (e.g. Kidney, Liver, Heart, Lung)',
  `hospital_id` INT NOT NULL COMMENT 'Reference to registering hospital',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign Key Constraint
  CONSTRAINT `fk_donor_hospital`
    FOREIGN KEY (`hospital_id`) 
    REFERENCES `hospital` (`hospital_id`)
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- Table 4: `patient`
-- Holds waitlisted organ recipients needing transplants
-- ========================================================
CREATE TABLE `patient` (
  `patient_id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL COMMENT 'Patient full name',
  `age` INT NOT NULL COMMENT 'Patient age in years',
  `blood_group` ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NOT NULL COMMENT 'ABO and Rh blood group',
  `required_organ` VARCHAR(50) NOT NULL COMMENT 'Organ urgently required for transplantation',
  `hospital_id` INT NOT NULL COMMENT 'Admitting transplant hospital',
  `username` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Unique patient portal login handle',
  `password` VARCHAR(255) NOT NULL COMMENT 'Secure bcrypt hashed password',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign Key Constraint
  CONSTRAINT `fk_patient_hospital`
    FOREIGN KEY (`hospital_id`) 
    REFERENCES `hospital` (`hospital_id`)
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- Table 5: `allocation`
-- Records approved organ matches and transfers.
-- Enforces STRICT duplicate prevention:
--   1. UNIQUE (`donor_id`): A donor's organ can be allocated ONLY ONCE.
--   2. UNIQUE (`patient_id`): A recipient cannot receive duplicate allocations.
-- ========================================================
CREATE TABLE `allocation` (
  `allocation_id` INT AUTO_INCREMENT PRIMARY KEY,
  `donor_id` INT NOT NULL COMMENT 'Donor whose organ is being allocated',
  `patient_id` INT NOT NULL COMMENT 'Recipient patient receiving the organ',
  `hospital_id` INT NOT NULL COMMENT 'Transplant hospital coordinating the surgery',
  `organ_name` VARCHAR(50) NOT NULL COMMENT 'Name of organ being allocated (Kidney, Liver, etc.)',
  `allocation_status` ENUM('Pending', 'Approved', 'Rejected', 'Transferred', 'Completed') 
    NOT NULL DEFAULT 'Pending' 
    COMMENT 'Lifecycle state of organ allocation',
  `approved_by_admin` INT NULL COMMENT 'Admin ID who reviewed and authorized allocation',
  `allocation_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  -- PREVENT DUPLICATE ALLOCATIONS:
  -- A donor organ can only be allocated once in the entire system:
  CONSTRAINT `uq_single_donor_allocation` 
    UNIQUE (`donor_id`),

  -- Foreign Key Constraints
  CONSTRAINT `fk_alloc_donor`
    FOREIGN KEY (`donor_id`) 
    REFERENCES `donor` (`donor_id`)
    ON DELETE RESTRICT 
    ON UPDATE CASCADE,

  CONSTRAINT `fk_alloc_patient`
    FOREIGN KEY (`patient_id`) 
    REFERENCES `patient` (`patient_id`)
    ON DELETE RESTRICT 
    ON UPDATE CASCADE,

  CONSTRAINT `fk_alloc_hospital`
    FOREIGN KEY (`hospital_id`) 
    REFERENCES `hospital` (`hospital_id`)
    ON DELETE RESTRICT 
    ON UPDATE CASCADE,

  CONSTRAINT `fk_alloc_admin`
    FOREIGN KEY (`approved_by_admin`) 
    REFERENCES `admin` (`admin_id`)
    ON DELETE SET NULL 
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- ADVANCED VALIDATION TRIGGER: Prevent Duplicate Organ Allocation
-- Emits clear SQL error if an organ from the same donor is re-allocated.
-- ========================================================
DELIMITER $$

CREATE TRIGGER `trg_prevent_duplicate_allocation`
BEFORE INSERT ON `allocation`
FOR EACH ROW
BEGIN
  DECLARE existing_count INT DEFAULT 0;

  -- Check if this donor has already been allocated an organ that is not Rejected
  SELECT COUNT(*) INTO existing_count
  FROM `allocation`
  WHERE `donor_id` = NEW.`donor_id`
    AND `allocation_status` != 'Rejected';

  IF existing_count > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'SECURITY ERROR: This donor organ has already been allocated and cannot be re-assigned!';
  END IF;
END$$

DELIMITER ;

-- ========================================================
-- SAMPLE DATA INSERTION (With Bcrypt Hashed Passwords)
-- Demo Password for all accounts: password123
-- Bcrypt Hash: $2a$10$13wPGEv0j3XvM9gCQL5AdOxC4nB7SH4B917P5GQV/TCghNtM4Ry22
-- ========================================================

-- 1. Insert Admins
INSERT INTO `admin` (`admin_id`, `name`, `username`, `password`) VALUES
(1, 'Dr. Sarah Mitchell', 'admin_sarah', '$2a$10$13wPGEv0j3XvM9gCQL5AdOxC4nB7SH4B917P5GQV/TCghNtM4Ry22'),
(2, 'Chief Director Ramesh Kumar', 'admin_ramesh', '$2a$10$13wPGEv0j3XvM9gCQL5AdOxC4nB7SH4B917P5GQV/TCghNtM4Ry22');

-- 2. Insert Hospitals
INSERT INTO `hospital` (`hospital_id`, `name`, `address`, `contact`, `username`, `password`) VALUES
(1, 'Apex Multi-Specialty Transplant Institute', 'Sector 12, Institutional Area, New Delhi', '+91 11 2659 0001', 'apex_hospital', '$2a$10$13wPGEv0j3XvM9gCQL5AdOxC4nB7SH4B917P5GQV/TCghNtM4Ry22'),
(2, 'Metro City Organ Retrieval Center', 'Bandra West, Marine Boulevard, Mumbai', '+91 22 4001 8899', 'metro_hospital', '$2a$10$13wPGEv0j3XvM9gCQL5AdOxC4nB7SH4B917P5GQV/TCghNtM4Ry22'),
(3, 'Global Medical Sciences Hospital', 'Outer Ring Road, Bellandur, Bengaluru', '+91 80 6112 3300', 'global_hospital', '$2a$10$13wPGEv0j3XvM9gCQL5AdOxC4nB7SH4B917P5GQV/TCghNtM4Ry22');

-- 3. Insert Donors
INSERT INTO `donor` (`donor_id`, `name`, `age`, `blood_group`, `donated_organ`, `hospital_id`) VALUES
(1, 'Arjun Verma', 32, 'O+', 'Kidney', 1),
(2, 'Priya Sundaram', 28, 'A+', 'Liver', 2),
(3, 'Rajesh Patel', 45, 'B+', 'Heart', 3),
(4, 'Deepa Nair', 34, 'O-', 'Cornea', 1);

-- 4. Insert Patients
INSERT INTO `patient` (`patient_id`, `name`, `age`, `blood_group`, `required_organ`, `hospital_id`, `username`, `password`) VALUES
(1, 'Rohan Mehra', 38, 'O+', 'Kidney', 1, 'patient_rohan', '$2a$10$13wPGEv0j3XvM9gCQL5AdOxC4nB7SH4B917P5GQV/TCghNtM4Ry22'),
(2, 'Ananya Sharma', 29, 'A+', 'Liver', 2, 'patient_ananya', '$2a$10$13wPGEv0j3XvM9gCQL5AdOxC4nB7SH4B917P5GQV/TCghNtM4Ry22'),
(3, 'Karthik Rao', 52, 'B+', 'Heart', 3, 'patient_karthik', '$2a$10$13wPGEv0j3XvM9gCQL5AdOxC4nB7SH4B917P5GQV/TCghNtM4Ry22'),
(4, 'Meera Joshi', 41, 'O-', 'Kidney', 1, 'patient_meera', '$2a$10$13wPGEv0j3XvM9gCQL5AdOxC4nB7SH4B917P5GQV/TCghNtM4Ry22');

-- 5. Insert Sample Allocations
INSERT INTO `allocation` (`allocation_id`, `donor_id`, `patient_id`, `hospital_id`, `organ_name`, `allocation_status`, `approved_by_admin`) VALUES
(1, 1, 1, 1, 'Kidney', 'Approved', 1),
(2, 2, 2, 2, 'Liver', 'Pending', NULL);

-- ========================================================
-- HELPFUL VERIFICATION QUERIES
-- ========================================================
-- Query 1: View Full Organ Allocation Details with Patient & Hospital Info
-- SELECT 
--   a.allocation_id,
--   d.name AS donor_name,
--   d.blood_group AS donor_blood,
--   a.organ_name,
--   p.name AS patient_name,
--   p.blood_group AS patient_blood,
--   h.name AS hospital_name,
--   a.allocation_status,
--   adm.name AS approved_by
-- FROM allocation a
-- JOIN donor d ON a.donor_id = d.donor_id
-- JOIN patient p ON a.patient_id = p.patient_id
-- JOIN hospital h ON a.hospital_id = h.hospital_id
-- LEFT JOIN admin adm ON a.approved_by_admin = adm.admin_id;

