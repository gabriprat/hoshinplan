/* ra (remote a: loads the href into the target element using AJAX) */
(function($) {
    var methods = {
        init: function(annotations) {
		this.click(methods.click);
        },
	click: function(target) {
		var 	that = $(this),
			loadurl = that.attr('href'),
			targ = that.attr('data-target');

		$.get(loadurl, function(data) {
			$(targ).html(data);
		});
		return false;
	}
    };

    $.fn.hjq_ra = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_ra' );
        }
    };

})( jQuery );
