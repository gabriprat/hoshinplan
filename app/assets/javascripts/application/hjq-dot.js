/* dot */
(function($) {
    var methods = {
        init: function(annotations) {
		var left = annotations.left;
		var top = annotations.top;
		var size = annotations.size;
		if ($.isNumeric(left)) {
			left += "px"
		}
		if ($.isNumeric(top)) {
			top += "px"
		}
		if ($.isNumeric(size)) {
			size += "px"
		}
		$(this).css({"left": left, "top": top, "width": size, "height": size})
        }
    };

    $.fn.hjq_dot = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_dot' );
        }
    };

})( jQuery );