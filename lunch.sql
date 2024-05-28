select
	(CASE
    	WHEN students.schoolid = '100' THEN 'MVU'
    	WHEN students.schoolid = '200' THEN 'MVU'
    	WHEN students.schoolid = '115' THEN 'FCS'
    	WHEN students.schoolid = '142' THEN 'HES'
    	WHEN students.schoolid = '295' THEN 'SWA'	
    	ELSE ''
    END) as "school ID",
	students.state_studentnumber as "state ID",
	students.lastfirst as "name",
	studentcorefields.lunchapplicno as "app num",
	(CASE
		WHEN s_vt_stu_x.nslelg = null THEN '96'
		ELSE s_vt_stu_x.nslelg
		END)
	
	 as "status",
	u_studentsuserfields.lunch_eligibility as "eligibility",
	(CASE  
		WHEN to_char(students.applic_submitted_date, 'DD/MM/YYYY') = '01/01/1900' THEN ' ' 
		ELSE to_char(students.applic_submitted_date, 'DD/MM/YYYY')
		END )
	as "app submitted",
	(CASE  
		WHEN to_char(students.applic_response_recvd_date, 'DD/MM/YYYY') = '01/01/1900' THEN ' ' 
		ELSE to_char(students.applic_response_recvd_date, 'DD/MM/YYYY')
		END )
	as "app recieved",
	to_char(u_def_ext_students.fr_status_change_date, 'DD/MM/YYYY') as "Status Date Change",
	u_def_ext_students.fr_status_changed as "Previous Status",
	u_def_ext_students.fr_status_change_reason as "Reason",
	u_def_ext_students.fr_dc_eligible_source as "source",
	u_def_ext_students.fr_notes as "notes"
	

from students
	left join studentcorefields ON students.dcid=studentcorefields.studentsdcid
	left join s_vt_stu_x ON students.DCID = s_vt_stu_x.studentsdcid
	left join u_studentsuserfields ON students.dcid = u_studentsuserfields.studentsdcid
	left outer join u_def_ext_students ON students.dcid = u_def_ext_students.studentsdcid
	


where
	students.enroll_status = 0
