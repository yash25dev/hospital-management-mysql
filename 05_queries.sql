-- ============================================================================
-- HOSPITAL MANAGEMENT SYSTEM (HMS) - 22 ESSENTIAL SQL QUERIES & SAMPLE OUTPUTS
-- DBMS Course Project | 3rd Year Computer Engineering
-- Target RDBMS: MySQL 8.0+
-- File: 05_queries.sql
-- ============================================================================

USE hospital_management_db;

-- ============================================================================
-- QUERY 1: Display all registered patients
-- Concept: Basic SELECT, column aliasing, and age calculation
-- ============================================================================
SELECT 
    patient_id,
    CONCAT(first_name, ' ', last_name) AS patient_name,
    gender,
    TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age,
    blood_group,
    phone,
    city
FROM Patient
ORDER BY patient_id ASC;

/*
SAMPLE OUTPUT:
+------------+------------------+--------+-----+-------------+------------+-------------+
| patient_id | patient_name     | gender | age | blood_group | phone      | city        |
+------------+------------------+--------+-----+-------------+------------+-------------+
|          1 | Rajesh Verma     | Male   |  44 | B+          | 9819001122 | Mumbai      |
|          2 | Sneha Kulkarni   | Female |  36 | O+          | 9822334455 | Pune        |
|          3 | Amit Sharma      | Male   |  51 | A+          | 9833445566 | Delhi       |
|          4 | Priya Nair       | Female |  31 | AB+         | 9844556677 | Bangalore   |
|          5 | Vikram Malhotra  | Male   |  58 | O-          | 9855667788 | Hyderabad   |
|          6 | Ananya Joshi     | Female |  25 | A-          | 9866778899 | Pune        |
|          7 | Suresh Patel     | Male   |  66 | B+          | 9877889900 | Ahmedabad   |
|          8 | Pooja Deshmukh   | Female |  38 | B-          | 9888990011 | Navi Mumbai |
|          9 | Rohan Gupta      | Male   |  10 | O+          | 9899001122 | Jaipur      |
|         10 | Sunita Rao       | Female |  54 | AB-         | 9811223344 | Chennai     |
+------------+------------------+--------+-----+-------------+------------+-------------+
*/

-- ============================================================================
-- QUERY 2: Display all doctors along with their department names
-- Concept: INNER JOIN between Doctor and Department
-- ============================================================================
SELECT 
    d.doctor_id,
    CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS doctor_name,
    dep.department_name,
    d.specialization,
    d.consultation_fee,
    d.phone
FROM Doctor d
INNER JOIN Department dep ON d.department_id = dep.department_id
ORDER BY dep.department_name, d.first_name;

/*
SAMPLE OUTPUT:
+-----------+----------------------+------------------+------------------------------------+------------------+------------+
| doctor_id | doctor_name          | department_name  | specialization                     | consultation_fee | phone      |
+-----------+----------------------+------------------+------------------------------------+------------------+------------+
|         1 | Dr. Arun Mehta       | Cardiology       | Senior Interventional Cardiologist |          1200.00 | 9820111001 |
|         2 | Dr. Meera Reddy      | Cardiology       | Associate Cardiologist             |           900.00 | 9820111002 |
|         6 | Dr. Neha Agarwal     | General Medicine | Consultant Physician               |           550.00 | 9820111006 |
|         5 | Dr. Sunita Deshmukh  | General Medicine | General Physician & Diabetologist  |           600.00 | 9820111005 |
|         3 | Dr. Ramesh Iyer      | Neurology        | Chief Neurosurgeon                 |          1500.00 | 9820111003 |
|         8 | Dr. Sanjay Kulkarni  | Oncology         | Surgical Oncologist                |          1600.00 | 9820111008 |
|         4 | Dr. Vikram Rathore   | Orthopedics      | Senior Orthopedic Surgeon          |          1000.00 | 9820111004 |
|         7 | Dr. Kavita Nair      | Pediatrics       | Consultant Pediatrician            |           700.00 | 9820111007 |
+-----------+----------------------+------------------+------------------------------------+------------------+------------+
*/

