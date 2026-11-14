-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM (HMS) - TRIGGER TEST & DEMONSTRATION SCRIPT
-- DBMS Course Project | 3rd Year Computer Engineering
-- Target RDBMS: MySQL 8.0+
-- File: 06_trigger_tests.sql
-- ============================================================================

USE hospital_management_db;

-- ############################################################################
-- TEST SUITE FOR TRIGGER 1: trg_prevent_future_dob
-- ############################################################################
-- 1. Trigger Name: trg_prevent_future_dob
-- 2. Purpose: Prevents inserting a patient record if date_of_birth is in the future.
-- 3. Trigger Definition:
--    DELIMITER $$
--    CREATE TRIGGER trg_prevent_future_dob BEFORE INSERT ON Patient FOR EACH ROW
--    BEGIN
--        IF NEW.date_of_birth > CURDATE() THEN
--            SIGNAL SQLSTATE '45000'
--            SET MESSAGE_TEXT = 'Validation Error: Patient Date of Birth cannot be in the future!';
--        END IF;
--    END$$
--    DELIMITER ;

-- 4. Test Statement (Should Fail with Custom Error):
-- Attempting to register an unborn patient with DOB in 2030:
-- UNCOMMENT TO TEST ERROR TRIGGER:
/*
INSERT INTO Patient (
    first_name, last_name, gender, date_of_birth, blood_group, 
    phone, email, address, city, emergency_contact
) VALUES (
    'Baby', 'Sharma', 'Male', '2030-01-01', 'O+', 
    '9999888877', 'baby.sharma@gmail.com', 'Andheri East', 'Mumbai', '9999888878'
);
*/

-- 5. Expected Output / Result:
-- ERROR 1644 (45000): Validation Error: Patient Date of Birth cannot be in the future!

-- 6. Explanation:
-- The BEFORE INSERT trigger intercepts the row before it reaches the disk. It checks
-- NEW.date_of_birth > CURDATE(). Since 2030-01-01 > CURDATE(), it fires a SIGNAL SQLSTATE '45000'
-- which halts the transaction, prevents dirty data, and displays the custom error message.


-- ############################################################################
-- TEST SUITE FOR TRIGGER 2: trg_room_occupied_on_admission
-- ############################################################################
-- 1. Trigger Name: trg_room_occupied_on_admission
-- 2. Purpose: Automatically updates room status to 'Occupied' when a patient is admitted.

-- Check Room status before admission:
SELECT room_id, room_number, room_type, status FROM Room WHERE room_id = 2;
-- Result: Room 2 ('GW-102') has status = 'Available'

-- 4. Test Statement:
-- Admit Patient 10 into Room 2 under Doctor 5:
INSERT INTO Admission (patient_id, room_id, doctor_id, admission_date, discharge_date, diagnosis)
VALUES (10, 2, 5, CURDATE(), NULL, 'Viral Pyrexia with Dehydration');

-- Check Room status immediately after admission:
SELECT room_id, room_number, room_type, status FROM Room WHERE room_id = 2;

-- 5. Expected Output / Result:
-- +---------+-------------+--------------+----------+
-- | room_id | room_number | room_type    | status   |
-- +---------+-------------+--------------+----------+
-- |       2 | GW-102      | General Ward | Occupied |
-- +---------+-------------+--------------+----------+

-- 6. Explanation:
-- An AFTER INSERT trigger on Admission detected that NEW.discharge_date IS NULL.
-- It immediately executed an UPDATE statement on the Room table matching NEW.room_id,
-- switching its status from 'Available' to 'Occupied' automatically.


-- ############################################################################
-- TEST SUITE FOR TRIGGER 3: trg_room_available_on_discharge
-- ############################################################################
-- 1. Trigger Name: trg_room_available_on_discharge
-- 2. Purpose: Automatically frees the room back to 'Available' when an inpatient's
--             discharge date is updated from NULL to a valid date.

-- Check Room status before discharge (Occupied by Patient 10 admitted above):
SELECT room_id, room_number, status FROM Room WHERE room_id = 2;
-- Result: status = 'Occupied'

-- 4. Test Statement:
-- Record discharge date for the admission:
UPDATE Admission
SET discharge_date = CURDATE()
WHERE patient_id = 10 AND room_id = 2 AND discharge_date IS NULL;

-- Check Room status immediately after discharge:
SELECT room_id, room_number, status FROM Room WHERE room_id = 2;

-- 5. Expected Output / Result:
-- +---------+-------------+-----------+
-- | room_id | room_number | status    |
-- +---------+-------------+-----------+
-- |       2 | GW-102      | Available |
-- +---------+-------------+-----------+

-- 6. Explanation:
-- An AFTER UPDATE trigger on Admission detected that OLD.discharge_date IS NULL and
-- NEW.discharge_date IS NOT NULL. This confirmed that the patient has checked out.
-- The trigger promptly executed an UPDATE on Room setting status = 'Available'.


-- ############################################################################
-- TEST SUITE FOR TRIGGER 4: trg_prevent_doctor_double_booking
-- ############################################################################
-- 1. Trigger Name: trg_prevent_doctor_double_booking
-- 2. Purpose: Ensures doctor schedule conflict prevention. Throws an error if another
--             appointment is scheduled for the same doctor at the exact same date & time.

