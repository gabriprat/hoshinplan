/* bootstrap_switch */
(function($) {
    var methods = {
        init: function(annotations) {
		var options = this.hjq('getOptions', annotations);
		this.bootstrapSwitch();
		if (options.size) {
			this.bootstrapSwitch("size", options.size);
		}
		if (options.change) {
			this.on('switchChange.bootstrapSwitch', options.change);
		}
        }
    };

    $.fn.hjq_bootstrap_switch = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_bootstrap_switch' );
        }
    };

})( jQuery );
