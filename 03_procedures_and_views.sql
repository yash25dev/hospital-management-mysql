-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM (HMS) - PROCEDURES & VIEWS
-- DBMS Course Project | 3rd Year Computer Engineering
-- Target RDBMS: MySQL 8.0+
-- File: 03_procedures_and_views.sql
-- ============================================================================

USE hospital_management_db;

-- ============================================================================
-- SECTION A: DATABASE VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- VIEW 1: vw_Doctor_Schedule
-- Purpose: Complete overview of all scheduled appointments with doctor and patient info
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- VIEW 2: vw_Active_Inpatients
-- Purpose: Real-time dashboard of currently admitted patients in hospital rooms
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- VIEW 3: vw_Comprehensive_Bill_Summary
-- Purpose: Detailed breakdown of patient billing, admissions, and payment state
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- VIEW 4: vw_Low_Stock_Medicines
-- Purpose: Automated pharmacy alert view for medicines nearing stock depletion
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- VIEW 5: vw_Department_Performance
-- Purpose: High-level management metrics across hospital departments
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_Department_Performance AS
SELECT 
    dep.department_id,
    dep.department_name,
    dep.head_of_department,
    COUNT(DISTINCT d.doctor_id) AS total_doctors,
    COUNT(DISTINCT a.appointment_id) AS total_appointments_booked,
    COUNT(DISTINCT adm.admission_id) AS total_inpatient_admissions
FROM Department dep
LEFT JOIN Doctor d ON dep.department_id = d.department_id
LEFT JOIN Appointment a ON d.doctor_id = a.doctor_id
LEFT JOIN Admission adm ON d.doctor_id = adm.doctor_id
GROUP BY dep.department_id, dep.department_name, dep.head_of_department;


-- ============================================================================
-- SECTION B: STORED PROCEDURES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PROCEDURE 1: sp_ScheduleAppointment
-- Purpose: Safely books a consultation after validating doctor & patient existence
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_ScheduleAppointment;

DELIMITER $$
CREATE PROCEDURE sp_ScheduleAppointment (
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_app_date DATE,
    IN p_app_time TIME,
    IN p_reason VARCHAR(255)
)
BEGIN
    -- Validate Patient existence
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE patient_id = p_patient_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Execution Aborted: Patient ID does not exist!';
    END IF;

    -- Validate Doctor existence and active status
    IF NOT EXISTS (SELECT 1 FROM Doctor WHERE doctor_id = p_doctor_id AND status = 'Active') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Execution Aborted: Doctor ID does not exist or doctor is not Active!';
    END IF;

    -- Insert appointment record (trg_prevent_doctor_double_booking will automatically validate slot)
    INSERT INTO Appointment (patient_id, doctor_id, appointment_date, appointment_time, status, reason_for_visit)
    VALUES (p_patient_id, p_doctor_id, p_app_date, p_app_time, 'Scheduled', p_reason);

    SELECT 
        LAST_INSERT_ID() AS booked_appointment_id,
        'Appointment successfully booked' AS message;
END$$
DELIMITER ;

-- ----------------------------------------------------------------------------
-- PROCEDURE 2: sp_AdmitPatient
-- Purpose: Admits a patient to an available room, firing trigger to update room status
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_AdmitPatient;

DELIMITER $$
CREATE PROCEDURE sp_AdmitPatient (
    IN p_patient_id INT,
    IN p_room_id INT,
    IN p_doctor_id INT,
    IN p_diagnosis VARCHAR(255)
)
BEGIN
    DECLARE v_room_status VARCHAR(20);

    -- Check if room exists and get status
    SELECT status INTO v_room_status
    FROM Room
    WHERE room_id = p_room_id;

    IF v_room_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Execution Aborted: Specified Room does not exist!';
    ELSEIF v_room_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Admission Error: Selected Room is not Available for admission!';
    END IF;

    -- Insert admission (Triggers trg_room_occupied_on_admission)
    INSERT INTO Admission (patient_id, room_id, doctor_id, admission_date, discharge_date, diagnosis)
    VALUES (p_patient_id, p_room_id, p_doctor_id, CURDATE(), NULL, p_diagnosis);

    SELECT 
        LAST_INSERT_ID() AS new_admission_id,
        p_room_id AS room_assigned,
        'Patient admitted successfully and Room status set to Occupied' AS confirmation;
END$$
DELIMITER ;

