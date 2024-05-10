SELECT 	
	teachers.teachernumber as Teacher_id,
	teachers.teachernumber as Teacher_number,
	s_vt_usr_x.educatorid as educatorid,
	teachers.homeschoolid as School_id,
	teachers.first_name as First_name,
	teachers.middle_name as Middle_name,
	teachers.last_name as Last_name,
	teachers.email_addr as Teacher_email
	 
	
FROM teachers
	inner join users on teachers.teachernumber = users.teachernumber
	inner join s_vt_usr_x on s_vt_usr_x.usersdcid = users.dcid

WHERE teachers.status = 1
					AND teachers.homeschoolid = teachers.schoolid
					AND teachers.email_addr LIKE '%@mvsdschools.org'
					AND teachers.schoolid IN (115,142,295,100,200)
	