-- ============================================================================
-- QUERY 3: Display doctors belonging to the 'Cardiology' department
-- Concept: JOIN with WHERE filtering on parent table attribute
-- ============================================================================
SELECT 
    d.doctor_id,
    CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    d.consultation_fee,
    d.email
FROM Doctor d
JOIN Department dep ON d.department_id = dep.department_id
WHERE dep.department_name = 'Cardiology';

/*
SAMPLE OUTPUT:
+-----------+-----------------+------------------------------------+------------------+----------------------------+
| doctor_id | doctor_name     | specialization                     | consultation_fee | email                      |
+-----------+-----------------+------------------------------------+------------------+----------------------------+
|         1 | Dr. Arun Mehta  | Senior Interventional Cardiologist |          1200.00 | arun.mehta@cityhospital.in |
|         2 | Dr. Meera Reddy | Associate Cardiologist             |           900.00 | meera.reddy@cityhospital.in|
+-----------+-----------------+------------------------------------+------------------+----------------------------+
*/

-- ============================================================================
-- QUERY 4: Display patients having appointments with a particular doctor (Dr. Arun Mehta)
-- Concept: Multi-table JOIN (Patient -> Appointment -> Doctor) with WHERE
-- ============================================================================
SELECT 
    a.appointment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.phone AS patient_phone,
    a.appointment_date,
    a.appointment_time,
    a.status,
    a.reason_for_visit
FROM Patient p
JOIN Appointment a ON p.patient_id = a.patient_id
JOIN Doctor d ON a.doctor_id = d.doctor_id
WHERE d.first_name = 'Arun' AND d.last_name = 'Mehta';

/*
SAMPLE OUTPUT:
+----------------+-----------------+---------------+------------------+------------------+-----------+-----------------------------------------+
| appointment_id | patient_name    | patient_phone | appointment_date | appointment_time | status    | reason_for_visit                        |
+----------------+-----------------+---------------+------------------+------------------+-----------+-----------------------------------------+
|              1 | Rajesh Verma    | 9819001122    | 2026-10-15       | 10:00:00         | Completed | Routine cardiac stress evaluation       |
|              5 | Vikram Malhotra | 9855667788    | 2026-10-22       | 10:30:00         | Completed | Chest discomfort & hypertension review  |
+----------------+-----------------+---------------+------------------+------------------+-----------+-----------------------------------------+
*/

-- ============================================================================
-- QUERY 5: Display appointments on a particular date ('2026-11-06')
-- Concept: Date filtering with multi-entity joins
-- ============================================================================
SELECT 
    a.appointment_id,
    a.appointment_time,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS doctor_name,
    dep.department_name,
    a.status
FROM Appointment a
JOIN Patient p ON a.patient_id = p.patient_id
JOIN Doctor d ON a.doctor_id = d.doctor_id
JOIN Department dep ON d.department_id = dep.department_id
WHERE a.appointment_date = '2026-11-06'
ORDER BY a.appointment_time ASC;

/*
SAMPLE OUTPUT:
+----------------+------------------+----------------+-----------------+-----------------+-----------+
| appointment_id | appointment_time | patient_name   | doctor_name     | department_name | status    |
+----------------+------------------+----------------+-----------------+-----------------+-----------+
|              8 | 10:00:00         | Pooja Deshmukh | Dr. Meera Reddy | Cardiology      | Scheduled |
|              9 | 11:00:00         | Rohan Gupta    | Dr. Kavita Nair | Pediatrics      | Scheduled |
+----------------+------------------+----------------+-----------------+-----------------+-----------+
*/

-- ============================================================================
-- QUERY 6: Display all currently available rooms
-- Concept: Filtering on ENUM status attribute with ORDER BY charge
-- ============================================================================
SELECT 
    room_id,
    room_number,
    room_type,
    charge_per_day,
    status
