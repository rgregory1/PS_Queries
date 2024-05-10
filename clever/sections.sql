SELECT
					sections.schoolid AS School_id,
					sections.id AS Section_id,
					teachers.teachernumber AS Teacher_id,
					sections.section_number AS Section_number,
					courses.course_name AS Course_name,
					courses.course_number AS Course_number,
					sections.expression AS Perid,
					terms.abbreviation AS Term_name,
					to_char(terms.firstday,'MM/DD/YYYY') AS Term_start,
					to_char(terms.lastday,'MM/DD/YYYY') AS Term_end
					-- sections.room
					
				FROM
					sections
					JOIN teachers ON sections.teacher = teachers.id
					INNER JOIN courses ON courses.course_number = sections.course_number
					INNER JOIN terms ON terms.id = sections.termid
						AND terms.schoolid = sections.schoolid
				WHERE
					sections.termid >= (SELECT TO_NUMBER(Value)*100 FROM Prefs WHERE Name = 'coursearchiveyear')
					AND sections.schoolid IN (142,115,295,100,200)
					-- AND sections.schoolid = 200
					and LENGTH(teachers.teachernumber) =4 
	
