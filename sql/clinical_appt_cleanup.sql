ALTER TABLE clinical_appt
	CHANGE COLUMN Hipertension Hypertension INT,
    CHANGE COLUMN Handcap disability_count INT,
    CHANGE COLUMN `No-show` no_show VARCHAR(3)

SELECT
	disability_count,
    COUNT(*)
FROM clinical_appt
GROUP BY disability_count

SELECT
	ScheduledDay,
    AppointmentDay
FROM clinical_appt
LIMIT 10;

SET SQL_SAFE_UPDATES = 0;

UPDATE clinical_appt
SET ScheduledDay_clean = STR_TO_DATE(REPLACE(REPLACE(ScheduledDay, 'T', ' '), 'Z', ''), '%Y-%m-%d %H:%i:%S'),
    AppointmentDay_clean = STR_TO_DATE(REPLACE(REPLACE(AppointmentDay, 'T', ' '), 'Z', ''), '%Y-%m-%d %H:%i:%S');

ALTER TABLE clinical_appt
	add COLUMN ScheduledDay_clean DATETIME,
    add COLUMN AppointmentDay_clean DATE;


ALTER TABLE clinical_appt
	DROP COLUMN ScheduledDay ,
    DROP COLUMN AppointmentDay;

ALTER TABLE clinical_appt
	CHANGE COLUMN ScheduledDay_clean ScheduledDay DATETIME,
    CHANGE COLUMN AppointmentDay_clean AppointmentDay DATE;

SELECT
	min(age),
    max(age)
FROM clinical_appt

DELETE FROM clinical_appt
WHERE age= -1;

ALTER TABLE clinical_appt ADD COLUMN lead_time_days INT ;

UPDATE clinical_appt
SET lead_time_days= datediff(AppointmentDay,DATE(ScheduledDay))

SELECT
	min(lead_time_days),
    max(lead_time_days)
FROM clinical_appt

SELECT * FROM clinical_appt
WHERE lead_time_days <0;

DELETE FROM clinical_appt
WHERE lead_time_days <0;
