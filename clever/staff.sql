select
  
  teachers.homeschoolid as School_id,
  teachers.teachernumber as Staff_id,
  teachers.Email_Addr as Staff_email,
  teachers.first_name as First_name,
  teachers.last_name as Last_name,
  teachers.title as Title
  
FROM
  Teachers teachers
  LEFT JOIN u_def_ext_users ext ON teachers.users_dcid = ext.usersdcid
  
WHERE
  teachers.Status = 1 
  and teachers.homeschoolid = teachers.schoolid
  AND teachers.email_addr LIKE '%@mvsdschools.org'
  AND teachers.homeschoolid in (100,200,115,142,295,0)
  AND ext.clever_staff = 1

ORDER BY
  teachers.Last_Name,
  teachers.First_Name;
