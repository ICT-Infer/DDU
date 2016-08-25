select
	courses.code as course_code,
	courses.name as course_name,
	institutions.name as institution_name,
	CASE
		WHEN courses.autumn THEN 'Autumn'
		ELSE 'Spring'
	END || ', ' || courses.year as semester
from course_enrolled_students
inner join courses
	on course_enrolled_students.course = courses.id
inner join institutions
	on courses.institution = institutions.id
where
	person = '1'
order by courses.year, courses.autumn, courses.code;
