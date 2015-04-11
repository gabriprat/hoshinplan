/* connectedsortable */
(function($) {
    var methods = {
        init: function(annotations) {
		var options=this.hjq('getOptions', annotations);
		this.sortable(options).disableSelection();
		
        }
    };

    $.fn.hjq_connectedsortable = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_click_editor' );
        }
    };

})( jQuery );
