/* hjq-slider */
(function ($) {
    var methods = {
        init: function (annotations) {
            var that = $(this);
            var options = that.hjq('getOptions', annotations);
            var slider = that.before('<div class="slider"></div>').prev()[0];

            noUiSlider.create(slider, {
                start: that.val(),
                connect: [true, false],
                tooltips: [true],
                behaviour: "tap",
                step: 1,
                range: {
                    'min': options.min,
                    'max': options.max
                },
                format: {
                    to: function ( value ) {
                        return Math.round(value);
                    },
                    from: function ( value ) {
                        return Math.round(value);
                    }
                }
            });

            slider.noUiSlider.on('update', function( values, handle ) {
                if ( handle ) {
                    that.val(values[handle]);
                } else {
                    that.val(values[0]);
                }
                that.trigger("change");
            });

            for (var event in annotations.events) {
                this.on(event, this.hjq('createFunction', annotations.events[event]));
            }
            this.trigger("create");
        }
    };

    $.fn.hjq_slider = function (method) {

        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on hjq_slider');
        }
    };

})(jQuery);