FROM Room
WHERE status = 'Available'
ORDER BY charge_per_day ASC;

/*
SAMPLE OUTPUT:
+---------+-------------+---------------+----------------+-----------+
| room_id | room_number | room_type     | charge_per_day | status    |
+---------+-------------+---------------+----------------+-----------+
|       1 | GW-101      | General Ward  |        1200.00 | Available |
|       2 | GW-102      | General Ward  |        1200.00 | Available |
|       3 | SP-201      | Semi-Private  |        2500.00 | Available |
|       4 | SP-202      | Semi-Private  |        2500.00 | Available |
|       6 | PD-302      | Private Deluxe|        5000.00 | Available |
|       8 | ICU-02      | ICU           |        9500.00 | Available |
+---------+-------------+---------------+----------------+-----------+
*/

-- ============================================================================
-- QUERY 7: Display currently admitted patients (Inpatients)
-- Concept: IS NULL check on discharge_date with multi-table JOINs
-- ============================================================================
SELECT 
    adm.admission_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.blood_group,
    r.room_number,
    r.room_type,
    adm.admission_date,
    DATEDIFF(CURDATE(), adm.admission_date) AS days_stayed,
    adm.diagnosis,
    CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS attending_doctor
FROM Admission adm
JOIN Patient p ON adm.patient_id = p.patient_id
JOIN Room r ON adm.room_id = r.room_id
JOIN Doctor d ON adm.doctor_id = d.doctor_id
WHERE adm.discharge_date IS NULL;

/*
SAMPLE OUTPUT:
+--------------+-----------------+-------------+-------------+----------------+----------------+-------------+------------------------------------+---------------------+
| admission_id | patient_name    | blood_group | room_number | room_type      | admission_date | days_stayed | diagnosis                          | attending_doctor    |
+--------------+-----------------+-------------+-------------+----------------+----------------+-------------+------------------------------------+---------------------+
|            4 | Vikram Malhotra | O-          | ICU-01      | ICU            | 2026-11-02     |           3 | Acute Myocardial Infarction        | Dr. Arun Mehta      |
|            5 | Sneha Kulkarni  | O+          | PD-301      | Private Deluxe | 2026-11-03     |           2 | Severe Dengue with Thrombocytopenia| Dr. Sunita Deshmukh |
+--------------+-----------------+-------------+-------------+----------------+----------------+-------------+------------------------------------+---------------------+
*/

-- ============================================================================
-- QUERY 8: Display medicines below a particular stock level (<= 40 units)
-- Concept: Numeric comparison with conditional alerting and ORDER BY
-- ============================================================================
SELECT 
    medicine_id,
    medicine_name,
    category,
    unit_price,
    stock_quantity,
    manufacturer
FROM Medicine
WHERE stock_quantity <= 40
ORDER BY stock_quantity ASC;

/*
SAMPLE OUTPUT:
+-------------+---------------------+-----------------------+------------+----------------+------------------------+
| medicine_id | medicine_name       | category              | unit_price | stock_quantity | manufacturer           |
+-------------+---------------------+-----------------------+------------+----------------+------------------------+
|           7 | Enoxaparin 40mg Inj | Anticoagulant         |     480.00 |             15 | Sanofi India           |
|          10 | Ondansetron 4mg     | Antiemetic            |       8.50 |             30 | Cipla Ltd              |
|           6 | Ceftriaxone 1g Inj  | Injectable Antibiotic |     145.00 |             35 | Dr. Reddy Laboratories |
+-------------+---------------------+-----------------------+------------+----------------+------------------------+
*/

-- ============================================================================
-- QUERY 9: Display bills above ₹5,000
-- Concept: Financial threshold filtering with customer and mode correlation
-- ============================================================================
SELECT 
    b.bill_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    b.bill_date,
    b.room_charges,
    b.medicine_charges,
    b.total_amount,
    b.payment_status,
    b.payment_mode
FROM Bill b
JOIN Patient p ON b.patient_id = p.patient_id
WHERE b.total_amount > 5000.00
ORDER BY b.total_amount DESC;

