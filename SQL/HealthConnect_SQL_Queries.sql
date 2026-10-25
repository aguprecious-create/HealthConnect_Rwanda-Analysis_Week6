-- HealthConnect Rwanda: SQL business questions (Week 6)
-- Database: HealthConnect_Rwanda (PostgreSQL)
-- Notes on data coverage are given as comments beside each query where it matters.

-- =========================================================
-- PATIENT ANALYSIS
-- =========================================================

-- 1. Retrieve all registered patients.
SELECT * FROM patients;

-- 2. Count patients by gender.
SELECT gender, COUNT(*) AS patients
FROM patients
GROUP BY gender
ORDER BY patients DESC;

-- 3. Count patients by province.
SELECT pr.provincename, COUNT(*) AS patients
FROM patients p
JOIN villages v   ON p.villageid = v.villageid
JOIN sectors s    ON v.sectorid = s.sectorid
JOIN districts d  ON s.districtid = d.districtid
JOIN provinces pr ON d.provinceid = pr.provinceid
GROUP BY pr.provincename
ORDER BY patients DESC;

-- 4. Identify patients above 65 years.
SELECT patientid, firstname, lastname, gender, age
FROM patients
WHERE age > 65
ORDER BY age DESC;

-- 5. Find patients with chronic diseases.
SELECT patientid, firstname, lastname, age, chroniccondition
FROM patients
WHERE chroniccondition IS NOT NULL
ORDER BY chroniccondition, lastname;

-- 5b. Count patients by chronic condition.
SELECT chroniccondition, COUNT(*) AS patients
FROM patients
WHERE chroniccondition IS NOT NULL
GROUP BY chroniccondition
ORDER BY patients DESC;

-- 6. Retrieve patients covered by insurance.
-- Coverage note: every patient has an insurance ID, so all 20,000 show as covered.
SELECT patientid, firstname, lastname, insuranceid
FROM patients
WHERE insuranceid IS NOT NULL;

-- 7. Count patients by blood group.
SELECT bloodgroup, COUNT(*) AS patients
FROM patients
GROUP BY bloodgroup
ORDER BY patients DESC;

-- 8. List the youngest and oldest patients.
SELECT 'Youngest' AS category, patientid, firstname, lastname, age
FROM patients
WHERE age = (SELECT MIN(age) FROM patients)
UNION ALL
SELECT 'Oldest', patientid, firstname, lastname, age
FROM patients
WHERE age = (SELECT MAX(age) FROM patients);

-- 9. Identify duplicate phone numbers.
SELECT phone, COUNT(*) AS patients_sharing
FROM patients
GROUP BY phone
HAVING COUNT(*) > 1
ORDER BY patients_sharing DESC;

-- 10. Calculate average patient age.
SELECT ROUND(CAST(AVG(age) AS NUMERIC), 1) AS average_age
FROM patients;

-- =========================================================
-- APPOINTMENT ANALYSIS
-- Coverage note: facility, department and doctor details exist for 5,000 appointments
-- (clinical_transactions). Counts below are for those 5,000 appointments.
-- =========================================================

-- 11. Count appointments by month.
SELECT EXTRACT(YEAR FROM CAST(date AS DATE)) AS year,
       EXTRACT(MONTH FROM CAST(date AS DATE)) AS month,
       COUNT(*) AS appointments
FROM clinical_transactions
GROUP BY 1, 2
ORDER BY 1, 2;

-- 12. Identify busiest hospitals (facilities).
-- Facility names are not in the dataset, so facilities are shown by ID.
SELECT facilityid, COUNT(*) AS appointments
FROM clinical_transactions
GROUP BY facilityid
ORDER BY appointments DESC
LIMIT 10;

-- 13. Find busiest departments.
SELECT d.departmentname, COUNT(*) AS appointments
FROM clinical_transactions ct
JOIN departments d ON ct.departmentid = d.departmentid
GROUP BY d.departmentname
ORDER BY appointments DESC
LIMIT 10;

-- 14. Find doctors with the highest workload.
SELECT ct.doctorid, doc.firstname, doc.lastname, doc.specialty,
       COUNT(*) AS appointments
FROM clinical_transactions ct
JOIN doctor doc ON ct.doctorid = doc.staffid
GROUP BY ct.doctorid, doc.firstname, doc.lastname, doc.specialty
ORDER BY appointments DESC
LIMIT 10;

