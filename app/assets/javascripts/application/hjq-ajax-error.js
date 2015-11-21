/* ajax error toast */
(function($) {
    var default_options = undefined;
    

    $( document ).ajaxError(function() {
	    $(document).hjq_error_toast({});
    });

    // old min_time functionality removed -- using an effect on the
    // removal ensures it stays on screen long enough to be visible.

    var methods = {
        /* without any options, error = $(foo).hjq_error_toast() places a toast
           to the left of foo until you remove it via
           error.hjq_error_toast('remove');

           options:
           - toast-next-to: DOM id of the element to place the toast next to.
           - toast-at: selector for the element to place the toast next to.
           - no-toast: if set, the toast is not displayed.
           - toast-options: passed to [jQuery-UI's position](http://jqueryui.com/demos/position/).   Defaults are `{my: 'left center', at: 'right center', offset: '5 0'}`
           - message: the message to display inside the toast

           If options.message is false-ish, default_message is displayed.

           The toast is returned.
        */
        init: function(options, default_message) {
            // Options from Dryml now come with underscores. This simple workaround turns them to dashes:
            options['toast-options'] = options['toast_options'];
            options['toast-at'] = options['toast_at'];
            options['toast-next-to'] = options['toast_next_to'];
            options['no-toast'] = options['no_toast'];

            var original=$("#ajax-error-wrapper .ajax-error:first");
            if (original.length==0) return $();

            options = $.extend({}, defaultOptions.call(this), options);
            if(options['no-toast']) return $();

            var clone=original.clone();

            clone.find("span").text(options["error-message"] || default_message || "");

            var pos_options = $.extend({}, defaultOptions()['toast-options'], options['toast-options']);

            pos_options.of = this;
            if(options['toast-at']) pos_options.of=$(options['toast-at']);
            else if(options['toast-next-to']) pos_options.of=$("#"+options['toast-next-to']);

            clone.insertBefore(original).show().position(pos_options).delay(5000).fadeOut("slow");
            return clone;
        },

        remove: function() {
            return this.remove();
        }
    };

    var defaultOptions = function() {
        if(default_options) return default_options;
        var page_options = this.hjq('pageData');
        default_options = {};
        default_options['toast-next-to'] = page_options['spinner-next-to'];
        default_options['toast-at'] = page_options['spinner-at'];
        default_options['no-toast'] = page_options['no-spinner'];
        default_options['toast-options'] = page_options['spinner-options'] || {
            my: "right bottom",
            at: "left top",
            collision: "none"
        };
        default_options['error-message'] = page_options['error-message'];
        return default_options;
    };

    $.fn.hjq_error_toast = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_error_toast' );
        }
    };

})( jQuery );
