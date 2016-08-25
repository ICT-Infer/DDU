select
	courses.code as course_code,
	courses.name as course_name,
	institutions.name as institution_name
from cs_enrolled_students
inner join course_semesters
	on cs_enrolled_students.course_semester = course_semesters.id
inner join courses
	on course_semesters.course = courses.id
inner join institutions
	on courses.institution = institutions.id
where
	person = '1'
	and course_semesters.year = (select extract(year from now()))
	-- If the current month is >= 7, then we are in or after july,
	-- which means that it is the autumn semester. Otherwise, it is
	-- the spring semester as denoted by autumn being false.
	and course_semesters.autumn = (select extract(month from now()) >= 7)
order by courses.code;
