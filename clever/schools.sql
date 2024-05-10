select
	school_number as School_id,
	name as School_name,
	(CASE 
		
		WHEN school_number = '295' THEN 'PS295'
	    WHEN school_number = '115' THEN 'PS115'
	    WHEN school_number = '142' THEN 'PS142'
	    ELSE 'PS187'
		END
	)
	as School_number,
	-- school_number as School_number,
	low_grade as Low_grade,
	high_grade as High_grade
	
from
	schools
where
	School_number IN (115,142,295,200,100)
