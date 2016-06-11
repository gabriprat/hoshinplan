/* hjq-slider */
(function($) {
    var methods = {
        init: function(annotations) {
            var options = this.hjq('getOptions', annotations);
            this.bootstrapSlider(options);
	    for (var event in annotations.events) {
		    this.on(event, this.hjq('createFunction', annotations.events[event]));
	    }
	    this.trigger("create");
        }
    };

    $.fn.hjq_slider = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_slider' );
        }
    };

})( jQuery );
