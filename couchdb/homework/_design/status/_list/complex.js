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

function(head, req)
{
	provides("html", function ()
	{
		html = "<!DOCTYPE html><html lang=en><head><title>DDU</title></head>";

		function trv_pd (vd)
		{
			html += "<td>" + vd.due_date + "</td>";

			html += "<td><time datetime=\""
				+ vd.due_ts + "\">"
				+ vd.due_zclock + "</time></td>";
		}

		function trv_pr (vd)
		{
			html += "<td>" + vd.delivered_date + "</td>";

			html += "<td><time datetime=\""
				+ vd.delivered_ts + "\">"
				+ vd.delivered_zclock + "</time></td>";
		}

		function trv_app (vd)
		{
			html += "<td>" + vd.score + "</td>";
		}

		function tr (trv, row)
		{
			html += "<tr>";

			vd = row.value; // view-emitted data values

			html += "<td><a href=\"" + vd.course_url + "\">"
				+ vd.course + "</a></td>";

			html += "<td>" + vd.title + "</td>";

			trv(vd);

			html += "</tr>";
		}

		function table (first_row, n, title, ths, trv)
		{
			row = first_row;

			if (row && ('key' in row) && row.key[0] === n)
			{
				html += "<h2>" + title + "</h2>";
				html += "<table>";
				html += "<thead><tr>" + ths + "</tr></thead>";
				html += "<tbody>";

				do
				{
					tr(trv, row);
					row = getRow();
				} while (row && ('key' in row) && row.key[0] === n)

				html += "</tbody></table>";
			}

			return row;
		}

		ths_common = "<th>Course</th><th>Assignment</th>";
		ths_pd = ths_common + "<th colspan=2>Due</th>";
		ths_pr = ths_common + "<th colspan=2>Delivered</th>";
		ths_app = ths_common + "<th>Score</th>";

		row = getRow();
		row = table(row, 0, "Pending delivery", ths_pd, trv_pd);
		row = table(row, 1, "Pending review", ths_pr, trv_pr);
		row = table(row, 2, "Approved", ths_app, trv_app);

		return html;
	});
}
