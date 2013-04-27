var submitClosestForm = function() {
	$(this)
		.closest('form')
		.submit();
}

function attatchAutosubmit() {
	$(".autosubmit input")
		.unbind("change", submitClosestForm).change(submitClosestForm);
	$('.bootstrap-datepicker').datepicker();
}

$(document)
	.ready(attatchAutosubmit);
