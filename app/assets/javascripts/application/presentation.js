
var PRESENTATION_SELECTOR = '.slide-page,div.navbar,div.content-header,div.hoshin-header,.ordering-handle,.column.ordering,.footer';

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
	var size = parseInt($('body').css('font-size')) + 8;
	$('body').css({'font-size': size, 'overflow-x': 'hidden'});
	$("div.objectives-wrapper,div.indicators-wrapper,div.tasks-wrapper").height("auto");
	currentSlide = $('.slide-page').length - $('div.area').length;
	currentSlide = currentSlide < 0 ? 0 : currentSlide;
	presenting = true;
	$('.slide-page').width("100%");
	$('.slide-page').css({position:'absolute', left:0, top:0, outline: '1px solid transparent'});
	showSlide(currentSlide);
}

var endPresentation = function() {
	$(PRESENTATION_SELECTOR).show();
	$('.slide-page').show();
	var size = parseInt($('body').css('font-size')) - 8;
	$('body').removeAttr('style');
	$('.slide-page').removeAttr('style');
	presenting = false;
	equalHeightSections();
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

var attachKeyEvents = function() {
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
		        case 36: showSlide( 0 ); break;
		        // end
		        case 35: showSlide( Number.MAX_VALUE ); break;
		        // f
		        case 70: enterFullscreen(); break;
		}
	});
}
$(document).ready(attachKeyEvents);
