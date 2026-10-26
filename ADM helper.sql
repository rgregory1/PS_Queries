SELECT 
    (CASE
        WHEN schoolid = '100' THEN 'MVU'
        WHEN schoolid = '200' THEN 'MVU'
        WHEN schoolid = '115' THEN 'FCS'
        WHEN schoolid = '142' THEN 'HES'
        WHEN schoolid = '295' THEN 'SWA'
        WHEN schoolid = '21' THEN 'ECP'
        WHEN schoolid = '900' THEN 'OODP'
        ELSE ''
    END) as School,
    student_number as StudentNumber,
    state_studentnumber as Permnumber,
    first_name AS FirstName,
    last_name AS LastName,
    grade_level AS Grade,
    adminstat AS ADMINSTAT,
    (CASE
        WHEN adminstat = '02' THEN 'School Choice'
        WHEN adminstat = '03' THEN 'Exchange'
        WHEN adminstat = '04' THEN 'HS taking academic'
        WHEN adminstat = '05' THEN 'HS in extra-cur'
        WHEN adminstat = '06' THEN 'guest'
        WHEN adminstat = '07' THEN 'Ser here, enrolled else'
        WHEN adminstat = '08' THEN 'Enrolled here, serv else'
        WHEN adminstat = '09' THEN 'HSCP'
        ELSE ''
    END) as AdminstatText,
    to_char(entrydate, 'MM/DD/YYYY') as ENRBEGDATE,
    to_char(exitdate, 'MM/DD/YYYY') as ENRENDDATE,
    fundsource AS FUNDSOURCE,
    (CASE
        WHEN fundsource = '02' THEN 'Other VT SD'
        WHEN fundsource = '03' THEN 'Non-VT SD'
        WHEN fundsource = '04' THEN 'VT State'
        WHEN fundsource = '05' THEN 'Agency Other'
        WHEN fundsource = '06' THEN 'Fed Agency'
        WHEN fundsource = '07' THEN 'Private Fund'
        WHEN fundsource = '08' THEN 'Employee Ben'
        WHEN fundsource = '09' THEN 'Sponsored'
        ELSE ''
    END) as FundsourceText,
    admtdist AS ADMTDIST,
    (CASE
        WHEN admtdist = 'T003' THEN 'Alburg'
        WHEN admtdist = 'T007' THEN 'Bakersfield'
        WHEN admtdist = 'T018' THEN 'Berkshire'
        WHEN admtdist = 'T068' THEN 'Enosburg'
        WHEN admtdist = 'T072' THEN 'Fairfield'
        WHEN admtdist = 'T079' THEN 'Georgia'
        WHEN admtdist = 'T103' THEN 'Isle La Motte'
        WHEN admtdist = 'T126' THEN 'Milton'
        WHEN admtdist = 'T128' THEN 'Montgomery'
        WHEN admtdist = 'T143' THEN 'North Hero'
        WHEN admtdist = 'T165' THEN 'Richford'
        WHEN admtdist = 'T187' THEN 'Sheldon'
        WHEN admtdist = 'T192' THEN 'South Hero'
        WHEN admtdist = 'T176' THEN 'St A City'
        WHEN admtdist = 'T177' THEN 'St A Town'
        WHEN admtdist = 'T084' THEN 'Grand Isle'
        ELSE ''
    END) as AdmtdistText,
    (CASE
        WHEN admtyp = 'S' THEN 'S'
        ELSE ''
    END) AS ADMTYP,
    admhours AS ADMHours,
    hs_activadm AS HSActivityADM,
    EDFI_PUBLISH_SCHOOL AS EdFiPublishSchool,
    Tuition_Student AS Tuition_Student,
    Tuition_ENRORGID AS TuitionENRORGID
FROM (
    -- Get Current Enrollment
    SELECT s.schoolid, s.student_number, s.state_studentnumber, s.first_name, s.last_name, s.grade_level, 
           s.entrydate, s.exitdate, x.adminstat, x.fundsource, x.admtdist, x.admtyp, x.admhours, 
           x.hs_activadm, x.EDFI_PUBLISH_SCHOOL, x.Tuition_Student, x.Tuition_ENRORGID
    FROM students s
    LEFT JOIN s_vt_stu_x x ON s.dcid = x.studentsdcid
    
    UNION ALL
    
    -- Get Previous Enrollments (Joining to the main extension table to avoid the error)
    SELECT r.schoolid, s.student_number, s.state_studentnumber, s.first_name, s.last_name, r.grade_level, 
           r.entrydate, r.exitdate, x.adminstat, x.fundsource, x.admtdist, x.admtyp, x.admhours, 
           x.hs_activadm, x.EDFI_PUBLISH_SCHOOL, x.Tuition_Student, x.Tuition_ENRORGID
    FROM reenrollments r
    JOIN students s ON r.studentid = s.id
    LEFT JOIN s_vt_stu_x x ON s.dcid = x.studentsdcid
) combined_data
WHERE 
    entrydate >= TO_DATE('08/25/2026', 'MM/DD/YYYY')
    AND student_number NOT IN ('81265')
    AND (entrydate != exitdate)
ORDER BY LastName, FirstName, ENRBEGDATE
