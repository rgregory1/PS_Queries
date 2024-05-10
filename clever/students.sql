select
	schoolid as School_id,
	student_number as Student_id,
	student_number as Student_number,
	students.State_StudentNumber as State_id,
	last_name as Last_name,
	first_name as First_name,
	grade_level as Grade,
	gender as Gender,
	to_char(dob,'MM/DD/YYYY') as DOB,
	(CASE
    	WHEN students.ethnicity = 'H' THEN 'W'
    	ELSE students.ethnicity
    END) AS Race,
	(CASE
		WHEN students.ethnicity = 'H' THEN 'Y'
		ELSE 'N'
    END) AS Hispanic_Latino,
    (CASE
	      WHEN studentcorefields.lep_status = 'Y' THEN 'Y'
	      ELSE 'N'
	  END) ASEll_status,
	  lower(REGEXP_SUBSTR(emailaddress.emailaddress,'[~@]+',1,1)) as Username,
	  
	  (lower(SUBSTR(First_name, 1,1) || SUBSTR(Last_name,1,1) || '3456789!'))as Password
    
from 
	students

LEFT JOIN studentcorefields ON students.dcid=studentcorefields.studentsdcid
LEFT JOIN personemailaddressassoc on personemailaddressassoc.personid = students.person_id

LEFT JOIN emailaddress on emailaddress.emailaddressid = personemailaddressassoc.emailaddressid

where
	Schoolid IN (115,142,295,200,100)
	AND students.enroll_status=0
	-- AND students.enroll_status IN (0,-1)
