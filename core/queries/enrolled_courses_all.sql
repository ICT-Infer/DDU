select
	institutions.slugfrag as institution_slugfrag,
	course_semesters.year as year_slugfrag,
	CASE
		WHEN course_semesters.autumn THEN 'autumn'
		ELSE 'spring'
	END as semester_slugfrag,
	courses.slugfrag as course_slugfrag,
	courses.code as course_code,
	courses.name as course_name,
	institutions.name as institution_name,
	CASE
		WHEN course_semesters.autumn THEN 'Autumn'
		ELSE 'Spring'
	END || ', '
	|| course_semesters.year as semester
from cs_enrolled_students
inner join course_semesters
	on cs_enrolled_students.course_semester = course_semesters.id
inner join courses
	on course_semesters.course = courses.id
inner join institutions
	on courses.institution = institutions.id
where
	person = '1'
order by course_semesters.year, course_semesters.autumn, courses.code;