/*
SAMPLE OUTPUT:
+---------+--------------+------------+--------------+------------------+--------------+----------------+--------------+
| bill_id | patient_name | bill_date  | room_charges | medicine_charges | total_amount | payment_status | payment_mode |
+---------+--------------+------------+--------------+------------------+--------------+----------------+--------------+
|       3 | Amit Sharma  | 2026-10-22 |     10000.00 |           120.00 |     30620.00 | Paid           | Insurance    |
|       4 | Suresh Patel | 2026-10-29 |     10000.00 |           950.00 |     28350.00 | Paid           | Debit Card   |
|       2 | Rajesh Verma | 2026-10-18 |      3600.00 |           825.00 |     11325.00 | Paid           | Credit Card  |
+---------+--------------+------------+--------------+------------------+--------------+----------------+--------------+
*/

-- ============================================================================
-- QUERY 10: Find the highest bill amount and the patient who paid it
-- Concept: Scalar Subquery with MAX() aggregate function
-- ============================================================================
SELECT 
    b.bill_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    b.bill_date,
    b.total_amount,
    b.payment_mode
FROM Bill b
JOIN Patient p ON b.patient_id = p.patient_id
WHERE b.total_amount = (SELECT MAX(total_amount) FROM Bill);

/*
SAMPLE OUTPUT:
+---------+--------------+------------+--------------+--------------+
| bill_id | patient_name | bill_date  | total_amount | payment_mode |
+---------+--------------+------------+--------------+--------------+
|       3 | Amit Sharma  | 2026-10-22 |     30620.00 | Insurance    |
+---------+--------------+------------+--------------+--------------+
*/

-- ============================================================================
-- QUERY 11: Summary statistics of all hospital bills
-- Concept: Comprehensive Aggregate Functions (COUNT, SUM, AVG, MIN, MAX)
-- ============================================================================
SELECT 
    COUNT(*) AS total_bills_generated,
    SUM(total_amount) AS total_revenue_generated,
    ROUND(AVG(total_amount), 2) AS average_bill_amount,
    MIN(total_amount) AS minimum_bill_amount,
    MAX(total_amount) AS maximum_bill_amount
FROM Bill;

/*
SAMPLE OUTPUT:
+-----------------------+-------------------------+---------------------+---------------------+---------------------+
| total_bills_generated | total_revenue_generated | average_bill_amount | minimum_bill_amount | maximum_bill_amount |
+-----------------------+-------------------------+---------------------+---------------------+---------------------+
|                     6 |                76730.00 |            12788.33 |              750.00 |            30620.00 |
+-----------------------+-------------------------+---------------------+---------------------+---------------------+
*/

-- ============================================================================
-- QUERY 12: Count patients department-wise
-- Concept: GROUP BY with COUNT(DISTINCT) across joined tables
-- ============================================================================
SELECT 
    dep.department_id,
    dep.department_name,
    COUNT(DISTINCT a.patient_id) AS total_distinct_patients
FROM Department dep
LEFT JOIN Doctor d ON dep.department_id = d.department_id
LEFT JOIN Appointment a ON d.doctor_id = a.doctor_id
GROUP BY dep.department_id, dep.department_name
ORDER BY total_distinct_patients DESC;

/*
SAMPLE OUTPUT:
+---------------+------------------+-------------------------+
| department_id | department_name  | total_distinct_patients |
+---------------+------------------+-------------------------+
|             1 | Cardiology       |                       3 |
|             5 | Pediatrics       |                       2 |
|             2 | Neurology        |                       1 |
|             3 | Orthopedics      |                       1 |
|             4 | General Medicine |                       2 |
|             6 | Oncology         |                       1 |
+---------------+------------------+-------------------------+
*/

-- ============================================================================
-- QUERY 13: Count appointments per doctor having more than 1 appointment
-- Concept: GROUP BY with HAVING clause and COUNT()
-- ============================================================================
SELECT 
    d.doctor_id,
    CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS doctor_name,
    dep.department_name,
    COUNT(a.appointment_id) AS total_appointments
