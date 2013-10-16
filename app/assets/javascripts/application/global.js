var submitClosestForm = function() {
	$(this)
		.closest('form')
		.submit();
	return false;
}

var preventDoubleSubmit = function(e) {  
    if (this.beenSubmitted) {
	  e.preventDefault();
      return false;
  } else {
      this.beenSubmitted = true;
	  $(this).unbind("submit").submit(preventDoubleSubmit);
  }
};

var attatchAutosubmit = function() {
	$(".autosubmit input[type=text]")
		.unbind("change", submitClosestForm).change(submitClosestForm);
	$('.bootstrap-datepicker').datepicker();
	$(".autosubmit").unbind("submit", preventDoubleSubmit).submit(preventDoubleSubmit);
	colorize();
}

var colorize = function () {
	$(".indicator-tpc").parent().heatcolor(
		function() {
			var num = $(this).children(".indicator-tpc").text();
			num = num>100 ? 100 : num<50 ? 50 : num;
			return num;
		}, 
		{ maxval: 100, minval: 50, colorStyle: 'greentored', lightness: 0.4 }
	);
}

$(document).ready(attatchAutosubmit);

$(document).ready(function () {
	alert($("div.table.indicators .table-head .table-row :nth-child(2)").prop("tagName"));
	$("div.table.indicators .table-head .table-row :nth-child(3)").css("min-width", "220px");
});
