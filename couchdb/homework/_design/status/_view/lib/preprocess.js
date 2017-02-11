/*
 * Copyright (c) 2016 Erik Nordstrøm <erikn@ict-infer.no>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

// NOTE: Document validation is not a concern of this function.
var assignment = function (doc)
{
	/*
	 * Helper functions
	 */

	function twd (num) // two digits
	{
		return ("0" + num).substr(-2);
	}

	/*
	 * Document processing -- meta data
	 */

	result = {};

	// Every CouchDB document has an ID and a revision. We pass these on.
	result._id = doc._id;
	result._rev = doc._rev;

	// URL to edit CouchDB document
	result.doc_url = "/_utils/#/database/homework/" + doc._id;

	// Keep institution, semester and course
	result.institution = doc.institution;
	result.semester = doc.semester;
	result.course = doc.course;

	// Key used for filtering
	result.course_id = [doc.institution, doc.semester, doc.course];

	// Keep assignment number
	result.assignment_num = doc.assignment_num;

	// Keep assignment type
	result.assignment_type = doc.assignment_type;

	// Keep comment. NOTE: Comment is for storing notes about the entry.
	if (doc.comment)
	{
		result.comment = doc.comment;
	}

	/*
	 * Document processing -- main fields
	 */

	// Keep files
	if (doc.files)
	{
		result.files = doc.files;
	}

	// Course name
	result.course = doc.course;

	// Assignment title, pt. 1
	if (doc.assignment_type === "oblig")
	{
		result.title = "Oblig " + twd(doc.assignment_num)
	}
	else if (doc.assignment_type === "journal")
	{
		result.title = "Journal " + twd(doc.assignment_num)
	}
	else if (doc.assignment_type === "report")
	{
		result.title = "Report " + twd(doc.assignment_num)
	}
	else if (doc.assignment_type === "lab")
	{
		result.title = "Lab assignments " + twd(doc.assignment_num)
	}
	// Assignment title, pt. 2
	if (doc.title)
	{
		result.title += ": " + doc.title;
	}

	// Keep due date
	result.due = doc.due;

	// Status, pt. 1
	if (doc.overdue)
	{
		result.overdue = doc.overdue;
		result.sid = 5;
	}
	else if (!doc.delivered)
	{
		result.pending_delivery = true;
		result.sid = 0;
	}
	else if (doc.delivered)
	{
		result.delivered = doc.delivered;
		result.sid = 1;

		if (doc.approved)
		{
			result.approved = doc.approved;
			result.sid = 2;
		}
		else if (doc.rejected)
		{
			result.rejected = doc.rejected;
			result.sid = 4;
		}
	}
	// Status, pt. 2
	if ((result.approved || result.rejected)
		&& result.assignment_type === "oblig")
	{
		result.score_frac = doc.score;
		result.score_ratio = doc.score;
		result.score_pct = (100 * (doc.score[0]
			/ doc.score[1])).toFixed(2) + "%";
	}
	if (!result.pending_delivery && doc.has_solution_published)
	{
		result.has_solution_published = true;
	}

	return result;
};

// CommonJS bindings
if (typeof(exports) === 'object')
{
	exports.assignment = assignment;
};
