/* my-click-editor */
(function($) {
    var methods = {
        init: function(annotations) {
		var that = $(this);
		that.click(function () {
			that.toggle();
			that.next('.in-place-input').toggle().next('.in-place-btn').toggleClass('hide');
		});
		
        }
    };

    $.fn.hjq_my_click_editor = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_my_click_editor' );
        }
    };

})( jQuery );