-- 15. Identify referral patterns.
-- Coverage note: the dataset has no referral field. The closest available measure is
-- emergency visits by facility, shown here as a proxy.
SELECT facilityid, COUNT(*) AS emergency_visits
FROM clinical_transactions
WHERE visittype = 'Emergency'
GROUP BY facilityid
ORDER BY emergency_visits DESC;

-- 16. Count emergency appointments.
SELECT COUNT(*) AS emergency_appointments
FROM clinical_transactions
WHERE visittype = 'Emergency';

-- 17. Calculate average appointments per doctor.
SELECT ROUND(CAST(COUNT(*) * 1.0 / COUNT(DISTINCT doctorid) AS NUMERIC), 2) AS avg_appointments_per_doctor
FROM clinical_transactions;

-- 18. Retrieve appointments by province.
SELECT pr.provincename, COUNT(*) AS appointments
FROM clinical_transactions ct
JOIN patients p   ON ct.patientid = p.patientid
JOIN villages v   ON p.villageid = v.villageid
JOIN sectors s    ON v.sectorid = s.sectorid
JOIN districts d  ON s.districtid = d.districtid
JOIN provinces pr ON d.provinceid = pr.provinceid
GROUP BY pr.provincename
ORDER BY appointments DESC;

-- 19. Identify facilities with the highest patient volume.
SELECT facilityid,
       COUNT(*) AS appointments,
       COUNT(DISTINCT patientid) AS unique_patients
FROM clinical_transactions
GROUP BY facilityid
ORDER BY unique_patients DESC
LIMIT 10;

-- 20. Find peak consultation periods (by day of week and month).
SELECT EXTRACT(DOW FROM CAST(date AS DATE)) AS day_of_week_number,
       EXTRACT(MONTH FROM CAST(date AS DATE)) AS month,
       COUNT(*) AS consultations
FROM clinical_transactions
WHERE visittype = 'Consultation'
GROUP BY 1, 2
ORDER BY consultations DESC
LIMIT 10;

-- =========================================================
-- CLINICAL ANALYSIS
-- =========================================================

-- 21. Top diagnoses.
SELECT diagnosis, COUNT(*) AS cases
FROM diagnoses
GROUP BY diagnosis
ORDER BY cases DESC;

-- 22. Most requested laboratory tests.
-- Not answerable: the dataset has no laboratory test records.
SELECT 'Not available: no laboratory test data in the dataset' AS note;

-- 23. Most prescribed medications.
-- Not answerable: the dataset has no prescription records.
SELECT 'Not available: no prescription data in the dataset' AS note;

-- 24. Average admission duration.
-- Not answerable: the dataset has no admission records.
SELECT 'Not available: no admission data in the dataset' AS note;

-- 25. Disease severity distribution.
SELECT severity, COUNT(*) AS cases,
       ROUND(CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS NUMERIC), 1) AS percent_of_cases
FROM diagnoses
GROUP BY severity
ORDER BY cases DESC;

-- 26. Laboratory test utilization.
-- Not answerable: no laboratory test data (see question 22).
SELECT 'Not available: no laboratory test data in the dataset' AS note;

-- 27. Prescription trends.
-- Not answerable: no prescription data (see question 23).
SELECT 'Not available: no prescription data in the dataset' AS note;

-- 28. Referral destinations.
-- Not answerable: no referral data (see question 15).
SELECT 'Not available: no referral data in the dataset' AS note;

-- 29. Admission rate by diagnosis.
-- Not answerable: no admission data. Shown instead: diagnosis share by severity.
SELECT diagnosis, severity, COUNT(*) AS cases
FROM diagnoses
GROUP BY diagnosis, severity
ORDER BY diagnosis, severity;

-- 30. Clinical workload by department.
SELECT d.departmentname,
       COUNT(*) AS total_visits,
       SUM(CASE WHEN ct.visittype = 'Emergency' THEN 1 ELSE 0 END) AS emergency_visits,
       SUM(CASE WHEN ct.visittype = 'Consultation' THEN 1 ELSE 0 END) AS consultations,
       SUM(CASE WHEN ct.visittype = 'Follow-up' THEN 1 ELSE 0 END) AS follow_ups
FROM clinical_transactions ct
JOIN departments d ON ct.departmentid = d.departmentid
GROUP BY d.departmentname
ORDER BY total_visits DESC;

-- =========================================================
-- FINANCIAL ANALYSIS
-- Coverage note: billing links to appointments through appointmentid. Facility and
-- department revenue can only be shown for the 5,000 appointments in clinical_transactions.
-- =========================================================

