/* color_tpc */
(function($) {
    var methods = {
        init: function(annotations) {
		methods.colorize.call(this, annotations.options.tpc);
        },
	colorize: function (tpc) {
		this.heatcolor(
			function() { 
				return tpc>100 ? 100 : tpc<50 ? 50 : tpc;
			 }, 
			{ maxval: 100, minval: 50, colorStyle: 'greentored', lightness: 0.4 }
		);
	}
    };

    $.fn.hjq_color_tpc = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_color_tpc' );
        }
    };

})( jQuery );
