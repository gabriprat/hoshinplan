/* bootstrap_switch */
(function($) {
        var methods = {
                init: function(annotations) {
                        var options = this.hjq('getOptions', annotations);
                        this.bootstrapSwitch();
                        for (var key in options) { 
                                this.bootstrapSwitch(key, options[key]);
                        }
                        for (var event in annotations.events) {
                                this.on(event, this.hjq('createFunction', annotations.events[event]));
                        }
                }
        };

        $.fn.hjq_bootstrap_switch = function(method) {

                if (methods[method]) {
                        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
                } else if (typeof method === 'object' || !method) {
                        return methods.init.apply(this, arguments);
                } else {
                        $.error('Method ' + method + ' does not exist on hjq_bootstrap_switch');
                }
        };

})(jQuery);