-- 31. Revenue by facility.
SELECT ct.facilityid,
       COUNT(*) AS billed_appointments,
       SUM(b.amount) AS billed_revenue
FROM billing b
JOIN clinical_transactions ct ON b.appointmentid = ct.appointmentid
GROUP BY ct.facilityid
ORDER BY billed_revenue DESC;

-- 32. Revenue by department.
SELECT d.departmentname,
       COUNT(*) AS billed_appointments,
       SUM(b.amount) AS billed_revenue
FROM billing b
JOIN clinical_transactions ct ON b.appointmentid = ct.appointmentid
JOIN departments d ON ct.departmentid = d.departmentid
GROUP BY d.departmentname
ORDER BY billed_revenue DESC;

-- 33. Revenue by service.
-- Coverage note: services cannot be linked to individual bills. Department revenue (32)
-- is the closest available view.
SELECT 'Not available at service level: see question 32 for department revenue' AS note;

-- 34. Insurance claims by provider.
SELECT provider,
       COUNT(*) AS claims,
       SUM(claimamount) AS total_claimed,
       ROUND(CAST(AVG(claimamount) AS NUMERIC), 0) AS average_claim
FROM insurance_claims
GROUP BY provider
ORDER BY total_claimed DESC;

-- 35. Outstanding payments.
-- Outstanding = bill amount minus payments received, for bills not yet fully paid.
WITH paid AS (
    SELECT billingid, SUM(amountpaid) AS amount_paid
    FROM payments
    GROUP BY billingid
)
SELECT b.billingid, b.appointmentid, b.status, b.amount,
       COALESCE(p.amount_paid, 0) AS amount_paid,
       b.amount - COALESCE(p.amount_paid, 0) AS outstanding
FROM billing b
LEFT JOIN paid p ON b.billingid = p.billingid
WHERE b.amount - COALESCE(p.amount_paid, 0) > 0
ORDER BY outstanding DESC;

-- 35b. Total outstanding amount.
WITH paid AS (
    SELECT billingid, SUM(amountpaid) AS amount_paid
    FROM payments
    GROUP BY billingid
)
SELECT COUNT(*) AS bills_outstanding,
       SUM(b.amount - COALESCE(p.amount_paid, 0)) AS total_outstanding
FROM billing b
LEFT JOIN paid p ON b.billingid = p.billingid
WHERE b.amount - COALESCE(p.amount_paid, 0) > 0;

-- 36. Average billing amount.
SELECT ROUND(CAST(AVG(amount) AS NUMERIC), 2) AS average_bill
FROM billing;

-- 37. Monthly revenue trend.
-- Coverage note: bills have no date. The pre-aggregated revenue_summary table is used.
SELECT month, revenue, appointments
FROM revenue_summary
ORDER BY month;

-- 38. Payment methods.
SELECT method,
       COUNT(*) AS payments,
       SUM(amountpaid) AS total_paid,
       ROUND(CAST(100.0 * SUM(amountpaid) / SUM(SUM(amountpaid)) OVER () AS NUMERIC), 1) AS percent_of_total
FROM payments
GROUP BY method
ORDER BY total_paid DESC;

-- 39. Top revenue-generating hospitals.
SELECT ct.facilityid,
       SUM(b.amount) AS billed_revenue
FROM billing b
JOIN clinical_transactions ct ON b.appointmentid = ct.appointmentid
GROUP BY ct.facilityid
ORDER BY billed_revenue DESC
LIMIT 10;

-- 40. Financial performance ranking.
-- Facilities ranked by billed revenue, with outstanding balance for the same bills.
WITH paid AS (
    SELECT billingid, SUM(amountpaid) AS amount_paid
    FROM payments
    GROUP BY billingid
),
facility_finance AS (
    SELECT ct.facilityid,
           SUM(b.amount) AS billed_revenue,
           SUM(b.amount - COALESCE(p.amount_paid, 0)) AS outstanding
    FROM billing b
    JOIN clinical_transactions ct ON b.appointmentid = ct.appointmentid
    LEFT JOIN paid p ON b.billingid = p.billingid
    GROUP BY ct.facilityid
)
SELECT facilityid, billed_revenue, outstanding,
       RANK() OVER (ORDER BY billed_revenue DESC) AS revenue_rank
FROM facility_finance
ORDER BY revenue_rank;
