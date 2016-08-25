select
	courses.code as course_code,
	courses.name as course_name,
	institutions.name as institution_name
from course_enrolled_students
inner join courses
	on course_enrolled_students.course = courses.id
inner join institutions
	on courses.institution = institutions.id
where
	person = '1'
	and courses.year = (select extract(year from now()))
	-- If the current month is >= 7, then we are in or after july,
	-- which means that it is the autumn semester. Otherwise, it is
	-- the spring semester as denoted by autumn being false.
	and courses.autumn = (select extract(month from now()) >= 7)
order by courses.code;
