/* timer */
(function($) {
    var methods = {
        init: function(annotations) {
		var options = this.hjq('getOptions', annotations);
		this.on('update', options.update);
		methods.update.call(this, options.percent)
        },
	update: function(percent) {
		this.timer(percent);
		this.trigger("update");
	}
    };

    $.fn.hjq_timer = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_timer' );
        }
    };

})( jQuery );
