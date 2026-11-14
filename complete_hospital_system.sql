-- ============================================================================
-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM (HMS) - MASTER CONSOLIDATED SCRIPT
-- DBMS Course Project | 3rd Year Computer Engineering
-- Target RDBMS: MySQL 8.0+
-- File: complete_hospital_system.sql
-- ============================================================================
-- Instructions: Run this entire script in MySQL Workbench or via MySQL CLI:
--               SOURCE complete_hospital_system.sql;
-- ============================================================================

-- Step 1: Initialize Database
DROP DATABASE IF EXISTS hospital_management_db;
CREATE DATABASE hospital_management_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE hospital_management_db;

-- ============================================================================
-- SECTION 1: DDL TABLE CREATION WITH CONSTRAINTS
-- ============================================================================

-- 1. Department Table
CREATE TABLE Department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    head_of_department VARCHAR(100) NOT NULL,
    contact_extension VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Doctor Table
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

-- 3. Patient Table
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

-- 4. Appointment Table
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

-- 5. Room Table
CREATE TABLE Room (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type ENUM('General Ward', 'Semi-Private', 'Private Deluxe', 'ICU') NOT NULL,
    charge_per_day DECIMAL(10, 2) NOT NULL CHECK (charge_per_day > 0),
    status ENUM('Available', 'Occupied', 'Under Maintenance') NOT NULL DEFAULT 'Available'
) ENGINE=InnoDB;

-- 6. Admission Table
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

