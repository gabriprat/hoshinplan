/* hjq-select_all_checkbox */
(function ($) {
    var methods = {
        init: function (annotations) {
            var opts = this.hjq('getOptions', annotations);
            var selector = opts.selector;
            var cs = $(selector);
            methods.changeStatus(cs);
            cs.on('click.selectAllCheckbox', methods.changeStatus.bind(this, cs));
            $(this).on('click.selectAllCheckbox', methods.click.bind(this, cs));
        },
        click: function (cs) {
            var checked = $(this).is(":checked");
            cs.prop('checked', checked);
        },
        changeStatus: function (cs) {
            var allChecked = cs.filter(':checked').length === cs.length;
            $(this).attr('checked', allChecked);
        }
    };

    $.fn.hjq_select_all_checkbox = function (method) {

        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on hjq_select_all_checkbox');
        }
    };

})(jQuery);
