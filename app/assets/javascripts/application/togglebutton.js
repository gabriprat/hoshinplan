/* togglebutton */
(function($) {
        var methods = {
                init: function(annotations) {
                        for (var event in annotations.events) {
                                this.on(event, this.hjq('createFunction', annotations.events[event]));
                        }
                }
        };

        $.fn.hjq_togglebutton = function(method) {

                if (methods[method]) {
                        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
                } else if (typeof method === 'object' || !method) {
                        return methods.init.apply(this, arguments);
                } else {
                        $.error('Method ' + method + ' does not exist on hjq_togglebutton');
                }
        };

})(jQuery);