-- Let's check an existing appointment:
-- In our sample data: Doctor 2 (Dr. Meera Reddy) has an appointment on '2026-11-06' at '10:00:00'.
SELECT appointment_id, doctor_id, appointment_date, appointment_time, status 
FROM Appointment 
WHERE doctor_id = 2 AND appointment_date = '2026-11-06' AND appointment_time = '10:00:00';

-- 4. Test Statement (Should Fail with Custom Error):
-- Attempting to book Patient 3 with Doctor 2 at the exact same slot:
-- UNCOMMENT TO TEST ERROR TRIGGER:
/*
INSERT INTO Appointment (
    patient_id, doctor_id, appointment_date, appointment_time, status, reason_for_visit
) VALUES (
    3, 2, '2026-11-06', '10:00:00', 'Scheduled', 'Second consultation on same slot'
);
*/

-- 5. Expected Output / Result:
-- ERROR 1644 (45000): Scheduling Conflict: Doctor already has an active appointment at this date and time!

-- 6. Explanation:
-- The BEFORE INSERT trigger on Appointment runs a COUNT query matching NEW.doctor_id,
-- NEW.appointment_date, and NEW.appointment_time for non-cancelled appointments.
-- Because an active record exists (count > 0), the trigger raises an unhandled user exception
-- via SIGNAL SQLSTATE '45000', aborting insertion before conflict occurs.


-- ############################################################################
-- TEST SUITE FOR TRIGGER 5: trg_calculate_total_bill_insert & update
-- ############################################################################
-- 1. Trigger Name: trg_calculate_total_bill_insert
-- 2. Purpose: Automatically computes total_amount = consultation + room + medicine + other charges.

-- 4. Test Statement:
-- Insert a new Bill without providing total_amount (or passing 0.00):
INSERT INTO Bill (
    patient_id, admission_id, bill_date, 
    consultation_fee, room_charges, medicine_charges, other_charges, 
    total_amount, payment_status, payment_mode
) VALUES (
    2, NULL, CURDATE(), 
    1500.00, 5000.00, 1250.50, 450.00, 
    0.00, 'Paid', 'UPI'
);

-- Retrieve the newly inserted bill record:
SELECT 
    bill_id, 
    patient_id, 
    consultation_fee, 
    room_charges, 
    medicine_charges, 
    other_charges, 
    total_amount, 
    payment_mode
FROM Bill
WHERE bill_id = LAST_INSERT_ID();

-- 5. Expected Output / Result:
-- +---------+------------+------------------+--------------+------------------+---------------+--------------+--------------+
-- | bill_id | patient_id | consultation_fee | room_charges | medicine_charges | other_charges | total_amount | payment_mode |
-- +---------+------------+------------------+--------------+------------------+---------------+--------------+--------------+
-- |       7 |          2 |          1500.00 |      5000.00 |          1250.50 |        450.00 |      8200.50 | UPI          |
-- +---------+------------+------------------+--------------+------------------+---------------+--------------+--------------+
-- Calculation: 1500.00 + 5000.00 + 1250.50 + 450.00 = 8200.50

-- 6. Explanation:
-- The BEFORE INSERT trigger on Bill intercepts the record and sets
-- NEW.total_amount = NEW.consultation_fee + NEW.room_charges + NEW.medicine_charges + NEW.other_charges.
-- Even though total_amount was passed as 0.00, the trigger calculated the true sum of 8200.50.


-- ############################################################################
-- TEST SUITE FOR BONUS TRIGGER 6: trg_deduct_medicine_stock
-- ############################################################################
-- 1. Trigger Name: trg_deduct_medicine_stock
-- 2. Purpose: Automatically synchronizes pharmacy inventory when a medicine is prescribed.

-- Check stock before prescription:
SELECT medicine_id, medicine_name, stock_quantity FROM Medicine WHERE medicine_id = 4;
-- Result: Medicine 4 ('Amoxicillin 500mg') has stock_quantity = 120

-- 4. Test Statement:
-- Create a new prescription item prescribing 20 units of Medicine 4 under Prescription 4:
INSERT INTO Prescription_Medicine (prescription_id, medicine_id, dosage, quantity, instructions)
VALUES (4, 4, '500mg', 20, 'Take 1 capsule thrice daily for 7 days');

-- Check stock immediately after prescription:
SELECT medicine_id, medicine_name, stock_quantity FROM Medicine WHERE medicine_id = 4;

-- 5. Expected Output / Result:
-- +-------------+-------------------+----------------+
-- | medicine_id | medicine_name     | stock_quantity |
-- +-------------+-------------------+----------------+
-- |           4 | Amoxicillin 500mg |            100 |
-- +-------------+-------------------+----------------+
-- (Stock reduced from 120 -> 100)

-- 6. Explanation:
-- The AFTER INSERT trigger on Prescription_Medicine executes:
-- UPDATE Medicine SET stock_quantity = stock_quantity - NEW.quantity WHERE medicine_id = NEW.medicine_id;
-- This eliminates manual inventory tracking and prevents human counting discrepancies.
