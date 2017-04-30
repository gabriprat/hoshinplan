/* filters */
(function ($) {
    var methods = {
        init: function (annotations) {
            var options = this.hjq('getOptions', annotations);
            var that = this;
            $(that.data('target')).find('input[type=checkbox]').on('change.filter', function() {
               filterPostits();
            });
        }
    };

    $.fn.hjq_filters = function (method) {

        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on hjq_filters');
        }
    };

})(jQuery);