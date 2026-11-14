-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM (HMS) - TRIGGERS & VERIFICATION
-- DBMS Course Project | 3rd Year Computer Engineering
-- Target RDBMS: MySQL 8.0+
-- File: 02_triggers.sql
-- ============================================================================

USE hospital_management_db;

-- ============================================================================
-- TRIGGER 1: trg_prevent_future_dob
-- ============================================================================
-- 1. Trigger Name: trg_prevent_future_dob
-- 2. Purpose: Ensures medical integrity by preventing registration of any patient
--             whose Date of Birth (DOB) is in the future.
-- 3. CREATE TRIGGER Statement:
DROP TRIGGER IF EXISTS trg_prevent_future_dob;

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
DELIMITER ;

-- ============================================================================
-- TRIGGER 2: trg_room_occupied_on_admission
-- ============================================================================
-- 1. Trigger Name: trg_room_occupied_on_admission
-- 2. Purpose: Real-time bed occupancy automation. When an inpatient admission 
--             record is created, the assigned room's status automatically transitions
--             from 'Available' to 'Occupied'.
-- 3. CREATE TRIGGER Statement:
DROP TRIGGER IF EXISTS trg_room_occupied_on_admission;

DELIMITER $$
CREATE TRIGGER trg_room_occupied_on_admission
AFTER INSERT ON Admission
FOR EACH ROW
BEGIN
    -- Only set room to Occupied if the admission is currently active (discharge_date is NULL)
    IF NEW.discharge_date IS NULL THEN
        UPDATE Room
        SET status = 'Occupied'
        WHERE room_id = NEW.room_id;
    END IF;
END$$
DELIMITER ;

-- ============================================================================
-- TRIGGER 3: trg_room_available_on_discharge
-- ============================================================================
-- 1. Trigger Name: trg_room_available_on_discharge
-- 2. Purpose: Automatically frees up hospital room capacity when a patient's 
--             discharge date is recorded (transitioning from NULL to a valid date).
-- 3. CREATE TRIGGER Statement:
DROP TRIGGER IF EXISTS trg_room_available_on_discharge;

DELIMITER $$
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
DELIMITER ;

-- ============================================================================
-- TRIGGER 4: trg_prevent_doctor_double_booking
-- ============================================================================
-- 1. Trigger Name: trg_prevent_doctor_double_booking
-- 2. Purpose: Prevents scheduling conflicts by ensuring a doctor cannot be 
--             booked for two distinct appointments at the identical date and time.
-- 3. CREATE TRIGGER Statement:
DROP TRIGGER IF EXISTS trg_prevent_doctor_double_booking;

DELIMITER $$
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
DELIMITER ;

-- ============================================================================
-- TRIGGER 5: trg_calculate_total_bill_insert & trg_calculate_total_bill_update
-- ============================================================================
-- 1. Trigger Name: trg_calculate_total_bill_insert / trg_calculate_total_bill_update
-- 2. Purpose: Automated invoice calculation. Guarantees that total_amount is strictly
--             computed as the mathematical sum of consultation fees, room stay charges,
--             pharmacy medicine charges, and auxiliary costs without manual error.
-- 3. CREATE TRIGGER Statements:
DROP TRIGGER IF EXISTS trg_calculate_total_bill_insert;
DROP TRIGGER IF EXISTS trg_calculate_total_bill_update;

DELIMITER $$
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
DELIMITER ;

-- ============================================================================
-- BONUS TRIGGER 6: trg_deduct_medicine_stock
-- ============================================================================
-- 1. Trigger Name: trg_deduct_medicine_stock
-- 2. Purpose: Real-time pharmacy inventory sync. Automatically deducts prescribed
--             quantity from Medicine inventory stock upon prescription dispensing.
-- 3. CREATE TRIGGER Statement:
DROP TRIGGER IF EXISTS trg_deduct_medicine_stock;

DELIMITER $$
CREATE TRIGGER trg_deduct_medicine_stock
AFTER INSERT ON Prescription_Medicine
FOR EACH ROW
BEGIN
    UPDATE Medicine
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE medicine_id = NEW.medicine_id;
END$$
DELIMITER ;
