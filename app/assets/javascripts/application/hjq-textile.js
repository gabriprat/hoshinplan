/* textile-editor */
(function($) {
    var methods = {
        init: function(annotations) {
		new MyTextileEditor($(this).attr('id'), 'extended');
		if ($(this).is(":hidden")) {
			$(this).prev(".textile-toolbar").hide();
			$(this).focus(function() {$(this).prev(".textile-toolbar").show();});
		}
        }
    };

    $.fn.hjq_textile_editor = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_textile_editor' );
        }
    };

})( jQuery );