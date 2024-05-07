SELECT DISTINCT
	students.first_name,
	students.middle_name,
	students.last_name,
	students.schoolid,
	students.Student_Number,
	students.State_StudentNumber,
	students.grade_level,
	students.gender,
	TO_CHAR(students.dob, 'MM/DD/YYYY') AS dob,
	TRIM(mp.FirstName) || ' ' || TRIM(mp.LastName) AS Custodial_1_Name,
	SUBSTR(pn_cust1.PhoneNumber,1,3) || '-' || substr(pn_cust1.PhoneNumber,4,3) || '-' || substr(pn_cust1.PhoneNumber,7,4) AS Custodial_1_Phone,
	TRIM(ea.EmailAddress) AS Custodial_1_Email,
	REPLACE(TRIM(a.street || ' ' || a.Unit), '  ', ' ') AS Custodial_1_Address,
	TRIM(a.linetwo) AS Custodial_1_Line2,
	TRIM(a.City) AS Custodial_1_City,
	CASE WHEN state1.Code = 'Not Set' THEN NULL ELSE state1.code END AS Custodial_1_State,
	TRIM(a.PostalCode) AS Custodial_1_Zip,
	TRIM(mp2.FirstName) || ' ' || TRIM(mp2.LastName) AS Custodial_2_Name,
	SUBSTR(pn_cust2.PhoneNumber,1,3) || '-' || substr(pn_cust2.PhoneNumber,4,3) || '-' || substr(pn_cust2.PhoneNumber,7,4) AS Custodial_2_Phone,
	TRIM(ea2.EmailAddress) AS Custodial_2_Email,
	REPLACE(TRIM(a.street || ' ' || a.Unit), '  ', ' ') AS Custodial_2_Address,
	TRIM(a2.linetwo) AS Custodial_2_Line2,
	TRIM(a2.City) AS Custodial_2_City,
	CASE WHEN state2.Code = 'Not Set' THEN NULL ELSE state2.code END AS Custodial_2_State,
	TRIM(a2.PostalCode) AS Custodial_2_Zip
FROM
	Students
	
	
