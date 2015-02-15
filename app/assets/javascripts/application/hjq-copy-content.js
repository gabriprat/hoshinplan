/* copy-content */
(function($) {
    var methods = {
        init: function(annotations) {
		var that = $(this);
		var source = $(annotations.source);
		that.html(source.html());
        }
    };

    $.fn.hjq_copy_content = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_copy_content' );
        }
    };

})( jQuery );