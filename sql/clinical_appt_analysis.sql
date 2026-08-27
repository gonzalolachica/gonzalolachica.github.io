-- DATA EXPLORATION
-- what is the overall no show rate

SELECT
    no_show,
    COUNT(*) AS total_appointments,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM clinical_appt), 2) AS pct_of_total
FROM clinical_appt
GROUP BY no_show;

-- Does the day of the week matter
SELECT
    DAYNAME (AppointmentDay) as appointment_day,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) AS no_shows,
	ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) *100/ COUNT(*), 2) AS rate_of_no_shows
    from clinical_appt
    GROUP BY DAYNAME(AppointmentDay)
    ORDER BY rate_of_no_shows DESC;


    -- Patient-level risk scoring

    SELECT
		patientId,
        appointmentID,
        appointmentDay,
        no_Show,
        COUNT(*) OVER(
        partition by PatientID
        ORDER BY appointmentDay
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING ) as prior_appointments,
        SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END) OVER
        (PARTITION BY PatientID
        ORDER BY AppointmentDay
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) as prior_no_shows
        FROM clinical_appt
        ORDER BY PatientId,appointmentDay;


	CREATE VIEW v_appointment_risk AS
    WITH patient_history AS (
    SELECT
		PatientId,
        AppointmentID,
        AppointmentDay,
        Neighbourhood,
        lead_time_days,
        SMS_received,
        Scholarship,
        no_show,
        COUNT(*) OVER (
        PARTITION BY PatientID
        ORDER BY AppointmentDay
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prior_appointments,
        SUM(CASE WHEN no_show = 'YES' THEN 1 ELSE 0 END) OVER (
        PARTITION BY PatientId
        ORDER BY AppointmentDay
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING ) AS prior_no_shows
        FROM clinical_appt
        )

SELECT
	PatientId,
    AppointmentID,
    AppointmentDay,
    Neighbourhood ,
    lead_time_days ,
	prior_appointments,
    prior_no_shows,
    ROUND(prior_no_shows/NULLIF(prior_appointments,0), 2) AS prior_no_show_rate,
    CASE
		WHEN prior_appointments = 0 THEN 'New Patient - Monitor'
        WHEN (prior_no_shows / NULLIF(prior_appointments, 0 ))>= 0.5
			OR lead_Time_days >8 then 'High Risk'
		WHEN (prior_no_shows / NULLIF(prior_appointments, 0 )) >= 0.2
			OR lead_Time_days BETWEEN 4 AND 7 then 'Medium Risk'
		ELSE 'Low Risk'
	END AS risk_tier
FROM patient_history;



SELECT *
FROM v_appointment_risk
WHERE risk_Tier= 'High Risk'
ORDER BY appointmentDay
LIMIT 50;



SELECT * FROM clinical_appt

SELECT * FROM v_appointment_risk
