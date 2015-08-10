/* hjq-slider */
(function($) {
    var methods = {
        init: function(annotations) {
            var options = $.extend({"value": parseFloat(this.val())}, this.hjq('getOptions', annotations));
            this.bootstrapSlider(options);
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
