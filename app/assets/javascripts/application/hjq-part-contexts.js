/* part_contexts (adds AJAX loaded part context to the page scripts) */
(function($) {
    var methods = {
        init: function(annotations) {
            var pd = $("[data-rapid-page-data]").data('rapid-page-data');
            $.each(annotations, function(key, value) {
                pd.hobo_parts[key] = value;
            });
            $("[data-rapid-page-data]").data('rapid-page-data', pd);
        }
    };

    $.fn.hjq_part_contexts = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_part_contexts' );
        }
    };

})( jQuery );
