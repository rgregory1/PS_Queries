SELECT
				StudentContactAssoc.StudentDCID,
				StudentContactAssoc.ContactPriorityOrder,
				StudentContactDetail.IsCustodial AS Rights,

				(SELECT 
					CodeSet.Code 
				FROM 
					CodeSet 
				WHERE 
					CodeSet.CodeSetID = StudentContactDetail.RelationshipTypeCodeSetID
				) AS Role,

				CASE
					WHEN Person.MiddleName IS NOT NULL 
					THEN CONCAT(CONCAT(CONCAT(CONCAT(Person.FirstName, ' '), Person.MiddleName), ' '), Person.LastName)
					ELSE CONCAT(CONCAT(Person.FirstName, ' '), Person.LastName)
					END AS Name,

				(SELECT 
					PersonPhoneNumberAssoc.PhoneNumberAsEntered 
				FROM 
					PersonPhoneNumberAssoc 
				WHERE 
					PersonPhoneNumberAssoc.PersonID = StudentContactAssoc.PersonID AND 
					PersonPhoneNumberAssoc.PhoneNumberPriorityOrder = 1
				) AS Phone_1,
				
				(SELECT 
					CodeSet.Code 
				FROM 
					PersonPhoneNumberAssoc, CodeSet 
				WHERE 
					PersonPhoneNumberAssoc.PersonID = StudentContactAssoc.PersonID AND 
					PersonPhoneNumberAssoc.PhoneNumberPriorityOrder = 1 AND
					CodeSet.CodeSetID = PersonPhoneNumberAssoc.PhoneTypeCodeSetID
				) AS Phone_1_Type,

				(SELECT 
					PersonPhoneNumberAssoc.PhoneNumberAsEntered 
				FROM 
					PersonPhoneNumberAssoc 
				WHERE 
					PersonPhoneNumberAssoc.PersonID = StudentContactAssoc.PersonID AND 
					PersonPhoneNumberAssoc.PhoneNumberPriorityOrder = 2
				) AS Phone_2,

				(SELECT 
					CodeSet.Code 
				FROM 
					PersonPhoneNumberAssoc, CodeSet 
				WHERE 
					PersonPhoneNumberAssoc.PersonID = StudentContactAssoc.PersonID AND 
					PersonPhoneNumberAssoc.PhoneNumberPriorityOrder = 2 AND
					CodeSet.CodeSetID = PersonPhoneNumberAssoc.PhoneTypeCodeSetID
				) AS Phone_2_Type,

				(SELECT 
					PersonPhoneNumberAssoc.PhoneNumberAsEntered 
				FROM 
					PersonPhoneNumberAssoc 
				WHERE 
					PersonPhoneNumberAssoc.PersonID = StudentContactAssoc.PersonID AND 
					PersonPhoneNumberAssoc.PhoneNumberPriorityOrder = 3
				) AS Phone_3,

				(SELECT 
					CodeSet.Code 
				FROM 
					PersonPhoneNumberAssoc, CodeSet 
				WHERE 
					PersonPhoneNumberAssoc.PersonID = StudentContactAssoc.PersonID AND 
					PersonPhoneNumberAssoc.PhoneNumberPriorityOrder = 3 AND
					CodeSet.CodeSetID = PersonPhoneNumberAssoc.PhoneTypeCodeSetID
				) AS Phone_3_Type,

				StudentContactDetail.IsEmergency AS Emergency,
				
				(SELECT 
					EmailAddress.EmailAddress 
				FROM 
					PersonEmailAddressAssoc, EmailAddress 
				WHERE 
					PersonEmailAddressAssoc.PersonID = StudentContactAssoc.PersonID AND 
					PersonEmailAddressAssoc.IsPrimaryEmailAddress = 1 AND
					EmailAddress.EmailAddressID = PersonEmailAddressAssoc.EmailAddressID
				) AS Email,

				(SELECT 
					CASE
						WHEN PersonAddress.Unit IS NOT NULL AND PersonAddress.LineTwo IS NOT NULL  
						THEN CONCAT(CONCAT(CONCAT(CONCAT(PersonAddress.Unit, ' '), PersonAddress.Street), ' '), PersonAddress.LineTwo)
						WHEN PersonAddress.Unit IS NOT NULL  
						THEN CONCAT(CONCAT(PersonAddress.Unit, ' '), PersonAddress.Street)
						WHEN PersonAddress.LineTwo IS NOT NULL  
						THEN CONCAT(CONCAT(PersonAddress.Street, ' '), PersonAddress.LineTwo)
						ELSE PersonAddress.Street
						END 
				FROM 
					PersonAddressAssoc, PersonAddress
				WHERE 
					PersonAddressAssoc.PersonID = StudentContactAssoc.PersonID AND 
					PersonAddressAssoc.AddressPriorityOrder = 1 AND
					PersonAddress.PersonAddressID = PersonAddressAssoc.PersonAddressID
				) AS Address,
				
				(SELECT 
					PersonAddress.City
				FROM 
					PersonAddressAssoc, PersonAddress
				WHERE 
					PersonAddressAssoc.PersonID = StudentContactAssoc.PersonID AND 
					PersonAddressAssoc.AddressPriorityOrder = 1 AND
					PersonAddress.PersonAddressID = PersonAddressAssoc.PersonAddressID
				) AS City,
				
				(SELECT 
					CodeSet.Code 
				FROM 
					PersonAddressAssoc, PersonAddress, CodeSet
				WHERE 
					PersonAddressAssoc.PersonID = StudentContactAssoc.PersonID AND 
					PersonAddressAssoc.AddressPriorityOrder = 1 AND
					PersonAddress.PersonAddressID = PersonAddressAssoc.PersonAddressID AND
					CodeSet.CodeSetID = PersonAddress.StatesCodesetID
				) AS State,
				
				(SELECT 
					PersonAddress.PostalCode
				FROM 
					PersonAddressAssoc, PersonAddress
				WHERE 
					PersonAddressAssoc.PersonID = StudentContactAssoc.PersonID AND 
					PersonAddressAssoc.AddressPriorityOrder = 1 AND
					PersonAddress.PersonAddressID = PersonAddressAssoc.PersonAddressID
				) AS Zip
				
			FROM
				STUDENTS
				LEFT JOIN STUDENTCOREFIELDS ON STUDENTCOREFIELDS.StudentsDCID = STUDENTS.dcid
				LEFT JOIN S_VT_STU_X ON S_VT_STU_X.StudentsDCID = STUDENTS.dcid
				LEFT JOIN StudentContactAssoc ON StudentContactAssoc.StudentDCID = STUDENTS.dcid
				LEFT JOIN Person ON Person.ID = StudentContactAssoc.PersonID
				LEFT JOIN StudentContactDetail ON StudentContactDetail.StudentContactAssocID = StudentContactAssoc.StudentContactAssocID
			WHERE
				(STUDENTS.Enroll_Status = -1 OR STUDENTS.Enroll_Status = 0) AND
				(:Local_ID = '_EMPTY_' OR STUDENTS.Student_Number = :Local_ID) AND
				(:Child_Count_ID = '_EMPTY_' OR STUDENTS.State_StudentNumber = :Child_Count_ID) AND
				(:First_Name = '_EMPTY_' OR UPPER(STUDENTS.First_Name) = :First_Name OR UPPER(STUDENTCOREFIELDS.pscore_legal_first_name) = :First_Name) AND
				(:Last_Name = '_EMPTY_' OR UPPER(STUDENTS.Last_Name) = :Last_Name OR UPPER(STUDENTCOREFIELDS.pscore_legal_last_name) = :Last_Name) AND
				((:est = '_EMPTY_' AND :iep = '_EMPTY_' AND :ss504 = '_EMPTY_') OR :est = S_VT_STU_X.est OR :iep =  S_VT_STU_X.iep OR :ss504 = S_VT_STU_X.ss504)
