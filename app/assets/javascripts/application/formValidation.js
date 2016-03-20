(function($) {
        String.prototype.capitalizeFirstLetter = function() {
                return this.charAt(0).toUpperCase() + this.slice(1);
        }
        var fieldset = $('<fieldset><textarea required="" /></fieldset>')[0];
        var tmp;
        var progress = document.createElement('progress');
        var output = document.createElement('output');
        
        supportFieldsetElements = ('elements' in fieldset);
        if ((supportFieldsetDisabled = ('disabled' in fieldset))) {
                try {
                        if (fieldset.querySelector(':invalid')) {
                                fieldset.disabled = true;
                                tmp = !fieldset.querySelector(':invalid') && fieldset.querySelector(':disabled');
                        }
                } catch (er) {}
                supportFieldsetDisabled = !! tmp;
        }

        var supportFormValidation = typeof document.createElement('input').checkValidity === 'function';
        var supportDatalist = !! (('options' in document.createElement('datalist')) && window.HTMLDataListElement);
        var bustedWidgetUi = !supportFieldsetDisabled || !supportFieldsetElements || !('value' in progress) || !('value' in output);
        var bustedValidity = window.opera || bustedWidgetUi || !supportDatalist;

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

        var addHtml5Validation = function() {
                $('form input, form select, form textarea').on('invalid', function(e) {
                        var msg = e.target.validationMessage || 'invalid content';
                        $(e.target).popover({
                                placement: 'bottom',
                                trigger: 'manual',
                                html: true,
                                content: '<div class="validation-message ic-exclamation"></div>' + msg.capitalizeFirstLetter()
                        }).popover('show');
                        $(e.target).on('change', function() {
                                $(this).popover('destroy');
                        });
                });
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
        if (!supportFormValidation || bustedValidity) {
                $(document).on("rapid:ajax:success", addHtml5Validation);
                $(document).ready(addHtml5Validation);
        }
})(jQuery);
