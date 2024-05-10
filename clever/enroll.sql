select
	cc.schoolid as School_id,
	cc.sectionid as Section_id,
	cc.studentid as Student_id
from
	cc cc
where
	cc.termid >= (SELECT TO_NUMBER(Value)*100 FROM Prefs WHERE Name = 'coursearchiveyear') and
	cc.schoolid IN (115,142,295,200,100)
