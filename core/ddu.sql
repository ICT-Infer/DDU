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

	UNIQUE(parent_location, name)
);

CREATE TABLE institutions (
	id		serial PRIMARY KEY,
	name		varchar(255) NOT NULL,
	location	integer NOT NULL,
	description	varchar(255),

	UNIQUE(name, location)
);

CREATE TABLE courses (
	id		serial PRIMARY KEY,
	institution	integer NOT NULL,
	name		varchar(255) NOT NULL,
	autumn		boolean, -- true: autumn, false: spring.
	year		integer NOT NULL,

	FOREIGN KEY (institution) REFERENCES institutions,

	UNIQUE(institution, name, autumn, year)
);

CREATE TABLE topics (
	id		serial PRIMARY KEY,
	course		integer NOT NULL,
	name		varchar(255) NOT NULL,

	FOREIGN KEY (course) REFERENCES courses,

	UNIQUE(course, name)
);

CREATE TABLE topic_syllabus (
	id		serial PRIMARY KEY,
	topic		integer NOT NULL,
	text		varchar(4096) NOT NULL,
	ordering	integer NOT NULL,

	FOREIGN KEY (topic) REFERENCES topics,

	UNIQUE(topic, text),
	UNIQUE(topic, ordering)
);

CREATE TABLE topic_resources (
	id		serial PRIMARY KEY,
	topic		integer NOT NULL,
	name		varchar(255) NOT NULL,
	url		varchar(4096) NOT NULL,
	ordering	integer NOT NULL,

	FOREIGN KEY (topic) REFERENCES topics,

	UNIQUE(topic, url),
	UNIQUE(topic, ordering)
);

CREATE TABLE course_deliveries (
	id		serial PRIMARY KEY,
	course		integer NOT NULL,
	name		varchar(255) NOT NULL,

	FOREIGN KEY (course) REFERENCES courses,

	UNIQUE(course, name)
);

CREATE TABLE course_delivery_resources (
	id		serial PRIMARY KEY,
	course_delivery	integer NOT NULL,
	name		varchar(255) NOT NULL,
	url		varchar(4096) NOT NULL,

	FOREIGN KEY (course_delivery) REFERENCES course_deliveries,

	UNIQUE(course_delivery, url)
);

CREATE TABLE course_delivery_attempts (
	id		serial PRIMARY KEY,
	course_delivery	integer NOT NULL,
	attempt_number	integer NOT NULL,
	due_date	timestamp with time zone NOT NULL,

	FOREIGN KEY (course_delivery) REFERENCES course_deliveries,

	UNIQUE(course_delivery, attempt_number)
);

CREATE TABLE people (
	id		serial PRIMARY KEY,
	name		varchar(255) NOT NULL,
	ssn		integer NOT NULL,

	UNIQUE(ssn)
);

CREATE TABLE person_mail_addresses (
	id		serial PRIMARY KEY,
	person		integer NOT NULL,
	mail_address	varchar(4096) NOT NULL,

	FOREIGN KEY (person) REFERENCES people,

	UNIQUE(mail_address)
);

CREATE TABLE course_enrolled_students (
	id		serial PRIMARY KEY,
	course		integer NOT NULL,
	person		integer NOT NULL,

	FOREIGN KEY (course) REFERENCES courses,
	FOREIGN KEY (person) REFERENCES people,

	UNIQUE(course, person)
);

CREATE TABLE student_deliveries (
	id			serial PRIMARY KEY,
	course_enrolled_student	integer NOT NULL,
	course_delivery_attempt	integer NOT NULL,
	delivered		timestamp with time zone NOT NULL,
	approved		timestamp with time zone,
	declined		timestamp with time zone,

	FOREIGN KEY (course_enrolled_student) REFERENCES course_enrolled_students,
	FOREIGN KEY (course_delivery_attempt) REFERENCES course_delivery_attempts,

	UNIQUE(course_enrolled_student, course_delivery_attempt)
);
