--
-- Copyright (c) 2016 Erik Nordstrøm <erikn@ict-infer.no>
--
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--

CREATE TABLE locations (
	id		serial PRIMARY KEY,
	parent_location	integer,
	name		varchar(255) NOT NULL,

	FOREIGN KEY (parent_location) REFERENCES locations,

	UNIQUE(parent_location, name)
);

COMMENT ON TABLE locations IS 'A recursively named geographical location. Typically one would add the country with no parent and then add a state with said country as parent and finally add a city with the state in question as its parent. The locations table is referenced by the institutions table.';

COMMENT ON COLUMN locations.parent_location IS 'The id of the parent location if any, otherwise NULL.';

COMMENT ON COLUMN locations.name IS 'The name of the geographical location, be it a country, a state, a city, or similar.';

CREATE TABLE institutions (
	id		serial PRIMARY KEY,
	slugfrag	varchar(32) NOT NULL,
	name		varchar(255) NOT NULL,
	location	integer NOT NULL,
	description	varchar(255),

	FOREIGN KEY (location) REFERENCES locations,

	UNIQUE(name, location)
);

COMMENT ON TABLE institutions IS 'Institutions of education.';

COMMENT ON COLUMN institutions.slugfrag IS 'Slug fragment for the construction of URLs. SHALL NOT contain any characters which are not HTTP URL safe. SHALL NOT contain any forward slash ("/") characters. Usually the abbreviated name of the institution. Example: For the Massachusetts Institute of Technology, one would likely use "MIT" (without the quotation marks) as the slug fragment.';

COMMENT ON COLUMN institutions.name IS 'The name of the institution.';

COMMENT ON COLUMN institutions.location IS 'The id of the location of the institution.';

COMMENT ON COLUMN institutions.description IS 'An optional, short, description of the institution.';

CREATE TABLE courses (
	id		serial PRIMARY KEY,
	slugfrag	varchar(32) NOT NULL,
	institution	integer NOT NULL,
	code		varchar(255) NOT NULL,
	name		varchar(255) NOT NULL,

	FOREIGN KEY (institution) REFERENCES institutions,

	UNIQUE(institution, code)
);

COMMENT ON TABLE courses IS 'A one-semester course offered at an institution of education. If an institution has a course which spans multiple semesters, use multiple entries to represent said course. If the course consists of multiple parts with separate examinations, it might make sense to represent these parts as separate courses. The year and semester information for a course is in a separate table in order for recurring courses (courses with the same code over multiple years -- the system allows for variations in the contents of the course over time) to easily be represented and for example to be compared over multiple years. Example: At NTNU i Gjøvik, there is a course called ELE1071 which has a duration of two semesters. Furthermore, in the second semester, there were two quite separate parts. In my DB, I have represented this course as three separate courses; course with code ELE1071-S1 for the first semester, and courses with codes ELE1071-S2-EC and ELE1071-S2-EM for the second semester.';

COMMENT ON COLUMN courses.slugfrag IS 'Slug fragment for the construction of URLs. SHALL NOT contain any characters which are not HTTP URL safe. SHALL NOT contain any forward slash ("/") characters. It is recommended that the slug resembles the code of the course as closely as possible.';

COMMENT ON COLUMN courses.institution IS 'The id of the instituiton at which the course is/was offered.';

COMMENT ON COLUMN courses.code IS 'The code of the course. It is probably almost universal for courses offered at institutions of education to have some short code name. Example: MITx has a course with code name "6.004.1x".';

COMMENT ON COLUMN courses.name IS 'The name of the course.';

CREATE TABLE course_semesters (
	id		serial PRIMARY KEY,
	course		integer NOT NULL,
	autumn		boolean NOT NULL, -- true: autumn, false: spring.
	year		integer NOT NULL,

	FOREIGN KEY (course) REFERENCES courses,

	UNIQUE(course, autumn, year)
);

COMMENT ON TABLE course_semesters IS 'Semesters during which a course was / is / will be offered.';

COMMENT ON COLUMN course_semesters.course IS 'The id of the course.';

COMMENT ON COLUMN course_semesters.autumn IS 'Whether the semester entry for this course is for the autumn, in which case the value of this field is to be set to True, or if it is for the spring, in which case this field is to be set to False.';

COMMENT ON COLUMN course_semesters.year IS 'The year of the semester entry for this course.';

CREATE TABLE cs_topics (
	id		serial PRIMARY KEY,
	course_semester	integer NOT NULL,
	name		varchar(255) NOT NULL,
	ordering	integer NOT NULL,

	FOREIGN KEY (course_semester) REFERENCES course_semesters,

	UNIQUE(course_semester, name),
	UNIQUE(course_semester, ordering)
);

COMMENT ON TABLE cs_topics IS 'The topics for a given semester of a course.';

COMMENT ON COLUMN cs_topics.course_semester IS 'The id of the course semester.';

COMMENT ON COLUMN cs_topics.name IS 'The name of the topic.';

COMMENT ON COLUMN cs_topics.ordering IS 'An integer used for ordering of the topics within a course semester.';

