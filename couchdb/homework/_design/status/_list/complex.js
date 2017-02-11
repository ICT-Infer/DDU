/*
 * Copyright (c) 2016, 2017 Erik Nordstrøm <erikn@ict-infer.no>
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
		if (req.query.semester && !req.query.semester.match(
			/^([0-9]{4,})\/(autumn|spring)$/))
		{
			return "Invalid semester format.";
		}

		if (req.query.course && !req.query.course.match(
			/^([A-Z]{3,4})([0-9]{2}|[0-9]{4})([A-Z])?$/))
		{
			return "Invalid course format.";
		}

		// TODO: Refuse invalid request params

		function sname (semid)
		{
			sparts = semid.split('/');

			return sparts[1].charAt(0).toUpperCase()
				+ sparts[1].slice(1) + " " + sparts[0];
		}

		title = "DDU";

		snamev = "";
		if (req.query.semester)
		{
			snamev = sname(req.query.semester);
			title = snamev + " - " + title;
		}

		html = "<!DOCTYPE html><html lang=en><head><title>"
				+ title + "</title>";
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

		//html += "<p>" + JSON.stringify(req) + "</p>";

		function htmltime (datearr)
		{
			var ts = new Date(Date.UTC(datearr[0],
					datearr[1] - 1, datearr[2],
					datearr[3], datearr[4]))
				.toISOString();

			return "<time datetime=" + ts + ">" + ts + "</time>";
		}

		function querystr (qobj)
		{
			qcount = 0;
			qparams = ["semester", "course"];
			qstr = "";

			for (i = 0 ; i < qparams.length ; i++)
			{
				qparam = qparams[i];

				if (qparam in qobj)
				{
					qstr += (!qcount ? "?" : "&amp;");
					qstr += qparam + "=" + qobj[qparam];
					qcount++;
				}
			}

			return qstr;
		}

		function trv_casol (vd)
		{
			return "<td>"
				+ (vd.has_solution_published ? "Yes" : "No")
				+ "</td>";
		}

		function trv_cadu (vd)
		{
			return "<td>" + htmltime(vd.due) + "</td>";
		}

		function trv_casde (vd)
		{
			return trv_casol(vd)
				+ "<td>" + htmltime(vd.delivered) + "</td>";
		}

		function trv_cass (vd)
		{
			frag = "";

			frag += trv_casol(vd);

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
			return trv_casol(vd) + trv_cadu(vd);
		}

		function tr (trv, row)
		{
			frag = "";
			vd = row.value; // View-provided data.

			frag += "<tr>";

			changeq = {};
			if (req.query.course)
			{
				changeq.course = req.query.course;
			}
			if (req.query.semester)
			{
				changeq.semester = req.query.semester;
			}

			if (!req.query.semester)
			{
				changeq.semester = vd.semester;

				frag += "<td><a href='"
					+ req.raw_path.split('?')[0]
					+ querystr(changeq) + "'>"
						+ sname(vd.semester)
					+ "</a></td>";
			}

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

		ths_common = (req.query.semester ? "" : "<th>Semester</th>")
			+ "<th>Course</th><th>Assignment</th>";

		ths_sol = "<th>Solution Published?</th>";

		ths_cadu = ths_common + "<th>Due</th>";
		ths_casde = ths_common + ths_sol + "<th>Delivered</th>";
		ths_cass = ths_common + ths_sol + "<th>Score</th>";
		ths_casdu = ths_common + ths_sol + "<th>Due</th>";

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