-- 7. Medicine Table
CREATE TABLE Medicine (
    medicine_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    manufacturer VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 8. Prescription Table
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

-- 9. Prescription_Medicine Table
CREATE TABLE Prescription_Medicine (
    prescription_item_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    medicine_id INT NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    instructions VARCHAR(100) NOT NULL,
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

-- 10. Bill Table
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


-- ============================================================================
-- SECTION 2: TRIGGERS (6 TRIGGERS)
-- ============================================================================

-- Trigger 1: Prevent Invalid Future Patient DOB
DELIMITER $$
CREATE TRIGGER trg_prevent_future_dob
BEFORE INSERT ON Patient
FOR EACH ROW
BEGIN
    IF NEW.date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Patient Date of Birth cannot be in the future!';
    END IF;
END$$

-- Trigger 2: Automatically Update Room to Occupied upon Inpatient Admission
CREATE TRIGGER trg_room_occupied_on_admission
AFTER INSERT ON Admission
FOR EACH ROW
BEGIN
    IF NEW.discharge_date IS NULL THEN
        UPDATE Room
        SET status = 'Occupied'
        WHERE room_id = NEW.room_id;
    END IF;
END$$

-- Trigger 3: Automatically Free Room back to Available upon Discharge
CREATE TRIGGER trg_room_available_on_discharge
AFTER UPDATE ON Admission
FOR EACH ROW
BEGIN
    IF (OLD.discharge_date IS NULL AND NEW.discharge_date IS NOT NULL) THEN
        UPDATE Room
        SET status = 'Available'
        WHERE room_id = NEW.room_id;
    END IF;
END$$

-- Trigger 4: Prevent Doctor Double Booking on Same Date and Time
CREATE TRIGGER trg_prevent_doctor_double_booking
BEFORE INSERT ON Appointment
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM Appointment
    WHERE doctor_id = NEW.doctor_id
      AND appointment_date = NEW.appointment_date
      AND appointment_time = NEW.appointment_time
      AND status NOT IN ('Cancelled');
      
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Scheduling Conflict: Doctor already has an active appointment at this date and time!';
    END IF;
END$$

-- Trigger 5: Automatic Bill Total Calculation on INSERT and UPDATE
CREATE TRIGGER trg_calculate_total_bill_insert
BEFORE INSERT ON Bill
FOR EACH ROW
BEGIN
    SET NEW.total_amount = COALESCE(NEW.consultation_fee, 0.00) 
                         + COALESCE(NEW.room_charges, 0.00) 
                         + COALESCE(NEW.medicine_charges, 0.00) 
                         + COALESCE(NEW.other_charges, 0.00);
END$$

CREATE TRIGGER trg_calculate_total_bill_update
BEFORE UPDATE ON Bill
FOR EACH ROW
BEGIN
    SET NEW.total_amount = COALESCE(NEW.consultation_fee, 0.00) 
                         + COALESCE(NEW.room_charges, 0.00) 
                         + COALESCE(NEW.medicine_charges, 0.00) 
                         + COALESCE(NEW.other_charges, 0.00);
END$$

-- Bonus Trigger 6: Real-time Pharmacy Stock Deduction on Prescription Dispensing
CREATE TRIGGER trg_deduct_medicine_stock
AFTER INSERT ON Prescription_Medicine
FOR EACH ROW
BEGIN
    UPDATE Medicine
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE medicine_id = NEW.medicine_id;
END$$
DELIMITER ;


-- ============================================================================
-- SECTION 3: STORED PROCEDURES & DATABASE VIEWS
-- ============================================================================

-- View 1: Doctor Schedule
CREATE OR REPLACE VIEW vw_Doctor_Schedule AS
SELECT 
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS doctor_name,
    dep.department_name,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.phone AS patient_phone,
    a.reason_for_visit,
    a.status AS appointment_status
FROM Appointment a
JOIN Doctor d ON a.doctor_id = d.doctor_id
JOIN Department dep ON d.department_id = dep.department_id
JOIN Patient p ON a.patient_id = p.patient_id;

-- View 2: Active Inpatients
CREATE OR REPLACE VIEW vw_Active_Inpatients AS
SELECT 
    adm.admission_id,
    adm.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.gender,
    TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS age,
    p.blood_group,
    r.room_number,
    r.room_type,
    r.charge_per_day,
    adm.admission_date,
    DATEDIFF(CURDATE(), adm.admission_date) AS days_admitted_so_far,
    adm.diagnosis,
    CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS attending_doctor,
    dep.department_name
FROM Admission adm
JOIN Patient p ON adm.patient_id = p.patient_id
JOIN Room r ON adm.room_id = r.room_id
JOIN Doctor d ON adm.doctor_id = d.doctor_id
JOIN Department dep ON d.department_id = dep.department_id
WHERE adm.discharge_date IS NULL;

-- View 3: Comprehensive Bill Summary
CREATE OR REPLACE VIEW vw_Comprehensive_Bill_Summary AS
SELECT 
    b.bill_id,
    b.bill_date,
    b.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.phone AS patient_phone,
    b.admission_id,
    b.consultation_fee,
    b.room_charges,
    b.medicine_charges,
    b.other_charges,
    b.total_amount,
    b.payment_status,
    COALESCE(b.payment_mode, 'Unpaid') AS payment_mode
FROM Bill b
JOIN Patient p ON b.patient_id = p.patient_id;

-- View 4: Low Stock Alert View
CREATE OR REPLACE VIEW vw_Low_Stock_Medicines AS
SELECT 
    medicine_id,
    medicine_name,
    category,
    unit_price,
    stock_quantity,
    manufacturer,
    CASE 
        WHEN stock_quantity = 0 THEN 'CRITICAL: OUT OF STOCK'
        WHEN stock_quantity <= 25 THEN 'HIGH: REORDER IMMEDIATELY'
        ELSE 'MEDIUM: REORDER SOON'
    END AS alert_severity
FROM Medicine
WHERE stock_quantity <= 40;

-- Procedure 1: Safe Appointment Booking
DELIMITER $$
CREATE PROCEDURE sp_ScheduleAppointment (
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_app_date DATE,
    IN p_app_time TIME,
    IN p_reason VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE patient_id = p_patient_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Execution Aborted: Patient ID does not exist!';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Doctor WHERE doctor_id = p_doctor_id AND status = 'Active') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Execution Aborted: Doctor ID does not exist or is not Active!';
    END IF;

    INSERT INTO Appointment (patient_id, doctor_id, appointment_date, appointment_time, status, reason_for_visit)
    VALUES (p_patient_id, p_doctor_id, p_app_date, p_app_time, 'Scheduled', p_reason);

    SELECT LAST_INSERT_ID() AS booked_appointment_id, 'Appointment successfully booked' AS message;
END$$

-- Procedure 2: Safe Patient Admission
CREATE PROCEDURE sp_AdmitPatient (
    IN p_patient_id INT,
    IN p_room_id INT,
    IN p_doctor_id INT,
    IN p_diagnosis VARCHAR(255)
)
BEGIN
    DECLARE v_room_status VARCHAR(20);

    SELECT status INTO v_room_status FROM Room WHERE room_id = p_room_id;

    IF v_room_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Execution Aborted: Specified Room does not exist!';
    ELSEIF v_room_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admission Error: Selected Room is not Available!';
    END IF;

    INSERT INTO Admission (patient_id, room_id, doctor_id, admission_date, discharge_date, diagnosis)
    VALUES (p_patient_id, p_room_id, p_doctor_id, CURDATE(), NULL, p_diagnosis);

    SELECT LAST_INSERT_ID() AS new_admission_id, p_room_id AS room_assigned, 'Patient admitted successfully' AS confirmation;
END$$

-- Procedure 3: Patient Discharge & Invoice Generation
CREATE PROCEDURE sp_DischargePatientAndGenerateBill (
    IN p_admission_id INT,
    IN p_other_charges DECIMAL(10, 2),
    IN p_payment_mode ENUM('Cash', 'UPI', 'Credit Card', 'Debit Card', 'Net Banking', 'Insurance')
)
BEGIN
    DECLARE v_patient_id INT;
    DECLARE v_room_id INT;
    DECLARE v_doctor_id INT;
    DECLARE v_adm_date DATE;
    DECLARE v_charge_per_day DECIMAL(10, 2);
    DECLARE v_consultation_fee DECIMAL(10, 2);
    DECLARE v_days_stayed INT;
    DECLARE v_total_room_cost DECIMAL(10, 2);
    DECLARE v_new_bill_id INT;

    SELECT patient_id, room_id, doctor_id, admission_date
    INTO v_patient_id, v_room_id, v_doctor_id, v_adm_date
    FROM Admission
    WHERE admission_id = p_admission_id AND discharge_date IS NULL;

    IF v_patient_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Discharge Error: Valid active admission not found!';
    END IF;

    SET v_days_stayed = GREATEST(DATEDIFF(CURDATE(), v_adm_date), 1);
    SELECT charge_per_day INTO v_charge_per_day FROM Room WHERE room_id = v_room_id;
    SET v_total_room_cost = v_days_stayed * v_charge_per_day;

    SELECT consultation_fee INTO v_consultation_fee FROM Doctor WHERE doctor_id = v_doctor_id;

    UPDATE Admission
    SET discharge_date = CURDATE()
    WHERE admission_id = p_admission_id;

    INSERT INTO Bill (
        patient_id, admission_id, bill_date, consultation_fee, 
        room_charges, medicine_charges, other_charges, payment_status, payment_mode
    ) VALUES (
        v_patient_id, p_admission_id, CURDATE(), v_consultation_fee, 
        v_total_room_cost, 0.00, COALESCE(p_other_charges, 0.00), 'Paid', p_payment_mode
    );

    SET v_new_bill_id = LAST_INSERT_ID();

    SELECT 
        b.bill_id, CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        r.room_number, v_days_stayed AS days_stayed, b.consultation_fee,
        b.room_charges, b.other_charges, b.total_amount, b.payment_status, b.payment_mode
    FROM Bill b
    JOIN Patient p ON b.patient_id = p.patient_id
    JOIN Room r ON r.room_id = v_room_id
    WHERE b.bill_id = v_new_bill_id;
END$$
DELIMITER ;


-- ============================================================================
-- SECTION 4: REALISTIC SAMPLE DATA INSERTION
-- ============================================================================

-- Departments
INSERT INTO Department (department_name, head_of_department, contact_extension) VALUES
('Cardiology', 'Dr. Arun Mehta', '101'),
('Neurology', 'Dr. Ramesh Iyer', '102'),
('Orthopedics', 'Dr. Vikram Rathore', '103'),
('General Medicine', 'Dr. Sunita Deshmukh', '104'),
('Pediatrics', 'Dr. Kavita Nair', '105'),
('Oncology', 'Dr. Sanjay Kulkarni', '106');

-- Doctors
INSERT INTO Doctor (department_id, first_name, last_name, specialization, phone, email, consultation_fee, joining_date, status) VALUES
(1, 'Arun', 'Mehta', 'Senior Interventional Cardiologist', '9820111001', 'arun.mehta@cityhospital.in', 1200.00, '2016-04-10', 'Active'),
(1, 'Meera', 'Reddy', 'Associate Cardiologist', '9820111002', 'meera.reddy@cityhospital.in', 900.00, '2019-08-15', 'Active'),
(2, 'Ramesh', 'Iyer', 'Chief Neurosurgeon', '9820111003', 'ramesh.iyer@cityhospital.in', 1500.00, '2014-02-01', 'Active'),
(3, 'Vikram', 'Rathore', 'Senior Orthopedic Surgeon', '9820111004', 'vikram.rathore@cityhospital.in', 1000.00, '2017-06-20', 'Active'),
(4, 'Sunita', 'Deshmukh', 'General Physician & Diabetologist', '9820111005', 'sunita.deshmukh@cityhospital.in', 600.00, '2015-11-12', 'Active'),
(4, 'Neha', 'Agarwal', 'Consultant Physician', '9820111006', 'neha.agarwal@cityhospital.in', 550.00, '2021-03-01', 'Active'),
(5, 'Kavita', 'Nair', 'Consultant Pediatrician', '9820111007', 'kavita.nair@cityhospital.in', 700.00, '2018-09-05', 'Active'),
(6, 'Sanjay', 'Kulkarni', 'Surgical Oncologist', '9820111008', 'sanjay.kulkarni@cityhospital.in', 1600.00, '2013-01-10', 'Active');

-- Patients
INSERT INTO Patient (first_name, last_name, gender, date_of_birth, blood_group, phone, email, address, city, emergency_contact) VALUES
('Rajesh', 'Verma', 'Male', '1982-05-14', 'B+', '9819001122', 'rajesh.verma@gmail.com', 'Flat 402, Sai Sagar Apt, Dadar', 'Mumbai', '9819001123'),
('Sneha', 'Kulkarni', 'Female', '1990-11-23', 'O+', '9822334455', 'sneha.kulkarni@yahoo.com', 'B-12, Green Woods, Kothrud', 'Pune', '9822334456'),
('Amit', 'Sharma', 'Male', '1975-02-18', 'A+', '9833445566', 'amit.sharma@outlook.com', '120/4, Mayur Vihar Phase 1', 'Delhi', '9833445567'),
('Priya', 'Nair', 'Female', '1995-07-30', 'AB+', '9844556677', 'priya.nair@gmail.com', '78, 4th Cross, Indiranagar', 'Bangalore', '9844556678'),
('Vikram', 'Malhotra', 'Male', '1968-09-12', 'O-', '9855667788', 'vikram.malhotra@rediffmail.com', 'Plot 55, Jubilee Hills', 'Hyderabad', '9855667789'),
('Ananya', 'Joshi', 'Female', '2001-03-15', 'A-', '9866778899', 'ananya.joshi@gmail.com', 'Flat 10, Vasant Vihar, Baner', 'Pune', '9866778800'),
('Suresh', 'Patel', 'Male', '1959-12-05', 'B+', '9877889900', 'suresh.patel@gmail.com', '14, Navrangpura Society', 'Ahmedabad', '9877889901'),
('Pooja', 'Deshmukh', 'Female', '1988-08-22', 'B-', '9888990011', 'pooja.deshmukh@gmail.com', 'B-304, Palm Beach Rd, Vashi', 'Navi Mumbai', '9888990012'),
('Rohan', 'Gupta', 'Male', '2016-04-10', 'O+', '9899001122', 'rohan.parents@gmail.com', 'C-55, Malviya Nagar', 'Jaipur', '9899001123'),
('Sunita', 'Rao', 'Female', '1972-01-28', 'AB-', '9811223344', 'sunita.rao@gmail.com', 'Flat 201, T. Nagar', 'Chennai', '9811223345');

-- Rooms
INSERT INTO Room (room_number, room_type, charge_per_day, status) VALUES
('GW-101', 'General Ward', 1200.00, 'Available'),
('GW-102', 'General Ward', 1200.00, 'Available'),
('SP-201', 'Semi-Private', 2500.00, 'Available'),
('SP-202', 'Semi-Private', 2500.00, 'Available'),
('PD-301', 'Private Deluxe', 5000.00, 'Available'),
('PD-302', 'Private Deluxe', 5000.00, 'Available'),
('ICU-01', 'ICU', 9500.00, 'Available'),
('ICU-02', 'ICU', 9500.00, 'Available');

-- Appointments
INSERT INTO Appointment (patient_id, doctor_id, appointment_date, appointment_time, status, reason_for_visit) VALUES
(1, 1, '2026-10-15', '10:00:00', 'Completed', 'Routine cardiac stress evaluation'),
(2, 5, '2026-10-16', '11:30:00', 'Completed', 'Persistent viral fever and weakness'),
(3, 4, '2026-10-18', '09:30:00', 'Completed', 'Right knee ligament sprain'),
(4, 3, '2026-10-20', '14:00:00', 'Completed', 'Migraine and chronic tension headache'),
(5, 1, '2026-10-22', '10:30:00', 'Completed', 'Chest discomfort and hypertension review'),
(6, 7, '2026-11-01', '16:00:00', 'Completed', 'Pediatric allergy and asthma follow-up'),
(7, 8, '2026-11-02', '12:00:00', 'Completed', 'Post-chemotherapy routine evaluation'),
(8, 2, '2026-11-06', '10:00:00', 'Scheduled', 'Palpitation and shortness of breath'),
(9, 7, '2026-11-06', '11:00:00', 'Scheduled', 'Childhood immunization check'),
(10, 6, '2026-11-07', '15:30:00', 'Scheduled', 'Thyroid profile consultation');

-- Admissions (Historical Discharged + Active Inpatients)
INSERT INTO Admission (patient_id, room_id, doctor_id, admission_date, discharge_date, diagnosis) VALUES
(1, 1, 1, '2026-10-15', '2026-10-18', 'Acute Angina Pectoris - Stabilized'),
(3, 3, 4, '2026-10-18', '2026-10-22', 'Arthroscopic ACL Reconstruction surgery'),
(7, 4, 8, '2026-10-25', '2026-10-29', 'Chemotherapy Cycle 3 Inpatient Care');

-- Active Inpatient admissions (Triggers will mark PD-301 and ICU-01 Occupied)
INSERT INTO Admission (patient_id, room_id, doctor_id, admission_date, discharge_date, diagnosis) VALUES
(5, 7, 1, '2026-11-02', NULL, 'Acute Myocardial Infarction - Critical Monitoring'),
(2, 5, 5, '2026-11-03', NULL, 'Severe Dengue with Thrombocytopenia');

-- Medicines
INSERT INTO Medicine (medicine_name, category, unit_price, stock_quantity, manufacturer) VALUES
('Atorvastatin 20mg', 'Cardiovascular', 15.50, 250, 'Sun Pharma Ltd'),
('Metoprolol 50mg', 'Cardiovascular', 12.00, 180, 'Cipla Ltd'),
('Paracetamol 650mg', 'Analgesic / Antipyretic', 3.50, 500, 'Micro Labs (Dolo)'),
('Amoxicillin 500mg', 'Antibiotic', 18.00, 120, 'Alkem Laboratories'),
('Pantoprazole 40mg', 'Antacid', 9.00, 300, 'Torrent Pharmaceuticals'),
('Ceftriaxone 1g Inj', 'Injectable Antibiotic', 145.00, 35, 'Dr. Reddy Laboratories'),
('Enoxaparin 40mg Inj', 'Anticoagulant', 480.00, 20, 'Sanofi India'),
('Ibuprofen 400mg', 'NSAID / Pain Relief', 6.00, 220, 'Abbott Healthcare'),
('Levothyroxine 50mcg', 'Endocrine', 4.50, 150, 'GlaxoSmithKline India'),
('Ondansetron 4mg', 'Antiemetic', 8.50, 30, 'Cipla Ltd');

-- Prescriptions
INSERT INTO Prescription (appointment_id, prescription_date, clinical_notes) VALUES
(1, '2026-10-15', 'Lipid control regimen and blood pressure regulation.'),
(2, '2026-10-16', 'Hydration therapy, antipyretic for fever relief.'),
(3, '2026-10-18', 'Post-injury anti-inflammatory analgesics and rest.'),
(4, '2026-10-20', 'Prophylactic migraine therapy, lifestyle adjustments.'),
(5, '2026-10-22', 'Aggressive statin therapy and beta-blockers.');

-- Prescription Items (Trigger automatically deducts quantities from Medicine inventory)
INSERT INTO Prescription_Medicine (prescription_id, medicine_id, dosage, quantity, instructions) VALUES
(1, 1, '20mg', 30, 'One tablet at night after food'),
(1, 2, '50mg', 30, 'One tablet in the morning after food'),
(2, 3, '650mg', 15, 'One tablet SOS when fever exceeds 100 F'),
(2, 5, '40mg', 10, 'One tablet empty stomach in morning'),
(3, 8, '400mg', 20, 'One tablet twice daily with meals'),
(4, 3, '650mg', 10, 'One tablet on onset of severe headache'),
(5, 1, '20mg', 60, 'One tablet at bedtime for 60 days'),
(5, 7, '40mg', 5, 'Subcutaneous injection once daily');

-- Bills (Trigger automatically calculates total_amount)
INSERT INTO Bill (patient_id, admission_id, bill_date, consultation_fee, room_charges, medicine_charges, other_charges, payment_status, payment_mode) VALUES
(4, NULL, '2026-10-20', 1500.00, 0.00, 35.00, 150.00, 'Paid', 'UPI'),
(1, 1, '2026-10-18', 2400.00, 3600.00, 825.00, 4500.00, 'Paid', 'Credit Card'),
(3, 2, '2026-10-22', 2000.00, 10000.00, 120.00, 18500.00, 'Paid', 'Insurance'),
(7, 3, '2026-10-29', 3200.00, 10000.00, 950.00, 14200.00, 'Paid', 'Debit Card'),
(6, NULL, '2026-11-01', 700.00, 0.00, 0.00, 50.00, 'Paid', 'Cash'),
(5, NULL, '2026-10-22', 1200.00, 0.00, 2400.00, 500.00, 'Pending', NULL);

-- ============================================================================
-- VERIFICATION PROOF: Display Key System States
-- ============================================================================
SELECT 'DATABASE SETUP COMPLETED SUCCESSFULLY!' AS status_message;

-- Verification 1: Verify Trigger 5 auto-calculated total_amount
SELECT bill_id, patient_id, consultation_fee, room_charges, medicine_charges, other_charges, total_amount, payment_status
FROM Bill;

-- Verification 2: Verify Trigger 2 marked active admission rooms Occupied
SELECT room_id, room_number, room_type, charge_per_day, status
FROM Room;

-- Verification 3: Verify Trigger 6 deducted stock quantities
SELECT medicine_id, medicine_name, stock_quantity, manufacturer
FROM Medicine;
