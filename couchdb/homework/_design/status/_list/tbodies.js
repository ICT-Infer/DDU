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

/*
 * Produces HTML tbodies of data.
 *
 * TODO: tbody group by week number.
 *
 * TODO: Take time zone as parameter and show adjusted time.
 *
 * MAYBE: Hyper-link only first occurence of each course?
 *
 * TODO: Remove XXX-marked testing parts once consumer has been implemented.
 */

function(head, req)
{
	provides("html", function ()
	{       
		html = "<table><tbody>"; // XXX: '<table>' is for testing

		while (row = getRow())
		{
			html += "<tr>";

			vd = row.value; // view-emitted data values

			html += "<td><a href=\"" + vd.course_url + "\">"
				+ vd.course + "</a></td>";

			html += "<td>" + vd.title + "</td>";

			if ('due_ts' in vd) // _view/pending_delivery
			{
				html += "<td>" + vd.due_date + "</td>";

				html += "<td><date datetime=\""
					+ vd.due_ts + "\">"
					+ vd.due_zclock + "</a></td>";
			}

			if ('delivered_ts' in vd) // _view/pending_review
			{
				html += "<td>" + vd.delivered_date + "</td>";

				html += "<td><date datetime=\""
					+ vd.delivered_ts + "\">"
					+ vd.delivered_zclock + "</a></td>";
			}

			if ('score' in vd) // _view/approved
			{
				html += "<td>" + vd.score + "</td>";
			}

			html += "</tr>";
		}

		html += "</tbody></table>"; // XXX: '</table>' is for testing
		return html;
	});
}