FROM Doctor d
JOIN Department dep ON d.department_id = dep.department_id
JOIN Appointment a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, doctor_name, dep.department_name
HAVING COUNT(a.appointment_id) > 1
ORDER BY total_appointments DESC;

/*
SAMPLE OUTPUT:
+-----------+-----------------+-----------------+--------------------+
| doctor_id | doctor_name     | department_name | total_appointments |
+-----------+-----------------+-----------------+--------------------+
|         1 | Dr. Arun Mehta  | Cardiology      |                  2 |
|         7 | Dr. Kavita Nair | Pediatrics      |                  2 |
+-----------+-----------------+-----------------+--------------------+
*/

-- ============================================================================
-- QUERY 14: Find patients residing in Mumbai, Pune, or Bangalore
-- Concept: IN operator for set-membership matching
-- ============================================================================
SELECT 
    patient_id,
    CONCAT(first_name, ' ', last_name) AS patient_name,
    city,
    blood_group,
    phone
FROM Patient
WHERE city IN ('Mumbai', 'Pune', 'Bangalore')
ORDER BY city, patient_name;

/*
SAMPLE OUTPUT:
+------------+----------------+-----------+-------------+------------+
| patient_id | patient_name   | city      | blood_group | phone      |
+------------+----------------+-----------+-------------+------------+
|          4 | Priya Nair     | Bangalore | AB+         | 9844556677 |
|          1 | Rajesh Verma   | Mumbai    | B+          | 9819001122 |
|          6 | Ananya Joshi   | Pune      | A-          | 9866778899 |
|          2 | Sneha Kulkarni | Pune      | O+          | 9822334455 |
+------------+----------------+-----------+-------------+------------+
*/

-- ============================================================================
-- QUERY 15: Find doctors whose specialization contains 'Cardio' or 'Surgeon'
-- Concept: Pattern matching using LIKE operator with % wildcard
-- ============================================================================
SELECT 
    doctor_id,
    CONCAT('Dr. ', first_name, ' ', last_name) AS doctor_name,
    specialization,
    consultation_fee
FROM Doctor
WHERE specialization LIKE '%Cardio%' OR specialization LIKE '%Surgeon%'
ORDER BY consultation_fee DESC;

/*
SAMPLE OUTPUT:
+-----------+---------------------+------------------------------------+------------------+
| doctor_id | doctor_name         | specialization                     | consultation_fee |
+-----------+---------------------+------------------------------------+------------------+
|         8 | Dr. Sanjay Kulkarni | Surgical Oncologist                |          1600.00 |
|         3 | Dr. Ramesh Iyer     | Chief Neurosurgeon                 |          1500.00 |
|         1 | Dr. Arun Mehta      | Senior Interventional Cardiologist |          1200.00 |
|         4 | Dr. Vikram Rathore  | Senior Orthopedic Surgeon          |          1000.00 |
|         2 | Dr. Meera Reddy     | Associate Cardiologist             |           900.00 |
+-----------+---------------------+------------------------------------+------------------+
*/

-- ============================================================================
-- QUERY 16: Find medicines with unit price between ₹10.00 and ₹200.00
-- Concept: Range filtering using BETWEEN operator
-- ============================================================================
SELECT 
    medicine_id,
    medicine_name,
    category,
    unit_price,
    stock_quantity
FROM Medicine
WHERE unit_price BETWEEN 10.00 AND 200.00
ORDER BY unit_price DESC;

/*
SAMPLE OUTPUT:
+-------------+---------------------+-----------------------+------------+----------------+
| medicine_id | medicine_name       | category              | unit_price | stock_quantity |
+-------------+---------------------+-----------------------+------------+----------------+
|           6 | Ceftriaxone 1g Inj  | Injectable Antibiotic |     145.00 |             35 |
|           4 | Amoxicillin 500mg   | Antibiotic            |      18.00 |            120 |
|           1 | Atorvastatin 20mg   | Cardiovascular        |      15.50 |            160 |
|           2 | Metoprolol 50mg     | Cardiovascular        |      12.00 |            150 |
+-------------+---------------------+-----------------------+------------+----------------+
*/

