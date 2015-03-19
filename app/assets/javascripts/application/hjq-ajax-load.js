/* ajax-load */
(function($) {
    var methods = {
        init: function(annotations) {
		var that = $(this);
		setTimeout( function(){ that.click(); }, 300 );
        }
    };

    $.fn.hjq_ajax_load = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_ajax_load' );
        }
    };

})( jQuery );