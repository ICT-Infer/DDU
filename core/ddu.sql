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

CREATE TABLE institutions (
	id		serial PRIMARY KEY,
	slugfrag	varchar(32) NOT NULL,
	name		varchar(255) NOT NULL,
	location	integer NOT NULL,
	description	varchar(255),

	FOREIGN KEY (location) REFERENCES locations,

	UNIQUE(name, location)
);

CREATE TABLE courses (
	id		serial PRIMARY KEY,
	slugfrag	varchar(32) NOT NULL,
	institution	integer NOT NULL,
	code		varchar(255) NOT NULL,
	name		varchar(255) NOT NULL,

	FOREIGN KEY (institution) REFERENCES institutions,

	UNIQUE(institution, code)
);

CREATE TABLE course_semesters (
	id		serial PRIMARY KEY,
	course		integer NOT NULL,
	autumn		boolean NOT NULL, -- true: autumn, false: spring.
	year		integer NOT NULL,

	FOREIGN KEY (course) REFERENCES courses,

	UNIQUE(course, autumn, year)
);

CREATE TABLE cs_topics (
	id		serial PRIMARY KEY,
	course_semester	integer NOT NULL,
	name		varchar(255) NOT NULL,

	FOREIGN KEY (course_semester) REFERENCES course_semesters,

	UNIQUE(course_semester, name)
);

CREATE TABLE topic_syllabus (
	id		serial PRIMARY KEY,
	topic		integer NOT NULL,
	text		varchar(4096) NOT NULL,
	ordering	integer NOT NULL,

	FOREIGN KEY (topic) REFERENCES cs_topics,

	UNIQUE(topic, text),
	UNIQUE(topic, ordering)
);

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

CREATE TABLE delivery_types (
	id	serial PRIMARY KEY,
	name	varchar(255) NOT NULL,
	fmtstr	varchar(255) NOT NULL,

	UNIQUE(name)
);

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

CREATE TABLE csd_resources (
	id		serial PRIMARY KEY,
	cs_delivery	integer NOT NULL,
	name		varchar(255) NOT NULL,
	url		varchar(4096) NOT NULL,

	FOREIGN KEY (cs_delivery) REFERENCES cs_deliveries,

	UNIQUE(cs_delivery, url)
);

CREATE TABLE csd_attempts (
	id		serial PRIMARY KEY,
	cs_delivery	integer NOT NULL,
	attempt_number	integer NOT NULL,
	due_date	timestamp with time zone NOT NULL,

	FOREIGN KEY (cs_delivery) REFERENCES cs_deliveries,

	UNIQUE(cs_delivery, attempt_number)
);

CREATE TABLE people (
	id		serial PRIMARY KEY,
	name		varchar(255) NOT NULL,
	ssn		varchar(255) NOT NULL,

	UNIQUE(ssn)
);

CREATE TABLE person_mail_addresses (
	id		serial PRIMARY KEY,
	person		integer NOT NULL,
	mail_address	varchar(4096) NOT NULL,

	FOREIGN KEY (person) REFERENCES people,

	UNIQUE(mail_address)
);

CREATE TABLE cs_enrolled_students (
	id		serial PRIMARY KEY,
	course_semester	integer NOT NULL,
	person		integer NOT NULL,

	FOREIGN KEY (course_semester) REFERENCES course_semesters,
	FOREIGN KEY (person) REFERENCES people,

	UNIQUE(course_semester, person)
);

-- People who grade deliveries for a given course during a semester.
CREATE TABLE csd_graders (
	id		serial PRIMARY KEY,
	course_semester	integer NOT NULL,
	person		integer NOT NULL,

	FOREIGN KEY (course_semester) REFERENCES course_semesters,
	FOREIGN KEY (person) REFERENCES people,

	UNIQUE(course_semester, person)
);

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
