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
		html = "<!DOCTYPE html><html lang=en><head><title>DDU</title>";
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
		html += "</head>";

		function htmltime (datearr)
		{
			var ts = new Date(Date.UTC(datearr[0],
					datearr[1] - 1, datearr[2],
					datearr[3], datearr[4]))
				.toISOString();

			return "<time datetime=" + ts + ">" + ts + "</time>";
		}

		function trv_cas (vd)
		{
			frag = "";

			frag += "<td>"
				+ (vd.has_solution_published ? "Yes" : "No")
				+ "</td>";

			return frag;
		}

		function trv_cadu (vd)
		{
			frag = "";

			frag += "<td>" + htmltime(vd.due) + "</td>";

			return frag;
		}

		function trv_casde (vd)
		{
			frag = "";

			frag += trv_cas(vd);

			frag += "<td>" + htmltime(vd.delivered) + "</td>";

			return frag;
		}

		function trv_cass (vd)
		{
			frag = "";

			frag += trv_cas(vd);

			if (vd.score_frac)
			{
				frag += "<td><meter min=0"
					+ " max=" + vd.score_frac[1]
					+ " optimum=" + vd.score_frac[1]
					+ " low=" + vd.score_frac[1]
					+ " value=" + vd.score_frac[0] + ">"
					+	vd.score_pct
					+ "</meter></td>";
			}
			else
			{
				frag += "<td>N/A</td>";
			}

			return frag;
		}

		function trv_casdu (vd)
		{
			frag = "";
			
			frag += trv_cas(vd);
			frag += trv_cadu(vd);

			return frag;
		}

		function tr (trv, row)
		{
			frag = "";
			vd = row.value; // View-provided data.

			frag += "<tr>";

			frag += "<td>" + vd.course + "</td>";

			frag += "<td><a href=\"" + vd.doc_url + "\">"
				+ vd.title + "</a></td>";

			frag += trv(vd);

			frag += "</tr>";

			return frag;
		}

		function table (first_row, n, title, ths, trv)
		{
			frag = "";
			row = first_row;
			count_valid_semester = 0;

			if (row && ('key' in row) && row.key[0] === n)
			{
				frag += "<h2>" + title + "</h2>";
				frag += "<table id=type-" + n + ">";
				frag += "<thead><tr>" + ths + "</tr></thead>";
				frag += "<tbody>";

				do
				{
					if ((req.query.semester
						&& req.query.semester
							=== row.value.semester)
						|| !req.query.semester)
					{
						frag += tr(trv, row);
						count_valid_semester++;
					}

					row = getRow();

				} while (row && ('key' in row)
					&& row.key[0] === n)

				frag += "</tbody></table>";

				if (count_valid_semester)
				{
					html += frag;
				}
			}

			return row;
		}

		ths_common = "<th>Course</th><th>Assignment</th>";
		ths_solution = "<th>Solution Published?</th>";
		ths_cadu = ths_common + "<th>Due</th>";
		ths_casde = ths_common + ths_solution + "<th>Delivered</th>";
		ths_cass = ths_common + ths_solution + "<th>Score</th>";
		ths_casdu = ths_common + ths_solution + "<th>Due</th>";

		row = getRow();
		row = table(row, 0, "Pending delivery", ths_cadu, trv_cadu);
		row = table(row, 1, "Pending review", ths_casde, trv_casde);
		row = table(row, 2, "Approved", ths_cass, trv_cass);
		row = table(row, 4, "Rejected", ths_cass, trv_cass);
		row = table(row, 5, "Overdue", ths_casdu, trv_casdu);

		html += "<script>"
			+ "function twd (num)" // two digits
			+ "{"
			+	"return ('0' + num).substr(-2);"
			+ "}"
			+ "function localizedt (d)"
			+ "{"
			+	"l = new Date(d.getAttribute('datetime'));"
			+	"d.textContent = "
			+		"twd(l.getMonth() + 1) + '/'"
			+		"+ twd(l.getDate()) + ' '"
			+		"+ twd(l.getHours()) + ':'"
			+		"+ twd(l.getMinutes())"
			+		";"
			+ "}"
			+ "var ds = document.evaluate('//time',document,null,"
				+ "XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,"
				+ "null);"
			+ "for (var i = 0 ; i < ds.snapshotLength ; i++)"
			+ "{"
			+	"localizedt(ds.snapshotItem(i));"
			+ "}"
			+ "</script>";

		return html;
	});
}
