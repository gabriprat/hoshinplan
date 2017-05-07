/* chart (Draws a chart using Morris.js library) */
(function ($) {
    var rtime = new Date(1, 1, 2000, 12, 00, 00); //Last resize event time
    var timeout = false; //Have we already set a resize timeout?
    var delta = 200; //Milliseconds until chart update after window resize

    var resize = function () {
        rtime = new Date();
        if (timeout === false) {
            timeout = true;
            setTimeout(methods.redraw, delta);
        }
    };

    var methods = {
        init: function (annotations) {
            $(this).click(methods.click);
            $(window).unbind("resize", resize);
            $(window).bind("resize", resize);
            var options = annotations.morris_attrs;
            var functions = ['hoverCallback', 'dateFormat', 'xLabelFormat', 'yLabelFormat'];
            for (i in functions) {
                var func = functions[i];
                if (options[func] && typeof options[func] == "string") {
                    options[func] = eval(options[func]);
                }
            }
            var func = {
                'line': Morris.Line,
                'area': Morris.Area,
                'bar': Morris.Bar,
                'donut': Morris.Donut
            }[annotations.type];
            var chart = func(options);
            $(this).data("chart", chart);
        },
        redraw: function () {
            if (delta > new Date() - rtime) {
                //Still resizing window, wait another delta
                setTimeout(methods.redraw, delta);
            } else {
                timeout = false;
                $('.chart').each(function () {
                    if ($(this).data('chart')) {
                        $(this).data('chart').redraw();
                    }
                });
            }
        }
    };

    $.fn.hjq_chart = function (method) {

        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on hjq_chart');
        }
    };

})(jQuery);

(function (moveTo) {
    Morris.Hover.prototype.moveTo = function (x, y, centre_y) {
        var ret = moveTo.call(this, x, y, centre_y);
        ret.css({top: "auto", bottom: "-90px"});
        return ret;
    };
}(Morris.Hover.prototype.moveTo));
