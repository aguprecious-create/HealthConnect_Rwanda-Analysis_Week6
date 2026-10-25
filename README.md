HealthConnect Rwanda: Data Analytics Submission (Week 6)
This repository holds the Week 6 Data Analytics track submission for HealthConnect Rwanda. It covers the PostgreSQL database, 40 SQL business questions, a six-page Power BI dashboard, an insights report, and a presentation.
Folder contents
Folder	Contents
`Database/`	`HealthConnect_Rwanda.sql`: the backup of the PostgreSQL database with all 27 tables.
`Data/`	The source files: `HC_Data.zip` (the healthcare tables) and `HC_Billing.csv` (the billing table, supplied separately).
`SQL/`	`HealthConnect_SQL_Queries.sql`: 40 business questions, grouped into patient, appointment, clinical and financial analysis.
`Dashboard/`	`HealthConnect_Rwanda.pbix`: the Power BI report with six pages.
`Report/`	`HealthConnect_Business_Insights_Report.docx` and `.pdf`: the three-page insights report.
`Presentation/`	`HealthConnect_Business_Insights_Presentation.pptx` and `.pdf`: a 13-slide presentation.
`Template/`	`HealthConnect_Dashboard_Template.pptx` and `.pdf`: an editable background template for the six dashboard pages.
Database
The data was loaded into a PostgreSQL 18 database named `HealthConnect_Rwanda`, with 27 tables. A backup of the database is part of the submission.
Tables were loaded from the source files with one table per file. Column names were converted to lowercase with underscores. The duplicate facility file (`HC_Facility_Master_Data 2.xlsx`) was excluded.
Opening the dashboard
Install Power BI Desktop and PostgreSQL.
Restore the database from the backup, or load the tables from `Data/`.
Open `Dashboard/HealthConnect_Rwanda.pbix`.
If prompted, enter the PostgreSQL password and refresh the data.
Pages: Executive Dashboard, Patient Analytics, Clinical Analytics, Financial Analysis, Operational Dashboard and Patient Experience.
Data coverage and limits
These limits shape the findings. They are also stated in the report and the presentation.
Appointment detail: only 5,000 of 60,000 appointments have facility and department details. Location and facility findings cover that subset.
Billing dates: billing has no dates. The monthly revenue trend uses the 5,000 matched bills, which total 771 million of the 9.31 billion billed.
Missing records: there are no laboratory, prescription, admission or referral records. Emergency visits are used as a proxy for referrals.
Facility names: facilities are identified by ID only. The facility master file contains department data.
Occupancy and usage: all beds are recorded as available, and equipment has no usage data, so utilisation cannot be measured.
Currency: the source data does not state a currency. Amounts are shown without a currency code unless noted.
Map: the province view uses a bubble map with approximate coordinates for each province's centre.
Key figures
Measure	Value
Patients	20,000
Appointments with clinical detail	5,000
Total billed (all bills)	9.31 billion
Billed on matched appointments	771 million
Total paid	8.39 billion
Insurance claims	4.88 billion
Staff	1,250
Beds	2,000
Feedback responses	21,064
Average rating	2.99 of 5
Complaint rate (ratings of 1 or 2)	40.4%
Data source
The data is synthetic and was created for training purposes.