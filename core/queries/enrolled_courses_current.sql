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
	and courses.year = '2016'
	and courses.autumn
order by courses.code;
