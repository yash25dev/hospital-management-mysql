-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM (HMS) - REALISTIC SAMPLE DATA
-- DBMS Course Project | 3rd Year Computer Engineering
-- Target RDBMS: MySQL 8.0+
-- File: 04_data.sql
-- ============================================================================

USE hospital_management_db;

-- ----------------------------------------------------------------------------
-- 1. INSERT DATA: Department (6 Records)
-- ----------------------------------------------------------------------------
INSERT INTO Department (department_name, head_of_department, contact_extension) VALUES
('Cardiology', 'Dr. Arun Mehta', '101'),
('Neurology', 'Dr. Ramesh Iyer', '102'),
('Orthopedics', 'Dr. Vikram Rathore', '103'),
('General Medicine', 'Dr. Sunita Deshmukh', '104'),
('Pediatrics', 'Dr. Kavita Nair', '105'),
('Oncology', 'Dr. Sanjay Kulkarni', '106');

-- ----------------------------------------------------------------------------
-- 2. INSERT DATA: Doctor (8 Records across departments)
-- ----------------------------------------------------------------------------
INSERT INTO Doctor (department_id, first_name, last_name, specialization, phone, email, consultation_fee, joining_date, status) VALUES
(1, 'Arun', 'Mehta', 'Senior Interventional Cardiologist', '9820111001', 'arun.mehta@cityhospital.in', 1200.00, '2016-04-10', 'Active'),
(1, 'Meera', 'Reddy', 'Associate Cardiologist', '9820111002', 'meera.reddy@cityhospital.in', 900.00, '2019-08-15', 'Active'),
(2, 'Ramesh', 'Iyer', 'Chief Neurosurgeon', '9820111003', 'ramesh.iyer@cityhospital.in', 1500.00, '2014-02-01', 'Active'),
(3, 'Vikram', 'Rathore', 'Senior Orthopedic Surgeon', '9820111004', 'vikram.rathore@cityhospital.in', 1000.00, '2017-06-20', 'Active'),
(4, 'Sunita', 'Deshmukh', 'General Physician & Diabetologist', '9820111005', 'sunita.deshmukh@cityhospital.in', 600.00, '2015-11-12', 'Active'),
(4, 'Neha', 'Agarwal', 'Consultant Physician', '9820111006', 'neha.agarwal@cityhospital.in', 550.00, '2021-03-01', 'Active'),
(5, 'Kavita', 'Nair', 'Consultant Pediatrician', '9820111007', 'kavita.nair@cityhospital.in', 700.00, '2018-09-05', 'Active'),
(6, 'Sanjay', 'Kulkarni', 'Surgical Oncologist', '9820111008', 'sanjay.kulkarni@cityhospital.in', 1600.00, '2013-01-10', 'Active');

-- ----------------------------------------------------------------------------
-- 3. INSERT DATA: Patient (10 Realistic Indian Patients)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 4. INSERT DATA: Room (8 Rooms across all types)
-- ----------------------------------------------------------------------------
INSERT INTO Room (room_number, room_type, charge_per_day, status) VALUES
('GW-101', 'General Ward', 1200.00, 'Available'),
('GW-102', 'General Ward', 1200.00, 'Available'),
('SP-201', 'Semi-Private', 2500.00, 'Available'),
('SP-202', 'Semi-Private', 2500.00, 'Available'),
('PD-301', 'Private Deluxe', 5000.00, 'Available'),
('PD-302', 'Private Deluxe', 5000.00, 'Available'),
('ICU-01', 'ICU', 9500.00, 'Available'),
('ICU-02', 'ICU', 9500.00, 'Available');

-- ----------------------------------------------------------------------------
-- 5. INSERT DATA: Appointment (10 Consultations)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 6. INSERT DATA: Admission (5 Inpatients - 3 Discharged, 2 Currently Active)
-- Note: Trigger trg_room_occupied_on_admission will automatically set Room 5 (PD-301)
--       and Room 7 (ICU-01) to 'Occupied' for active admissions!
-- ----------------------------------------------------------------------------
-- Discharged admissions (historical)
INSERT INTO Admission (patient_id, room_id, doctor_id, admission_date, discharge_date, diagnosis) VALUES
(1, 1, 1, '2026-10-15', '2026-10-18', 'Acute Angina Pectoris - Stabilized'),
(3, 3, 4, '2026-10-18', '2026-10-22', 'Arthroscopic ACL Reconstruction surgery'),
(7, 4, 8, '2026-10-25', '2026-10-29', 'Chemotherapy Cycle 3 Inpatient Care');