-- Contact 1 name
LEFT OUTER JOIN (
	SELECT
		StudentContactAssoc.PersonId,
		StudentContactAssoc.StudentContactAssocId,
		StudentContactAssoc.StudentDCID
	FROM 
		StudentContactAssoc
	INNER JOIN (
		SELECT 
			StudentContactAssoc.StudentDCID,
			MIN(StudentContactAssoc.ContactPriorityOrder) AS contact1
		FROM 
			StudentContactAssoc
		INNER JOIN (
			SELECT 
				StudentContactDetail.StudentContactAssocId
				-- StudentContactDetail.RelationshipTypeCodesetId
			FROM 
				StudentContactDetail
			WHERE 
				(
					StudentContactDetail.IsCustodial = 1 OR
					StudentContactDetail.LivesWithFlg = 1
				) AND
				StudentContactDetail.IsActive = 1 AND
				((
					StudentContactDetail.StartDate IS NULL AND 
					StudentContactDetail.EndDate IS NULL
				) OR (
					TRUNC(SYSDATE) <= COALESCE(StudentContactDetail.EndDate, TRUNC(SYSDATE)) AND 
					TRUNC(SYSDATE) >= COALESCE(StudentContactDetail.StartDate, TRUNC(SYSDATE))
				))
		) d ON d.StudentContactAssocId = StudentContactAssoc.StudentContactAssocId
		GROUP BY
			StudentContactAssoc.StudentDCID
	) sca1 ON StudentContactAssoc.StudentDCID = sca1.StudentDCID AND StudentContactAssoc.ContactPriorityOrder = sca1.contact1
) sca ON sca.StudentDCID = Students.DCID
LEFT OUTER JOIN Person mp ON mp.Id = sca.PersonId
-- Contact 1 phone
LEFT OUTER JOIN (
	SELECT
		PersonPhoneNumberAssoc.PersonId,
		PersonPhoneNumberAssoc.PhoneNumberID
	FROM 
		PersonPhoneNumberAssoc 
	INNER JOIN (
		SELECT 
			PersonPhoneNumberAssoc.PersonId,
			MIN(PersonPhoneNumberAssoc.PhoneNumberPriorityOrder) AS phone1
		FROM 
			PersonPhoneNumberAssoc
		GROUP BY
			PersonPhoneNumberAssoc.PersonId
	) ppna1 ON PersonPhoneNumberAssoc.personID = ppna1.personID AND PersonPhoneNumberAssoc.PhoneNumberPriorityOrder = ppna1.phone1 
) ppna_cust1 ON mp.Id = ppna_cust1.PersonId
LEFT OUTER JOIN PhoneNumber pn_cust1 ON ppna_cust1.PhoneNumberId = pn_cust1.PhoneNumberId
-- Contact 1 address
LEFT OUTER JOIN (
	SELECT 
		PersonAddressAssoc.PersonId,
		PersonAddressAssoc.PersonAddressId
	FROM 
		PersonAddressAssoc
	INNER JOIN (
		SELECT 
			PersonAddressAssoc.PersonId,
			MIN(PersonAddressAssoc.AddressPriorityOrder) AS address1
		FROM 
			PersonAddressAssoc
		WHERE 
			(
				personaddressassoc.StartDate IS NULL AND 
				personaddressassoc.EndDate IS NULL
			) OR (
				TRUNC(SYSDATE) <= COALESCE(personaddressassoc.EndDate, TRUNC(SYSDATE)) AND 
				TRUNC(SYSDATE) >= COALESCE(personaddressassoc.StartDate, TRUNC(SYSDATE))
			)
		GROUP BY
			PersonAddressAssoc.PersonId
	) paa1 ON PersonAddressAssoc.personID = paa1.personID AND PersonAddressAssoc.AddressPriorityOrder = paa1.address1 
) paa ON mp.Id = paa.PersonId 
LEFT OUTER JOIN PersonAddress a ON paa.PersonAddressId = a.PersonAddressId 
LEFT OUTER JOIN Codeset state1 ON a.StatesCodesetID = state1.CodesetId 
-- Contact 1 email
LEFT OUTER JOIN (
	SELECT
		PersonEmailAddressAssoc.PersonId,
		PersonEmailAddressAssoc.EmailAddressID
	FROM 
		PersonEmailAddressAssoc 
	INNER JOIN (
		SELECT 
			PersonEmailAddressAssoc.PersonId,
			MIN(PersonEmailAddressAssoc.EmailAddressPriorityOrder) AS email1
		FROM 
			PersonEmailAddressAssoc
		GROUP BY
			PersonEmailAddressAssoc.PersonId
	) peaa1 ON PersonEmailAddressAssoc.personID = peaa1.personID AND PersonEmailAddressAssoc.EmailAddressPriorityOrder = peaa1.email1  
) peaa ON mp.Id = peaa.PersonId
LEFT OUTER JOIN EmailAddress ea ON peaa.EmailAddressId = ea.EmailAddressId

