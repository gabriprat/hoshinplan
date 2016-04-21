/* hjq-stripe */
(function($) {
        var methods = {
                init: function(annotations) {
                        var config = annotations.config;
                        var that = this;
                        config.token = function(token) {
                                var form = that.closest("form");
                                form.find("input[name=stripeToken]").val(token.id);
                                form.submit();
                        }

                        var handler = StripeCheckout.configure(config);

                        this.on('click.handler', function(e) {
                                handler.open(annotations.open);
                                if (typeof mixpanel === "object" && typeof mixpanel.track === "function") {
                                        mixpanel.track("Checkout", {
                                                amount: annotations.open.amount/100, 
                                                currency: annotations.open.currency, 
                                                frequency: annotations.frequency,
                                                name: annotations.name,
                                                company_id: annotations.company_id
                                        });
                                }
                                e.preventDefault();
                        });

                        // Close Checkout on page navigation
                        $(window).on('popstate', function() {
                                handler.close();
                        });
                }
        };

        $.fn.hjq_stripe = function(method) {

                if (methods[method]) {
                        return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
                } else if (typeof method === 'object' || !method) {
                        return methods.init.apply(this, arguments);
                } else {
                        $.error('Method ' + method + ' does not exist on hjq_stripe');
                }
        };

})(jQuery);