-- Active admissions (currently in hospital)
INSERT INTO Admission (patient_id, room_id, doctor_id, admission_date, discharge_date, diagnosis) VALUES
(5, 7, 1, '2026-11-02', NULL, 'Acute Myocardial Infarction - Critical Monitoring'),
(2, 5, 5, '2026-11-03', NULL, 'Severe Dengue with Thrombocytopenia');

-- ----------------------------------------------------------------------------
-- 7. INSERT DATA: Medicine (10 Pharmacy Items)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 8. INSERT DATA: Prescription (5 Prescriptions)
-- ----------------------------------------------------------------------------
INSERT INTO Prescription (appointment_id, prescription_date, clinical_notes) VALUES
(1, '2026-10-15', 'Lipid control regimen and blood pressure regulation.'),
(2, '2026-10-16', 'Hydration therapy, antipyretic for fever relief.'),
(3, '2026-10-18', 'Post-injury anti-inflammatory analgesics and rest.'),
(4, '2026-10-20', 'Prophylactic migraine therapy, lifestyle adjustments.'),
(5, '2026-10-22', 'Aggressive statin therapy and beta-blockers.');

-- ----------------------------------------------------------------------------
-- 9. INSERT DATA: Prescription_Medicine (Items linked to prescriptions)
-- Note: Trigger trg_deduct_medicine_stock will automatically deduct these quantities!
-- ----------------------------------------------------------------------------
INSERT INTO Prescription_Medicine (prescription_id, medicine_id, dosage, quantity, instructions) VALUES
(1, 1, '20mg', 30, 'One tablet at night after food'),
(1, 2, '50mg', 30, 'One tablet in the morning after food'),
(2, 3, '650mg', 15, 'One tablet SOS when fever exceeds 100 F'),
(2, 5, '40mg', 10, 'One tablet empty stomach in morning'),
(3, 8, '400mg', 20, 'One tablet twice daily with meals'),
(4, 3, '650mg', 10, 'One tablet on onset of severe headache'),
(5, 1, '20mg', 60, 'One tablet at bedtime for 60 days'),
(5, 7, '40mg', 5, 'Subcutaneous injection once daily');

-- ----------------------------------------------------------------------------
-- 10. INSERT DATA: Bill (6 Invoices)
-- Note: Trigger trg_calculate_total_bill_insert will compute total_amount!
-- ----------------------------------------------------------------------------
-- Bill 1: Outpatient Consultation + Pharmacy
INSERT INTO Bill (patient_id, admission_id, bill_date, consultation_fee, room_charges, medicine_charges, other_charges, payment_status, payment_mode) VALUES
(4, NULL, '2026-10-20', 1500.00, 0.00, 35.00, 150.00, 'Paid', 'UPI');

-- Bill 2: Discharged Inpatient 1 (3 days in General Ward @ 1200/day + surgery/tests)
INSERT INTO Bill (patient_id, admission_id, bill_date, consultation_fee, room_charges, medicine_charges, other_charges, payment_status, payment_mode) VALUES
(1, 1, '2026-10-18', 2400.00, 3600.00, 825.00, 4500.00, 'Paid', 'Credit Card');

-- Bill 3: Discharged Inpatient 2 (4 days Semi-Private @ 2500/day + surgery)
INSERT INTO Bill (patient_id, admission_id, bill_date, consultation_fee, room_charges, medicine_charges, other_charges, payment_status, payment_mode) VALUES
(3, 2, '2026-10-22', 2000.00, 10000.00, 120.00, 18500.00, 'Paid', 'Insurance');

-- Bill 4: Discharged Inpatient 3 (4 days Semi-Private @ 2500/day + chemo)
INSERT INTO Bill (patient_id, admission_id, bill_date, consultation_fee, room_charges, medicine_charges, other_charges, payment_status, payment_mode) VALUES
(7, 3, '2026-10-29', 3200.00, 10000.00, 950.00, 14200.00, 'Paid', 'Debit Card');

-- Bill 5: Outpatient Consultation
INSERT INTO Bill (patient_id, admission_id, bill_date, consultation_fee, room_charges, medicine_charges, other_charges, payment_status, payment_mode) VALUES
(6, NULL, '2026-11-01', 700.00, 0.00, 0.00, 50.00, 'Paid', 'Cash');

-- Bill 6: Pending Outpatient Check
INSERT INTO Bill (patient_id, admission_id, bill_date, consultation_fee, room_charges, medicine_charges, other_charges, payment_status, payment_mode) VALUES
(5, NULL, '2026-10-22', 1200.00, 0.00, 2400.00, 500.00, 'Pending', NULL);
