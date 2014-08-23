/* tutorial */
(function($) {
    var methods = {
        init: function(annotations) {
		$("#tutorial-close").click(function() {
			$("#finish-tutorial").submit();
			var off = $("#nav-tutorial a").offset();
			var cms = $("#cms");
			cms.css({position:"absolute", overflow: "hidden", top: cms.offset().top, left: cms.offset().left})
				.animate({top:off.top + 30, width:0, height: 0, left: off.left}, 
					{duration: 1500, easing: "easeOutExpo"});
		});
		methods.update.call(this);
        },
	update: function() {
		var tutorial = $("#tutorial [data-tutorial]");
		if (tutorial.length != 1) {
			return;
		}
		var sel = tutorial.data("tutorial-steps");
		$(sel).addClass("done");
		var step = tutorial.data("tutorial");
		var sel = "#" + step + " a";
		if ($(sel).hjq_ra) {
			$(sel).hjq_ra("click");
		}
	}
    };

    $.fn.hjq_tutorial = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_tutorial' );
        }
    };

})( jQuery );
