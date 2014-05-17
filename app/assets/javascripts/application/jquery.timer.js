$.fn.timer = function(percent, href){
	var tpcHtml = '<div class="percent"></div>';
	if (href) {
		tpcHtml = '<a href="' + href + '" class="percent"></a>';
	}
	this.html('<div class="slice'+(percent > 50?' gt50':'')+'"><div class="pie"></div><div class="pie fill"></div></div><div class="bg"></div>' + tpcHtml);
	var that = this;	
	$(this).heatcolor(
	function() {
		return percent;
	}, 
	{ maxval: 100, minval: 0, colorStyle: 'greentored', lightness: 0.4, 
	  elementFunction: function() {return $(this).children(".percent")}
  	 });
	$(this).children(".percent").each(function() {
		var col = $(this).css("background-color");
		$(this).css("background-color", "transparent");
		$(this).parent().find(".pie").css("border-color", col);
	});
	this.find('.percent').html(Math.round(percent)+'%');
	this.show();
	var deg = 360/100*percent;
	var d1 = Math.max(0, (percent-50)*2/50);
	var d2 = Math.min(percent, 50)*2/50;
	var deg2 = Math.min(180,deg);
	if (percent>50) {
		$(this).find('.slice').css({'clip':'rect(0, 1em, 1em, 0)'});
		$(this).find('.slice .pie.fill').css({	
	        '-webkit-transition': 'transform '+d1+'s linear 2s, width 0s linear 2s',
	        '-moz-transition': 'transform '+d1+'s linear 2s, width 0s linear 2s',
	        '-o-transition': 'transform '+d1+'s linear 2s, width 0s linear 2s',
	        'transition': 'transform '+d1+'s linear 2s, width 0s linear 2s'});
		$(this).find('.slice .pie.fill').css({	
		'width':'0.8em',    
		'-moz-transform':'rotate('+deg+'deg)',
		'-webkit-transform':'rotate('+deg+'deg)',
		'-o-transform':'rotate('+deg+'deg)',
		'transform':'rotate('+deg+'deg)',
		});
	}
	$(this).find('.slice .pie:not(.fill)').css({
	        '-webkit-transition': 'transform '+d2+'s linear',
	        '-moz-transition': 'transform '+d2+'s linear',
	        '-o-transition': 'transform '+d2+'s linear',
	        'transition': 'transform '+d2+'s linear'});
	$(this).find('.slice .pie:not(.fill)').css({
		'-moz-transform':'rotate('+deg2+'deg)',
		'-webkit-transform':'rotate('+deg2+'deg)',
		'-o-transform':'rotate('+deg2+'deg)',
		'transform':'rotate('+deg2+'deg)'
		});
}