-- ----------------------------------------------------------------------------
-- PROCEDURE 3: sp_DischargePatientAndGenerateBill
-- Purpose: Discharges inpatient, frees room, computes room stay fee, and generates bill
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_DischargePatientAndGenerateBill;

DELIMITER $$
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

    -- Verify active admission record
    SELECT patient_id, room_id, doctor_id, admission_date
    INTO v_patient_id, v_room_id, v_doctor_id, v_adm_date
    FROM Admission
    WHERE admission_id = p_admission_id AND discharge_date IS NULL;

    IF v_patient_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Discharge Error: Valid active admission not found or patient already discharged!';
    END IF;

    -- Calculate length of stay (minimum 1 day for same-day discharge calculation)
    SET v_days_stayed = GREATEST(DATEDIFF(CURDATE(), v_adm_date), 1);

    -- Retrieve Room charge per day
    SELECT charge_per_day INTO v_charge_per_day FROM Room WHERE room_id = v_room_id;
    SET v_total_room_cost = v_days_stayed * v_charge_per_day;

    -- Retrieve Doctor consultation fee
    SELECT consultation_fee INTO v_consultation_fee FROM Doctor WHERE doctor_id = v_doctor_id;

    -- Update Admission with discharge date (Fires trg_room_available_on_discharge)
    UPDATE Admission
    SET discharge_date = CURDATE()
    WHERE admission_id = p_admission_id;

    -- Insert into Bill (Fires trg_calculate_total_bill_insert to compute total_amount)
    INSERT INTO Bill (
        patient_id, 
        admission_id, 
        bill_date, 
        consultation_fee, 
        room_charges, 
        medicine_charges, 
        other_charges, 
        payment_status, 
        payment_mode
    ) VALUES (
        v_patient_id,
        p_admission_id,
        CURDATE(),
        v_consultation_fee,
        v_total_room_cost,
        0.00,
        COALESCE(p_other_charges, 0.00),
        'Paid',
        p_payment_mode
    );

    SET v_new_bill_id = LAST_INSERT_ID();

    -- Return comprehensive discharge invoice
    SELECT 
        b.bill_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        r.room_number,
        v_days_stayed AS days_stayed,
        b.consultation_fee,
        b.room_charges,
        b.other_charges,
        b.total_amount,
        b.payment_status,
        b.payment_mode
    FROM Bill b
    JOIN Patient p ON b.patient_id = p.patient_id
    JOIN Room r ON r.room_id = v_room_id
    WHERE b.bill_id = v_new_bill_id;
END$$
DELIMITER ;

-- ----------------------------------------------------------------------------
-- PROCEDURE 4: sp_GetPatientHistory
-- Purpose: Complete medical and transactional audit trail for an individual patient
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_GetPatientHistory;

DELIMITER $$
CREATE PROCEDURE sp_GetPatientHistory (
    IN p_patient_id INT
)
BEGIN
    -- Result Set 1: Patient Profile
    SELECT 
        patient_id,
        CONCAT(first_name, ' ', last_name) AS full_name,
        gender,
        date_of_birth,
        TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age,
        blood_group,
        phone,
        city
    FROM Patient
    WHERE patient_id = p_patient_id;

    -- Result Set 2: Appointment History
    SELECT 
        a.appointment_id,
        a.appointment_date,
        a.appointment_time,
        CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS doctor_name,
        dep.department_name,
        a.status,
        a.reason_for_visit
    FROM Appointment a
    JOIN Doctor d ON a.doctor_id = d.doctor_id
    JOIN Department dep ON d.department_id = dep.department_id
    WHERE a.patient_id = p_patient_id
    ORDER BY a.appointment_date DESC;

    -- Result Set 3: Inpatient Admissions
    SELECT 
        adm.admission_id,
        r.room_number,
        r.room_type,
        adm.admission_date,
        adm.discharge_date,
        adm.diagnosis,
        CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS doctor_name
    FROM Admission adm
    JOIN Room r ON adm.room_id = r.room_id
    JOIN Doctor d ON adm.doctor_id = d.doctor_id
    WHERE adm.patient_id = p_patient_id;

    -- Result Set 4: Billing History
    SELECT 
        bill_id,
        bill_date,
        total_amount,
        payment_status,
        payment_mode
    FROM Bill
    WHERE patient_id = p_patient_id;
END$$
DELIMITER ;