CREATE TABLE topic_syllabus (
	id		serial PRIMARY KEY,
	topic		integer NOT NULL,
	text		varchar(4096) NOT NULL,
	ordering	integer NOT NULL,

	FOREIGN KEY (topic) REFERENCES cs_topics,

	UNIQUE(topic, text),
	UNIQUE(topic, ordering)
);

COMMENT ON TABLE topic_syllabus IS 'The syllabus of a topic. Usually references to chapters in the text books associated with the course semester of which the topic is part.';

COMMENT ON COLUMN topic_syllabus.topic IS 'The id of the topic with which this syllabus is associated.';

COMMENT ON COLUMN topic_syllabus.text IS 'The text for the syllabus entry.';

COMMENT ON COLUMN topic_syllabus.ordering IS 'An integer used for ordering of the syllabus within a topic.';

CREATE TABLE topic_resources (
	id		serial PRIMARY KEY,
	topic		integer NOT NULL,
	name		varchar(255) NOT NULL,
	url		varchar(4096) NOT NULL,
	ordering	integer NOT NULL,

	FOREIGN KEY (topic) REFERENCES cs_topics,

	UNIQUE(topic, url),
	UNIQUE(topic, ordering)
);

COMMENT ON TABLE topic_resources IS 'URLs for material relating to a topic. Examples of things to put here include links to YouTube videos, links to PDFs with recommended exercises and so on.';

COMMENT ON COLUMN topic_resources.topic IS 'The id of the topic with which this resource is associated.';

COMMENT ON COLUMN topic_resources.url IS 'The URL of the resource entry.';

COMMENT ON COLUMN topic_resources.ordering IS 'An integer used for ordering of the resources within a topic.';

CREATE TABLE delivery_types (
	id	serial PRIMARY KEY,
	name	varchar(255) NOT NULL,
	fmtstr	varchar(255) NOT NULL,

	UNIQUE(name)
);

COMMENT ON TABLE delivery_types IS 'Types of deliveries across all courses.';

COMMENT ON COLUMN delivery_types.name IS 'The name of the delivery type.';

COMMENT ON COLUMN delivery_types.fmtstr IS 'Format string for the delivery type to use when presenting a delivery. The only valid format character is %d, which is replaced by the number of the delivery. See the pre-populated data for some examples.';

-- Pre-populate with some common kinds of delivery types.
INSERT INTO delivery_types (name, fmtstr) VALUES
	('Obligatory assignment', 'Oblig %d'),
	('Prelab', 'Prelab, lab %d'),
	('Journal', 'Journal, lab %d'),
	('Report', 'Report, lab %d');

CREATE TABLE cs_deliveries (
	id		serial PRIMARY KEY,
	course_semester	integer NOT NULL,
	delivery_type	integer NOT NULL,
	name		varchar(255) NOT NULL,
	num		integer NOT NULL,

	FOREIGN KEY (course_semester) REFERENCES course_semesters,
	FOREIGN KEY (delivery_type) REFERENCES delivery_types,

	UNIQUE(course_semester, delivery_type, name),
	UNIQUE(course_semester, delivery_type, num)
);

COMMENT ON TABLE cs_deliveries IS 'Deliveries assosciated with a course semester.';

COMMENT ON COLUMN cs_deliveries.course_semester IS 'The id of the course semester with which a delivery is associated.';

COMMENT ON COLUMN cs_deliveries.delivery_type IS 'The id of the type of delivery that this delivery is.';

COMMENT ON COLUMN cs_deliveries.name IS 'The name of the delivery. This should be a descriptive name which reflects the *content* of a delivery. Example: "Diode circuits".';

COMMENT ON COLUMN cs_deliveries.num IS 'The number of the delivery. Count from 1 for each type of assignment. Example: A course might have eleven obligatory assignments, eight prelab assignments, eight lab journals and one lab report to be delivered -- each of these would then be numbered as such.';

CREATE TABLE csd_resources (
	id		serial PRIMARY KEY,
	cs_delivery	integer NOT NULL,
	name		varchar(255) NOT NULL,
	url		varchar(4096) NOT NULL,

	FOREIGN KEY (cs_delivery) REFERENCES cs_deliveries,

	UNIQUE(cs_delivery, url)
);

COMMENT ON TABLE csd_resources IS 'Resources associated with a delivery. Most importantly, all deliveries SHOULD have a document containing the details for the exercise or other kind of work which the students are going to make delivery for.';

COMMENT ON COLUMN csd_resources.cs_delivery IS 'The id of the course semester delivery with which this resource is associated.';

COMMENT ON COLUMN csd_resources.name IS 'The name of the resource. Examples: "Assignment text", "Introductory video".';

COMMENT ON COLUMN csd_resources.url IS 'The URL of the resource.';

CREATE TABLE csd_attempts (
	id		serial PRIMARY KEY,
	cs_delivery	integer NOT NULL,
	attempt_number	integer NOT NULL,
	due_date	timestamp with time zone NOT NULL,

	FOREIGN KEY (cs_delivery) REFERENCES cs_deliveries,

	UNIQUE(cs_delivery, attempt_number)
);

