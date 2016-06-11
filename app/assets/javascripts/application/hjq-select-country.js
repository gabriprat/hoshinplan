/* hjq-select_country */
(function($) {
    var methods = {
        init: function(annotations) {
                var that = this;
                var opts = this.hjq('getOptions', annotations);
                var countries = null;
                var hidden = this.nextAll("input[type=hidden]");
                opts.source = function(query, process) {
                    if (countries == null) {
                            $.get('/countries/complete_name', {}, function(data) {
                                    countries = data;
                                    process(countries);
                            });
                    } else {
                            process(countries);
                    }
                }
                opts.afterSelect = function(value) {
                    hidden.val(value.id);
                    hidden.trigger('change', value);
                }
                this.change(function() {
                    hidden.val("");
                    hidden.trigger('change');
                });
                this.typeahead(opts);
        }
    };

    $.fn.hjq_select_country = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_select_country' );
        }
    };

})( jQuery );
