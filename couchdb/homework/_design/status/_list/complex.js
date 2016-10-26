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
		html += "<style>"
			+ "meter"
			+ "{"
			+	"-webkit-appearance: none;"
			+	"-moz-appearance: none;"
			+	"appearance: none;"
			+	"background: lightgrey;"
			+ "}"
			+ "meter:-moz-meter-optimum::-moz-meter-bar"
			+ "{"
			+	"background: green;"
			+ "}"
			+ "meter:-moz-meter-sub-optimum::-moz-meter-bar"
			+ "{"
			+	"background: yellow;"
			+ "}"
			+ "meter::-webkit-meter-bar"
			+ "{"
			+	"background: lightgrey;"
			+ "}"
			+ "#type-4 meter:-moz-meter-sub-optimum::-moz-meter-bar"
			+ "{"
			+	"background: red;"
			+ "}"
			+ "meter::-webkit-meter-optimum-value"
			+ "{"
			+	"background: green;"
			+ "}"
			+ "meter::-webkit-meter-suboptimum-value"
			+ "{"
			+	"background: yellow;"
			+ "}"
			+ "#type-4 meter::-webkit-meter-suboptimum-value"
			+ "{"
			+	"background: red;"
			+ "}"
			+"</style>";

		function trv_cadu (vd)
		{
/*
			html += "<td>" + vd.due_date + "</td>";

			html += "<td><time datetime=\""
				+ vd.due_ts + "\">"
				+ vd.due_zclock + "</time></td>";
*/
		}

		function trv_cade (vd)
		{
/*
			html += "<td>" + vd.delivered_date + "</td>";

			html += "<td><time datetime=\""
				+ vd.delivered_ts + "\">"
				+ vd.delivered_zclock + "</time></td>";
*/
		}

		function trv_cas (vd)
		{
			html += "<td><meter min=0" + " max=" + vd.score_frac[1]
				+ " optimum=" + vd.score_frac[1] + " low="
				+ vd.score_frac[1] + " value="
				+ vd.score_frac[0] + ">" + vd.score_pct
				+ "</meter></td>";
		}

		function tr (trv, row)
		{
			vd = row.value; // View-provided data.

			html += "<tr>";

			html += "<td>" + vd.course + "</td>";

			html += "<td><a href=\"" + vd.doc_url + "\">"
				+ vd.title + "</a></td>";

			trv(vd);

			html += "</tr>";
		}

		function table (first_row, n, title, ths, trv)
		{
			row = first_row;

			if (row && ('key' in row) && row.key[0] === n)
			{
				html += "<h2>" + title + "</h2>";
				html += "<table id=type-" + n + ">";
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
		ths_cadu = ths_common + "<th colspan=2>Due</th>";
		ths_cade = ths_common + "<th colspan=2>Delivered</th>";
		ths_cas = ths_common + "<th>Score</th>";

		row = getRow();
		row = table(row, 0, "Pending delivery", ths_cadu, trv_cadu);
		row = table(row, 1, "Pending review", ths_cade, trv_cade);
		row = table(row, 2, "Approved", ths_cas, trv_cas);
		row = table(row, 4, "Rejected", ths_cas, trv_cas);
		row = table(row, 5, "Overdue", ths_cadu, trv_cadu);

		return html;
	});
}
