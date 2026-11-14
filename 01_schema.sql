-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM (HMS) - DATABASE SCHEMA
-- DBMS Course Project | 3rd Year Computer Engineering
-- Target RDBMS: MySQL 8.0+
-- File: 01_schema.sql
-- ============================================================================

-- Step 1: Create Database
DROP DATABASE IF EXISTS hospital_management_db;
CREATE DATABASE hospital_management_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE hospital_management_db;

-- ============================================================================
-- MODULE 1: DEPARTMENT MANAGEMENT
-- ============================================================================
-- Stores hospital clinical and administrative departments
CREATE TABLE Department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    head_of_department VARCHAR(100) NOT NULL,
    contact_extension VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================================
-- MODULE 2: DOCTOR MANAGEMENT
-- ============================================================================
-- Stores doctor profiles linked to their respective departments
CREATE TABLE Doctor (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    consultation_fee DECIMAL(10, 2) NOT NULL CHECK (consultation_fee >= 0),
    joining_date DATE NOT NULL,
    status ENUM('Active', 'On Leave', 'Retired') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_doctor_department 
        FOREIGN KEY (department_id) 
        REFERENCES Department(department_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- MODULE 3: PATIENT MANAGEMENT
-- ============================================================================
-- Stores patient personal, demographic, and medical contact records
CREATE TABLE Patient (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    date_of_birth DATE NOT NULL,
    blood_group VARCHAR(5) NOT NULL CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    emergency_contact VARCHAR(15) NOT NULL,
    registered_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================================
-- MODULE 4: APPOINTMENT MANAGEMENT
-- ============================================================================
-- Manages doctor-patient consultation schedules
CREATE TABLE Appointment (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status ENUM('Scheduled', 'Completed', 'Cancelled', 'No Show') NOT NULL DEFAULT 'Scheduled',
    reason_for_visit VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointment_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES Patient(patient_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_appointment_doctor 
        FOREIGN KEY (doctor_id) 
        REFERENCES Doctor(doctor_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- MODULE 5: ROOM MANAGEMENT
-- ============================================================================
-- Tracks hospital beds, wards, private rooms, and ICUs
CREATE TABLE Room (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type ENUM('General Ward', 'Semi-Private', 'Private Deluxe', 'ICU') NOT NULL,
    charge_per_day DECIMAL(10, 2) NOT NULL CHECK (charge_per_day > 0),
    status ENUM('Available', 'Occupied', 'Under Maintenance') NOT NULL DEFAULT 'Available'
) ENGINE=InnoDB;

-- ============================================================================
-- MODULE 6: INPATIENT ADMISSION MANAGEMENT
-- ============================================================================
-- Records patient admissions into rooms/beds and discharge details
CREATE TABLE Admission (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    room_id INT NOT NULL,
    doctor_id INT NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE NULL,
    diagnosis VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_discharge_after_admission 
        CHECK (discharge_date IS NULL OR discharge_date >= admission_date),
    CONSTRAINT fk_admission_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES Patient(patient_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_admission_room 
        FOREIGN KEY (room_id) 
        REFERENCES Room(room_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_admission_doctor 
        FOREIGN KEY (doctor_id) 
        REFERENCES Doctor(doctor_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- MODULE 7: MEDICINE / PHARMACY INVENTORY MANAGEMENT
-- ============================================================================
-- Manages hospital pharmacy stock, unit pricing, and manufacturer details
CREATE TABLE Medicine (
    medicine_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    manufacturer VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================================
-- MODULE 8: PRESCRIPTION MANAGEMENT
-- ============================================================================
-- Prescriptions generated per consultation appointment
CREATE TABLE Prescription (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    prescription_date DATE NOT NULL,
    clinical_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prescription_appointment 
        FOREIGN KEY (appointment_id) 
        REFERENCES Appointment(appointment_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Bridge Table: Resolves M:N relationship between Prescription and Medicine
CREATE TABLE Prescription_Medicine (
    prescription_item_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    medicine_id INT NOT NULL,
    dosage VARCHAR(50) NOT NULL,        -- e.g. '500mg'
    quantity INT NOT NULL CHECK (quantity > 0),
    instructions VARCHAR(100) NOT NULL,  -- e.g. 'Twice daily after meals'
    CONSTRAINT uq_presc_medicine 
        UNIQUE (prescription_id, medicine_id),
    CONSTRAINT fk_pm_prescription 
        FOREIGN KEY (prescription_id) 
        REFERENCES Prescription(prescription_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_pm_medicine 
        FOREIGN KEY (medicine_id) 
        REFERENCES Medicine(medicine_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- MODULE 9: BILLING & INVOICING MANAGEMENT
-- ============================================================================
-- Consolidates consultation, room stay, pharmacy, and auxiliary charges
CREATE TABLE Bill (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    admission_id INT NULL,
    bill_date DATE NOT NULL,
    consultation_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (consultation_fee >= 0),
    room_charges DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (room_charges >= 0),
    medicine_charges DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (medicine_charges >= 0),
    other_charges DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (other_charges >= 0),
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    payment_status ENUM('Paid', 'Pending', 'Partially Paid') NOT NULL DEFAULT 'Pending',
    payment_mode ENUM('Cash', 'UPI', 'Credit Card', 'Debit Card', 'Net Banking', 'Insurance') NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bill_patient 
        FOREIGN KEY (patient_id) 
        REFERENCES Patient(patient_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_bill_admission 
        FOREIGN KEY (admission_id) 
        REFERENCES Admission(admission_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE
) ENGINE=InnoDB;