-- ============================================================================
-- QUERY 17: List all distinct blood groups among registered patients
-- Concept: DISTINCT operator
-- ============================================================================
SELECT DISTINCT 
    blood_group
FROM Patient
ORDER BY blood_group ASC;

/*
SAMPLE OUTPUT:
+-------------+
| blood_group |
+-------------+
| A+          |
| A-          |
| AB+         |
| AB-         |
| B+          |
| B-          |
| O+          |
| O-          |
+-------------+
*/

-- ============================================================================
-- QUERY 18: Multi-table JOIN: Complete Prescription & Dispensation Audit Trail
-- Concept: Complex 5-table JOIN (Patient + Doctor + Appointment + Prescription + Prescription_Medicine + Medicine)
-- ============================================================================
SELECT 
    pr.prescription_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS prescribing_doctor,
    pr.prescription_date,
    m.medicine_name,
    pm.dosage,
    pm.quantity,
    pm.instructions
FROM Prescription pr
JOIN Appointment a ON pr.appointment_id = a.appointment_id
JOIN Patient p ON a.patient_id = p.patient_id
JOIN Doctor d ON a.doctor_id = d.doctor_id
JOIN Prescription_Medicine pm ON pr.prescription_id = pm.prescription_id
JOIN Medicine m ON pm.medicine_id = m.medicine_id
ORDER BY pr.prescription_id, m.medicine_name;

/*
SAMPLE OUTPUT:
+-----------------+-----------------+--------------------+-------------------+---------------------+--------+----------+-------------------------------------+
| prescription_id | patient_name    | prescribing_doctor | prescription_date | medicine_name       | dosage | quantity | instructions                        |
+-----------------+-----------------+--------------------+-------------------+---------------------+--------+----------+-------------------------------------+
|               1 | Rajesh Verma    | Dr. Arun Mehta     | 2026-10-15        | Atorvastatin 20mg   | 20mg   |       30 | One tablet at night after food      |
|               1 | Rajesh Verma    | Dr. Arun Mehta     | 2026-10-15        | Metoprolol 50mg     | 50mg   |       30 | One tablet in the morning after food|
|               2 | Sneha Kulkarni  | Dr. Sunita Deshmuk | 2026-10-16        | Pantoprazole 40mg   | 40mg   |       10 | One tablet empty stomach in morning |
|               2 | Sneha Kulkarni  | Dr. Sunita Deshmuk | 2026-10-16        | Paracetamol 650mg   | 650mg  |       15 | One tablet SOS when fever > 100 F   |
|               3 | Amit Sharma     | Dr. Vikram Rathore | 2026-10-18        | Ibuprofen 400mg     | 400mg  |       20 | One tablet twice daily with meals   |
|               4 | Priya Nair      | Dr. Ramesh Iyer    | 2026-10-20        | Paracetamol 650mg   | 650mg  |       10 | One tablet on onset of headache     |
|               5 | Vikram Malhotra | Dr. Arun Mehta     | 2026-10-22        | Atorvastatin 20mg   | 20mg   |       60 | One tablet at bedtime for 60 days   |
|               5 | Vikram Malhotra | Dr. Arun Mehta     | 2026-10-22        | Enoxaparin 40mg Inj | 40mg   |        5 | Subcutaneous injection once daily   |
+-----------------+-----------------+--------------------+-------------------+---------------------+--------+----------+-------------------------------------+
*/

-- ============================================================================
-- QUERY 19: Find all registered patients who have NEVER been admitted to a room
-- Concept: Subquery using NOT IN
-- ============================================================================
SELECT 
    patient_id,
    CONCAT(first_name, ' ', last_name) AS patient_name,
    gender,
    city,
    phone
