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

$( window ).resize(function() {
  equalHeightSections();
});


var equalHeightSections = function() {
	if (presenting) return;
	equalHeights($("div.objectives-wrapper"));
	equalHeights($("div.indicators-wrapper"));
	equalHeights($("div.tasks-wrapper"));
}

var equalHeights = function(elements) {
	elements.height("auto");
	var maxHeight = Math.max.apply(null, elements.map(function ()
	{
	    return $(this).height();
	}).get());
	elements.height(maxHeight);
}

var PRESENTATION_SELECTOR = 'div.navbar,div.content-header,div.hoshin-header,div.area,.ordering-handle';

var presenting = false;
var currentArea = 1;

var navigatePrev = function() {
	var nareas = $('div.area').length;
	var area = currentArea;
	if (currentArea == 0) {
		area = nareas-1;
	} else {
		area = currentArea-1;
	}
	slideAreas(currentArea, area, true);
}

var navigateNext = function() {
	var nareas = $('div.area').length;
	var area = currentArea;
	if (currentArea == nareas-1) {
		area = 0;
	} else {
		area = currentArea+1;
	}
	slideAreas(currentArea, area, false);
}

var slideAreas = function(current, next, reverse) {
	var w = $( document ).width() + "px";
	var mw = "-" + w;
	$($('div.area')[next]).css({left: (reverse?mw:w)});
	$($('div.area')[next]).animate({left:0}, "slow").toggle();
	$($('div.area')[current]).animate({"left":(reverse?w:mw)}, "slow", 
		function() {
			$($('div.area')[current]).toggle(); 
			currentArea = next;
		}
	);
} 

var showArea = function(num) {
	var nareas = $('div.area').length;
	var area = num;
	if (area >= nareas) {
		area = nareas-1;
	}
	$('div.area').hide();
	$($('div.area')[area]).show().css({left: 0});
	currentArea = area;
}

var startPresentation = function() {
	$(PRESENTATION_SELECTOR).hide();
	var size = parseInt($('body').css('font-size')) + 8;
	$('body').css('font-size', size);
	$("div.objectives-wrapper,div.indicators-wrapper,div.tasks-wrapper").height("auto");
	presenting = true;
	$('div.area').width("100%");
	$('div.area').css({position:'absolute', left:0, top:0});
	showArea(currentArea);
}

var endPresentation = function() {
	$(PRESENTATION_SELECTOR).show();
	$('div.area').show();
	var size = parseInt($('body').css('font-size')) - 8;
	$('body').css('font-size', size);
	$('div.area').removeAttr('style');
	equalHeightSections();
	presenting = false;
}

/**
 * Handling the fullscreen functionality via the fullscreen API
 *
 * @see http://fullscreen.spec.whatwg.org/
 * @see https://developer.mozilla.org/en-US/docs/DOM/Using_fullscreen_mode
 */
function enterFullscreen() {

        var element = document.body;

        // Check which implementation is available
        var requestMethod = element.requestFullScreen ||
                                                element.webkitRequestFullscreen ||
                                                element.webkitRequestFullScreen ||
                                                element.mozRequestFullScreen ||
                                                element.msRequestFullScreen;

        if( requestMethod ) {
                requestMethod.apply( element );
        }

}

var attatchKeyEvents = function() {
	$('body').keydown(function(e){
		if (!presenting) {
			return;
		}
		switch( e.which ) {
			// esc
			case 27: endPresentation(); break;
		        // left
		        case 37: navigatePrev(); break;
		        // right
		        case 39: navigateNext(); break;
		        // home
		        case 36: showArea( 0 ); break;
		        // end
		        case 35: showArea( Number.MAX_VALUE ); break;
		        // f
		        case 70: enterFullscreen(); break;
		}
	});
}

$(document).ready(attatchKeyEvents);

