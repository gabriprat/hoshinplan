(function($) {

        $(document).on("rapid:ajax:success", addHtml5Validation);
        $(document).ready(addHtml5Validation);

        function hasHtml5Validation() {
                return typeof document.createElement('input').checkValidity === 'function';
        }
        var moveToFirstEvent = function(elem, eventType, bindType) {
                var events = ($._data(elem, 'events') || {})[eventType];
                var fn;

                if (events && events.length > 1) {
                        fn = events.pop();
                        if (!bindType) {
                                bindType = 'bind';
                        }
                        if (bindType == 'bind' && events.delegateCount) {
                                events.splice(events.delegateCount, 0, fn);
                        } else {
                                events.unshift(fn);
                        }


                }
                elem = null;
        }

                function addHtml5Validation() {
                        if (hasHtml5Validation()) {
                                $('form').each(function() {
                                        $(this).on("submit", function(e) {
                                                if (!this.checkValidity()) {
                                                        e.preventDefault();
                                                        e.stopImmediatePropagation();
                                                        $(this).addClass('invalid');
                                                        $('#status').html('invalid');
                                                        return false;
                                                } else {
                                                        $(this).removeClass('invalid');
                                                        $('#status').html('submitted');
                                                }
                                        });
                                        moveToFirstEvent(this, 'submit');
                                });
                        }
                }

})(jQuery);
