SELECT DISTINCT
    students.first_name,
    students.last_name,
    u_health_info.health_form
FROM students

LEFT OUTER JOIN
    u_health_info
    ON students.DCID = U_HEALTH_INFO.StudentsDCID
WHERE STUDENTs.DCID = 3192
