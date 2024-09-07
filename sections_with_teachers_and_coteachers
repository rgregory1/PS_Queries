SELECT
    Clever.SectionID,
    Clever.Course_Number,
    Clever.Section_Number,
    Clever.Course_Name,
    Clever.SchoolID,
    Clever.Term_Name,
    Clever.Term_Start,
    Clever.Term_End,
    Clever.Teacher_ID,
    Clever.Teacher_2_ID,
    Clever.Teacher_3_ID,
    Clever.Teacher_4_ID,
    Clever.Teacher_5_ID,
    Clever.Teacher_6_ID,
    Clever.Teacher_7_ID,
    Clever.Teacher_8_ID,
    Clever.Teacher_9_ID
FROM (
    SELECT
        Sections.ID AS SectionID,
        Sections.Course_Number,
        Sections.Section_Number,
        Courses.Course_Name,
        Sections.SchoolID,
        Teachers.teachernumber,
        -- CASE
        --     WHEN Terms.isYearRec = 1 THEN 'Year'
        --     ELSE Terms.Abbreviation
        -- END AS Term_Name,
        terms.abbreviation AS Term_name,
        TO_CHAR(Terms.FirstDay,'MM/DD/YYYY') AS Term_Start,
        TO_CHAR(Terms.LastDay,'MM/DD/YYYY') AS Term_End,
        CASE
            WHEN RoleDef.RoleKey = 'com.pearson.powerschool.coteach.primary.teacher'
            THEN 1
            ELSE ROW_NUMBER() OVER (PARTITION BY Sections.ID ORDER BY NULL)
        END AS PriorityOrder
    FROM
        Sections
        JOIN Courses ON LOWER(Sections.Course_Number) = LOWER(Courses.Course_Number)
        JOIN Prefs Prefs ON Prefs.Name = 'coursearchiveyear'
        CROSS JOIN RoleDef
        JOIN SectionTeacher ON
            Sections.ID = SectionTeacher.SectionID
            AND RoleDef.ID = SectionTeacher.RoleID
        JOIN Teachers ON SectionTeacher.TeacherID = Teachers.ID
        JOIN Terms ON
            Sections.SchoolID = Terms.SchoolID
            AND Sections.TermID = Terms.ID
            AND TO_NUMBER(Prefs.Value) = Terms.YearID
    WHERE
        /* Ensure current assignment or lead teacher only */
        (
            TRUNC(SYSDATE) BETWEEN SectionTeacher.Start_Date AND SectionTeacher.End_Date
            OR Sections.Teacher = SectionTeacher.TeacherID
        )
        /*  Exclude undesired courses - best practice would be to use a (custom) field
            to track courses like these so you don't have to update the SQL */
        AND Courses.Course_Name NOT IN (
            'Cafe Duty',
            'Hall Duty/Coverage',
            'Staff Lunch',
            'Staff Pref',
            'Team Planning 6',
            'Team Planning 7',
            'Team Planning 8'
        )
        /*  Exclude undesired co-teaching roles - DO NOT put the Lead Teacher key here!
            The RoleDef.Name is also indexed, so you might prefer to use that for checking
            vs. the keys, especially if you plan to include customized co-teaching roles. */
        AND RoleDef.RoleKey NOT IN (
            'com.pearson.powerschool.coteach.class.observer',
            'com.pearson.powerschool.coteach.job.share.teacher',
            'com.pearson.powerschool.coteach.teacher.aide'
        )
        /*  Ensures at least one student is enrolled - optionally, you can use the
            Sections.No_of_Students field, but that depends on calculations done
            by Reset Class Counts/nightly process/etc. */
        AND EXISTS (
            SELECT 1 FROM CC WHERE ABS(CC.SectionID) = Sections.ID
        )
    ORDER BY
        Sections.ID,
        CASE
            WHEN RoleDef.RoleKey = 'com.pearson.powerschool.coteach.primary.teacher'
            THEN '1'
            ELSE teachers.teachernumber
        END
)
PIVOT (
    MAX(teachernumber)
    FOR PriorityOrder IN (
        1 AS teacher_id,
        2 AS teacher_2_id,
        3 AS teacher_3_id,
        4 AS teacher_4_id,
        5 AS teacher_5_id,
        6 AS teacher_6_id,
        7 AS teacher_7_id,
        8 AS teacher_8_id,
        9 AS teacher_9_id
    )
) Clever