-- Contact 2 name
LEFT OUTER JOIN (
	SELECT
		StudentContactAssoc.PersonId,
		StudentContactAssoc.StudentContactAssocId,
		StudentContactAssoc.StudentDCID
	FROM 
		StudentContactAssoc
	INNER JOIN (
		SELECT 
			StudentContactAssoc.StudentDCID,
			MIN(StudentContactAssoc.ContactPriorityOrder) AS contact2
		FROM 
			StudentContactAssoc
		INNER JOIN (
			SELECT 
				StudentContactDetail.StudentContactAssocId
				-- StudentContactDetail.RelationshipTypeCodesetId
			FROM 
				StudentContactDetail
			WHERE 
				(
					StudentContactDetail.IsCustodial = 1  OR
					StudentContactDetail.LivesWithFlg = 1
				) AND
				StudentContactDetail.IsActive = 1 AND
				((
					StudentContactDetail.StartDate IS NULL AND 
					StudentContactDetail.EndDate IS NULL
				) OR (
					TRUNC(SYSDATE) <= COALESCE(StudentContactDetail.EndDate, TRUNC(SYSDATE)) AND 
					TRUNC(SYSDATE) >= COALESCE(StudentContactDetail.StartDate, TRUNC(SYSDATE))
				))
		) d ON d.StudentContactAssocId = StudentContactAssoc.StudentContactAssocId
		-- exclude contact 1
		WHERE 
			StudentContactAssoc.PersonId NOT IN (
				SELECT 
					StudentContactAssoc.PersonID
				FROM 
					StudentContactAssoc
				INNER JOIN (
					SELECT 
						StudentContactAssoc.StudentDCID,
						MIN(StudentContactAssoc.ContactPriorityOrder) AS contact1
					FROM 
						StudentContactAssoc
					GROUP BY
						StudentContactAssoc.StudentDCID
				) firstcontact ON firstcontact.StudentDCID = StudentContactAssoc.StudentDCID AND StudentContactAssoc.ContactPriorityOrder = firstcontact.contact1
			)
		GROUP BY
			StudentContactAssoc.StudentDCID
	) sca11 ON StudentContactAssoc.StudentDCID = sca11.StudentDCID AND StudentContactAssoc.ContactPriorityOrder = sca11.contact2
) sca2 ON sca2.StudentDCID = Students.DCID
LEFT OUTER JOIN Person mp2 ON mp2.Id = sca2.PersonId
-- Contact 2 phone
LEFT OUTER JOIN (
	SELECT
		PersonPhoneNumberAssoc.PersonId,
		PersonPhoneNumberAssoc.PhoneNumberID
	FROM 
		PersonPhoneNumberAssoc 
	INNER JOIN (
		SELECT 
			PersonPhoneNumberAssoc.PersonId,
			MIN(PersonPhoneNumberAssoc.PhoneNumberPriorityOrder) AS phone1
		FROM 
			PersonPhoneNumberAssoc
		GROUP BY
			PersonPhoneNumberAssoc.PersonId
	) ppna1 ON PersonPhoneNumberAssoc.personID = ppna1.personID AND PersonPhoneNumberAssoc.PhoneNumberPriorityOrder = ppna1.phone1 
) ppna_cust2 ON mp2.Id = ppna_cust2.PersonId
LEFT OUTER JOIN PhoneNumber pn_cust2 ON ppna_cust2.PhoneNumberId = pn_cust2.PhoneNumberId
-- Contact 2 address
LEFT OUTER JOIN (
	SELECT 
		PersonAddressAssoc.PersonId,
		PersonAddressAssoc.PersonAddressId
	FROM 
		PersonAddressAssoc
	INNER JOIN (
		SELECT 
			PersonAddressAssoc.PersonId,
			MIN(PersonAddressAssoc.AddressPriorityOrder) AS address1
		FROM 
			PersonAddressAssoc
		WHERE 
			(
				personaddressassoc.StartDate IS NULL AND 
				personaddressassoc.EndDate IS NULL
			) OR (
				TRUNC(SYSDATE) <= COALESCE(personaddressassoc.EndDate, TRUNC(SYSDATE)) AND 
				TRUNC(SYSDATE) >= COALESCE(personaddressassoc.StartDate, TRUNC(SYSDATE))
			)
		GROUP BY
			PersonAddressAssoc.PersonId
	) paa1 ON PersonAddressAssoc.personID = paa1.personID AND PersonAddressAssoc.AddressPriorityOrder = paa1.address1 
) paa2 ON mp2.Id = paa2.PersonId 
LEFT OUTER JOIN PersonAddress a2 ON paa2.PersonAddressId = a2.PersonAddressId 
LEFT OUTER JOIN Codeset state2 ON a2.StatesCodesetID = state2.CodesetId 
-- Contact 2 email
LEFT OUTER JOIN (
	SELECT
		PersonEmailAddressAssoc.PersonId,
		PersonEmailAddressAssoc.EmailAddressID
	FROM 
		PersonEmailAddressAssoc 
	INNER JOIN (
		SELECT 
			PersonEmailAddressAssoc.PersonId,
			MIN(PersonEmailAddressAssoc.EmailAddressPriorityOrder) AS email1
		FROM 
			PersonEmailAddressAssoc
		GROUP BY
			PersonEmailAddressAssoc.PersonId
	) peaa1 ON PersonEmailAddressAssoc.personID = peaa1.personID AND PersonEmailAddressAssoc.EmailAddressPriorityOrder = peaa1.email1  
) peaa2 ON mp2.Id = peaa2.PersonId
LEFT OUTER JOIN EmailAddress ea2 ON peaa2.EmailAddressId = ea2.EmailAddressId

WHERE
	-- ROWNUM < 100 AND
	Students.ENROLL_STATUS IN (0,-1) AND
	-- Students.SchoolID IN (64,216,271,273,272) AND
	UPPER(students.Last_Name) NOT LIKE 'ZZ%' 
ORDER BY
	students.student_number
