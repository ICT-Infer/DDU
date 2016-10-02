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

function (doc)
{
	function twd (num) // two digits
	{
		return ("00" + num).substr(-2);
	}

	function course_url (cid) // Course ID array to URL string
	{
		return "/en_US/edu/" + cid[0] + "/" + cid[1]
			+ "/" + cid[2] + ".htm";
	}

	function darr2zts (arr) // UTC date array to time stamp string
	{
		return arr[0] + "-" + twd(arr[1]) + "-" + twd(arr[2])
			+ "T" + twd(arr[3]) + ":" + twd(arr[4]) + "Z";
	}

	function darr2zd (arr) // UTC date array to date string
	{
		return twd(arr[1]) + "/" + twd(arr[2]);
	}

	function darr2zc (arr) // UTC date array to clock string
	{
		return twd(arr[3]) + ":" + twd(arr[4]);
	}

	if (doc.delivered && !doc.approved && !doc.rejected)
	{
		course_id = [doc.institution, doc.semester, doc.course];
		key = [1, doc.due, course_id];
		value = {};

		value._rev = doc._rev;
		// TODO: Add script revision as a value attribute.
		value.course_url = course_url(course_id);
		value.course = doc.course;
		value.title = "Oblig " + twd(doc.assignment_num)
			+ ": " + doc.title;

		value.delivered_ts = darr2zts(doc.delivered);
		value.delivered_date = darr2zd(doc.delivered);
		value.delivered_zclock = darr2zc(doc.delivered);

		emit(key, value);
	}
}
