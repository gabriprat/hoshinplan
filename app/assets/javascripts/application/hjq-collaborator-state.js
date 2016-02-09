/* collaborator_state */
(function($) {
    var methods = {
        init: function(annotations) {
		this.change(methods.change);
        },
	change: function(target) {
		var that = $(this);
		var val = that.val();
		that.nextAll("form." + val).submit();
	}
    };

    $.fn.hjq_collaborator_state = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_collaborator_state' );
        }
    };

})( jQuery );