FROM Patient
WHERE patient_id NOT IN (
    SELECT DISTINCT patient_id 
    FROM Admission
)
ORDER BY patient_id ASC;

/*
SAMPLE OUTPUT:
+------------+----------------+--------+-------------+------------+
| patient_id | patient_name   | gender | city        | phone      |
+------------+----------------+--------+-------------+------------+
|          4 | Priya Nair     | Female | Bangalore   | 9844556677 |
|          6 | Ananya Joshi   | Female | Pune        | 9866778899 |
|          8 | Pooja Deshmukh | Female | Navi Mumbai | 9888990011 |
|          9 | Rohan Gupta    | Male   | Jaipur      | 9899001122 |
|         10 | Sunita Rao     | Female | Chennai     | 9811223344 |
+------------+----------------+--------+-------------+------------+
*/

-- ============================================================================
-- QUERY 20: Find doctors who have supervised at least one inpatient admission
-- Concept: Correlated Subquery using EXISTS
-- ============================================================================
SELECT 
    d.doctor_id,
    CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS doctor_name,
    dep.department_name,
    d.specialization
FROM Doctor d
JOIN Department dep ON d.department_id = dep.department_id
WHERE EXISTS (
    SELECT 1 
    FROM Admission adm 
    WHERE adm.doctor_id = d.doctor_id
)
ORDER BY d.doctor_id ASC;

/*
SAMPLE OUTPUT:
+-----------+---------------------+------------------+------------------------------------+
| doctor_id | doctor_name         | department_name  | specialization                     |
+-----------+---------------------+------------------+------------------------------------+
|         1 | Dr. Arun Mehta      | Cardiology       | Senior Interventional Cardiologist |
|         4 | Dr. Vikram Rathore  | Orthopedics      | Senior Orthopedic Surgeon          |
|         5 | Dr. Sunita Deshmukh | General Medicine | General Physician & Diabetologist  |
|         8 | Dr. Sanjay Kulkarni | Oncology         | Surgical Oncologist                |
+-----------+---------------------+------------------+------------------------------------+
*/

-- ============================================================================
-- QUERY 21: UPDATE Query - Adjust consultation fees for a specific department
-- Concept: Relational UPDATE with subquery / join
-- ============================================================================
-- Increase consultation fees by 10% for all doctors in General Medicine
UPDATE Doctor
SET consultation_fee = consultation_fee * 1.10
WHERE department_id = (
    SELECT department_id FROM Department WHERE department_name = 'General Medicine'
);

-- Verify the update
SELECT doctor_id, CONCAT('Dr. ', first_name, ' ', last_name) AS doctor_name, consultation_fee
FROM Doctor
WHERE department_id = (SELECT department_id FROM Department WHERE department_name = 'General Medicine');

/*
SAMPLE OUTPUT:
+-----------+---------------------+------------------+
| doctor_id | doctor_name         | consultation_fee |
+-----------+---------------------+------------------+
|         5 | Dr. Sunita Deshmukh |           660.00 |
|         6 | Dr. Neha Agarwal    |           605.00 |
+-----------+---------------------+------------------+
*/

-- ============================================================================
-- QUERY 22: Safe DELETE / Cancellation - Demonstrating Referential Integrity
-- Concept: Safe soft cancellation vs Foreign Key CASCADE deletion
-- ============================================================================
-- 1. Soft Cancel appointment (Standard Hospital Practice)
UPDATE Appointment
SET status = 'Cancelled'
WHERE appointment_id = 10;

-- 2. Verify cancellation status
SELECT appointment_id, patient_id, doctor_id, appointment_date, status
FROM Appointment
WHERE appointment_id = 10;

/*
SAMPLE OUTPUT:
+----------------+------------+-----------+------------------+-----------+
| appointment_id | patient_id | doctor_id | appointment_date | status    |
+----------------+------------+-----------+------------------+-----------+
|             10 |         10 |         6 | 2026-11-07       | Cancelled |
+----------------+------------+-----------+------------------+-----------+
*/
