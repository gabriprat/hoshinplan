$(window).load(function () {
	var body = $("body");
	var frame = $("#user-feedback-frame");
	var svg = '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 44 44" enable-background="0 0 44 44" class="usrp-button-icon-svg">    <path fill="#FFFFFF" d="M30.1,10.9H13.9c-2.1,0-3.9,1.7-3.9,3.9v9.2c0,2.1,1.7,3.9,3.9,3.9h3.3l8.5,4.4l0-4.4h4.5     c2.1,0,3.9-1.7,3.9-3.9v-9.2C34,12.6,32.3,10.9,30.1,10.9z M25.2,13.8c1.3,0,2.3,1,2.3,2.3c0,1.3-1,2.3-2.3,2.3     c-1.3,0-2.3-1-2.3-2.3C22.9,14.9,23.9,13.8,25.2,13.8z M18.7,13.8c1.3,0,2.3,1,2.3,2.3c0,1.3-1,2.3-2.3,2.3c-1.3,0-2.3-1-2.3-2.3     C16.4,14.9,17.4,13.8,18.7,13.8z M22,25c-3.2,0-6-2.5-7.7-6.2c2.3,2,4.9,3.2,7.7,3.2c2.8,0,5.4-1.2,7.7-3.2C28,22.6,25.2,25,22,25z"></path>   </svg>';
	var host = 'https://feedback.userreport.com';
	var feedbackURL = host + '/64daf682-b7c5-40ba-8fe3-aeb24ec7f4c2/';
	var hover = function() {
		$(this).css("margin-right", 0);
	}
	body.append('<a id="user-feedback" href="'+feedbackURL+'"><span class="svg ic-bullhorn"></span><span class="text">Feedback</span></a>');
	var feedbackDiv = $("#user-feedback");
	feedbackDiv.hover(
	  function () {
	    $(this).addClass("showing");
	  },
	  function () {
	    $(this).removeClass("showing");
	  }
	);
	feedbackDiv.on("click", function() {
		if ($("#user-feedback-frame").length==0) {
			body.append('<div id="user-feedback-frame" class="modal bpnFeedbackPopup" data-rapid="{&quot;modal&quot;:{}}" role="dialog" tabindex="-1"><div class="modal-dialog"><div class="modal-content"><div class="modal-body"><iframe  src="' + $(this).attr("href") + '"></iframe></div></div></div></div>');
			frame = $("#user-feedback-frame");
			frame.hjq().init();
		}
		$(window).on("message", function(event){
			var e = event.originalEvent;
			if (e.origin === host && e.data === 'close-feedback-forum') {
				frame.modal('hide');
			}
		});
		frame.modal('show');
		return false;
	});
});


