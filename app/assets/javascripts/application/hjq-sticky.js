/* sticky */
(function($) {
    var methods = {
        init: function(annotations) {
		this.stick_in_parent();
        }
    };

    $.fn.hjq_sticky = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_sticky' );
        }
    };

})( jQuery );
