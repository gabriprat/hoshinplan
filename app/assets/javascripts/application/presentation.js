
var PRESENTATION_SELECTOR = '.slide-page,div.navbar,div.content-header,.footer';

var presenting = false;
var currentSlide = 1;
var sliding = false;

var navigatePrev = function() {
	var nslides = $('.slide-page').length;
	var area = currentSlide;
	if (currentSlide == 0) {
		area = nslides-1;
	} else {
		area = currentSlide-1;
	}
	slideAreas(currentSlide, area, true);
}

var navigateNext = function() {
	var nslides = $('.slide-page').length;
	var area = currentSlide;
	if (currentSlide == nslides-1) {
		area = 0;
	} else {
		area = currentSlide+1;
	}
	slideAreas(currentSlide, area, false);
}

var slideAreas = function(current, next, reverse) {
	if (current == next || sliding)
		return;
	sliding = true;
	var w = $( document ).width() + "px";
	var mw = "-" + w;
	$($('.slide-page')[next]).css({left: (reverse?mw:w)});
	$($('.slide-page')[next]).animate({left:0}, "slow").toggle();
	$($('.slide-page')[current]).animate({"left":(reverse?w:mw)}, "slow", 
		function() {
			$($('.slide-page')[current]).toggle(); 
			currentSlide = next;
			sliding = false;
		}
	);
} 

var showSlide = function(num) {
	var nslides = $('.slide-page').length;
	var slide = num;
	if (slide >= nslides) {
		slide = nslides-1;
	}
	$('.slide-page').hide();
	$($('.slide-page')[slide]).show().css({left: 0});
	currentSlide = slide;
}

var startPresentation = function() {
	$(PRESENTATION_SELECTOR).hide();
	$('body').addClass('presenting');
	$("div.objectives-wrapper,div.indicators-wrapper,div.tasks-wrapper").height("auto");
	currentSlide = $('.slide-page').length - $('div.area').length;
	currentSlide = currentSlide < 0 ? 0 : currentSlide;
	presenting = true;
	$('.slide-page').width("100%");
	$('.slide-page').css({position:'absolute', left:0, top:0, outline: '1px solid transparent'});
	showSlide(currentSlide);
	equalHeightSections();
	enterFullscreen();
}

var endPresentation = function() {
	$(PRESENTATION_SELECTOR).show();
	$('.slide-page').show();
	var size = parseInt($('body').css('font-size')) - 8;
	$('body').removeClass('presenting');
	$('.slide-page').removeAttr('style');
	presenting = false;
	setTimeout(equalHeightSections,500);
	exitFullscreen();
}

function isFullscreen() {
	return (document.fullscreenElement ||    // alternative standard method
		document.mozFullScreenElement || document.webkitFullscreenElement || document.msFullscreenElement);
}

/**
 * Handling the fullscreen functionality via the fullscreen API
 *
 * @see http://fullscreen.spec.whatwg.org/
 * @see https://developer.mozilla.org/en-US/docs/DOM/Using_fullscreen_mode
 */
function enterFullscreen() {
	if (document.documentElement.requestFullscreen) {
		document.documentElement.requestFullscreen();
	} else if (document.documentElement.msRequestFullscreen) {
		document.documentElement.msRequestFullscreen();
	} else if (document.documentElement.mozRequestFullScreen) {
		document.documentElement.mozRequestFullScreen();
	} else if (document.documentElement.webkitRequestFullscreen) {
		document.documentElement.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
	}
}

function exitFullscreen() {
	if (document.exitFullscreen) {
		document.exitFullscreen();
	} else if (document.msExitFullscreen) {
		document.msExitFullscreen();
	} else if (document.mozCancelFullScreen) {
		document.mozCancelFullScreen();
	} else if (document.webkitExitFullscreen) {
		document.webkitExitFullscreen();
	}
}

function toggleFullscreen() {
	if (isFullscreen()) {
		exitFullscreen();
	} else {
		enterFullscreen();
	}
}

function fsChange() {
	if (isFullscreen()) {
		$(".presentation-help").fadeIn(1000);
		window.setTimeout(function() {
			$(".presentation-help").fadeTo(1500, 0);
		}, 15000);
		startPresentation();
	} else {
		endPresentation();
	}
	$(".modal").modal("hide");
}

var attachKeyEvents = function() {
	$('body').keydown(function(e){
		if (isModalShown()) {
			return;
		}
		/*if (e.which==122 || (e.metaKey && (e.shiftKey || e.ctrlKey) && e.which == 70)) {
			e.preventDefault();
			enterFullscreen();
			return;
		}*/
		if (!presenting || isInputFocused()) {
			return;
		}
		switch( e.which ) {
			// esc
			case 27: endPresentation(); break;
		        // left
		        case 37: e.preventDefault(); navigatePrev(); break;
		        // right
		        case 39: e.preventDefault(); navigateNext(); break;
		        // home
		        case 36: e.preventDefault(); showSlide( 0 ); break;
		        // end
		        case 35: e.preventDefault(); showSlide( Number.MAX_VALUE ); break;
		}
	});
	$(document).on("webkitfullscreenchange mozfullscreenchange fullscreenchange MSFullscreenChange", fsChange );
}
$(document).ready(attachKeyEvents);
