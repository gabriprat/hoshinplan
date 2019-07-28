//= require handsontable.full

var objectData = [], hot;

var hover = function(index, options, content) {
	var data;
	if ($('#graph-line').data('rapid')) {
		data = $('#graph-line').data('rapid').chart.morris_attrs.data
	}
	if (!data) return content;
	var row = data[index];
	var remove_msg = $("#dynamic-js").data("remove");
    var removeLink = '';
    if ($('#delete-form').length > 0) {
        removeLink = '<a href="javascript:deleteHistory(' + row.id + ', \'' + dateFormatDefault(row.day) + '\');">' + remove_msg + '</a>';
    }
	return content + removeLink;
}

var loadData = function() {
    initNumeral();
	var decChar = numeral.languageData().delimiters.decimal == "," ? "," : "\\.";
	var numRegEx = new RegExp("^\\s*[+-]?\\s*(?:(?:\\d+(?:" + decChar + "\\d+)?(?:e[+-]?\\d+)?)|(?:0x[a-f\\d]+))\\s*$", "i");
	var isNumeric = function(n) {
		var t = typeof n;
		if (t == 'number') {
			return !(isNaN(n) || !isFinite(n));
		} else if (t == 'string') {
			if (!n.length) {
				return false;
			} else if (n.length == 1) {
				return /\d/.test(n);
			} else {
				return numRegEx.test(n);
			}
		} else {
			return false;
		}
	}

	var l = document.documentElement.lang;
	$("#spreadsheet").html("");
	if ($('#graph-line').data('rapid')) {
		objectData = $('#graph-line').data('rapid').chart.morris_attrs.data.map(function(row) {
			return {
				"day": dateFormatDefault(row.origday),
				"value": row.value === null ? "" : numeral(row.value).format("0.[00000000]"),
				"goal": row.goal === null ? "" : numeral(row.goal).format("0.[00000000]"),
				"previous": row.previous === null ? "" : numeral(row.previous).format("0.[00000000]"),
                "comment": row.comment === null ? "" : row.comment
			}
		});
		if (objectData == null) {
			objectData = [];
		}
	}
	var container = document.getElementById('spreadsheet');
	var nullOrNumericValidator = function(value, callback) {
		if (!value || 0 === value.length) {
			callback(true);
		} else {
			if (isNumeric(value)) {
				callback(true);
			} else {
				callback(false);
			}
		}
	};
	hot = new Handsontable(container, {
		data: objectData,
		colHeaders: $("#dynamic-js").data("columns").split(","),
		columns: [{
			data: 'day',
			type: 'date'
		}, {
			type: 'text',
			language: l,
			className: 'htRight',
			validator: nullOrNumericValidator,
			data: 'value'
		}, {
			type: 'text',
			language: l,
			className: 'htRight',
			validator: nullOrNumericValidator,
			data: 'goal'
		}, {
            type: 'text',
            language: l,
            className: 'htRight',
            validator: nullOrNumericValidator,
            data: 'previous'
        }, {
            type: 'text',
            language: l,
            className: 'htRight',
            data: 'comment'
        }],
		dateFormat: $("[data-rapid-page-data]").data('rapid-page-data').dateformat.toUpperCase(),
		correctFormat: true,
		contextMenu: ['row_above', 'row_below', 'remove_row', 'undo', 'redo'],
		minSpareRows: 1
	});
	Handsontable.hooks.add('afterValidate', function(isValid, value, row, prop, source) {
		if (!isValid) {
			hadErrors = true;
			return false;
		}
	}, hot);
}
var hadErrors = false;
var data_update = function() {
	hadErrors = false;
	while (hot.isEmptyRow(objectData.length - 1)) {
		hot.updateSettings({
			minSpareRows: 0
		});
		hot.alter("remove_row", objectData.length - 1);
	}
	hot.validateCells(function(valid) {
		if (hadErrors) {
			return false;
		} else {
			var d = objectData.map(function(o) {
				return {
					"day": o.day,
                    "comment": o.comment,
					"value": (o.value == null || o.value == "")  ? null : numeral(o.value).value(),
					"goal": (o.goal == null || o.goal == "") ? null : numeral(o.goal).value(),
					"previous": (o.previous == null || o.previous == "") ? null :  numeral(o.previous).value()
				}
			});
			$("#json").val(JSON.stringify(d));
			$("#upload").submit();
		}
	});
	return false;
}
$(document).ready(loadData);


function deleteHistory(id, date) {
	var form = $("#delete-form");
	form.attr("action", "/indicator_histories/" + id);
	var conf = form.data("confirm-orig");
	form.data("confirm", conf.replace("XXX", date));
	form.submit();
}

function initNumeral() {
    if (typeof(numeral) == "undefined") {
        return;
    }
    // load a language
    numeral.language('es', {
        delimiters: {
            thousands: '.',
            decimal: ','
        },
        abbreviations: {
            thousand: 'K',
            million: 'M',
            billion: 'B',
            trillion: 'T'
        },
        ordinal : function (number) {
            return 'o';
        },
        currency: {
            symbol: '€'
        }
    });

    // switch between languages
    numeral.language(document.documentElement.lang);
}