COMMENT ON TABLE csd_attempts IS 'It is usual for students which fail on first attempt at delivering something to be given another chance. This table lists the attempt number batches and due dates of said attempt batches for a delivery in a course semester.';

COMMENT ON COLUMN csd_attempts.cs_delivery IS 'The id of the course semester delivery with which this attempt is associated.';

COMMENT ON COLUMN csd_attempts.attempt_number IS 'The number of the attempt batch.';

COMMENT ON COLUMN csd_attempts.due_date IS 'The due date of the attempt batch.';

CREATE TABLE people (
	id		serial PRIMARY KEY,
	name		varchar(255) NOT NULL,
	ssn		varchar(255) NOT NULL,

	UNIQUE(ssn)
);

COMMENT ON TABLE people IS 'Every person in the system, identified by their Social Security Number (SSN). In case the use of SSN has unacceptable impliactions on the privacy and/or security of students and faculty staff, use some other unique value in this field instead. Just make sure you know where the unique value comes from so that you do not end up with multiple entries for the same person.';

COMMENT ON COLUMN people.name IS 'The full name of a person.';

COMMENT ON COLUMN people.ssn IS 'The Social Security Number (SSN) of a person. In case the use of SSN has unacceptable impliactions on the privacy and/or security of students and faculty staff, use some other unique value in this field instead. Just make sure you know where the unique value comes from so that you do not end up with multiple entries for the same person.';

CREATE TABLE person_mail_addresses (
	id		serial PRIMARY KEY,
	person		integer NOT NULL,
	mail_address	varchar(4096) NOT NULL,

	FOREIGN KEY (person) REFERENCES people,

	UNIQUE(mail_address)
);

COMMENT ON TABLE person_mail_addresses IS 'E-mail addresses associated with people.';

COMMENT ON COLUMN person_mail_addresses.person IS 'The id of the person.';

COMMENT ON COLUMN person_mail_addresses.mail_address IS 'The e-mail address of the person.';

CREATE TABLE cs_enrolled_students (
	id		serial PRIMARY KEY,
	course_semester	integer NOT NULL,
	person		integer NOT NULL,

	FOREIGN KEY (course_semester) REFERENCES course_semesters,
	FOREIGN KEY (person) REFERENCES people,

	UNIQUE(course_semester, person)
);

COMMENT ON TABLE cs_enrolled_students IS 'People enrolled as students in a course semester.';

COMMENT ON COLUMN cs_enrolled_students.course_semester IS 'The id of a course semester in which a person is enrolled.';

COMMENT ON COLUMN cs_enrolled_students.person IS 'The id of a person enrolled in a course semester.';

CREATE TABLE csd_graders (
	id		serial PRIMARY KEY,
	course_semester	integer NOT NULL,
	person		integer NOT NULL,

	FOREIGN KEY (course_semester) REFERENCES course_semesters,
	FOREIGN KEY (person) REFERENCES people,

	UNIQUE(course_semester, person)
);

COMMENT ON TABLE csd_graders IS 'People who grade deliveries for a given course during a semester. This could for example be course lecturers or student assistants.';

COMMENT ON COLUMN course_semester.course_semester IS 'The id of a course which a person is set to grade deliveries for.';

COMMENT ON COLUMN course_semester.person IS 'The id of a person who is set to grade deliveries for a course semester.';

CREATE TABLE student_deliveries (
	id			serial PRIMARY KEY,
	cs_enrolled_student	integer NOT NULL,
	csd_attempt		integer NOT NULL,
	delivered		timestamp with time zone NOT NULL,
	approved		timestamp with time zone,
	declined		timestamp with time zone,
	graded_by		integer,

	FOREIGN KEY (cs_enrolled_student) REFERENCES cs_enrolled_students,
	FOREIGN KEY (csd_attempt) REFERENCES csd_attempts,
	FOREIGN KEY (graded_by) REFERENCES csd_graders,

	UNIQUE(cs_enrolled_student, csd_attempt)
);

COMMENT ON TABLE course_semesters IS 'Deliveries made by students. This is, like, the raison d''être for DDU... or, at least it was when I started writing it. Now it has grown quite a bit in potential beyond what I originally imagined.';

COMMENT ON COLUMN course_semesters.cs_enrolled_student IS 'The id of a student enrolled in a course.';

COMMENT ON COLUMN course_semesters.csd_attempt IS 'The course semester delivery attempt batch which which this delivery is associated.';

COMMENT ON COLUMN course_semesters.delivered IS 'The datetime at which the delivery was made or last modified.';

COMMENT ON COLUMN course_semesters.approved IS 'The datetime at which the delivery was approved, in case it was approved. If the delivery was not approved, this must be set to NULL.';

COMMENT ON COLUMN course_semesters.rejected IS 'The datetime at which the delivery was rejected, in case it was rejected. If the delivery was not rejected, this must be set to NULL.';

COMMENT ON COLUMN course_semesters.graded_by IS 'The id of the course semester grader that graded the delivery.';
