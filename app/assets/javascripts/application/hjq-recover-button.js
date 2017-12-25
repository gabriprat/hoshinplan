/* recover-button */
(function($) {
    var methods = {
        init: function(annotations) {
            var that=this;
        }
    };


    $.fn.hjq_recover_button = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_recover_button' );
        }
    };

})( jQuery );