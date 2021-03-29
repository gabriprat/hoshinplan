/* billing */
(function($) {
    var methods = {
        init: function() {
            $("#billing_detail_country").on("change", function(event, value) {
                var taxes = 0;
                if (value && value.taxes) {
                    taxes = value.taxes;
                }
                $(this).data('taxes', taxes);
                $("#billing_detail_vat_number").trigger("change");
            });
            $("#users_input").change(function() {
                    methods.updateQuantity();
            });
            methods.updateQuantity();

            $('input[name=billing_detail\\[active_subscription\\]\\[billing_period\\]]').on('change', function(event) {
                methods.updateNextBilling();
                methods.updatePrice();
            });

            $("#billing_detail_vat_number").on("vat:validate", function() {
                methods.calcTaxes();
                methods.updatePrice();
            });
            methods.updateNextBilling();
            methods.calcTaxes();
            methods.updatePrice();
        },
        initCard: function() {
            var clientSecret = $("#card-element").data('secret');
            var elements = stripe.elements({locale: $('html').attr('lang')});
            var cardElement = elements.create('card');
            cardElement.mount('#card-element');
            $("form.payment").on("submit", function(event) {
                $("#calc-total").val(getValue("total-row"));
                $("#calc-taxes").val(getValue("tax-tpc"));
                event.preventDefault();
                stripe.handleCardSetup(
                    clientSecret, cardElement, {
                        payment_method_data: {
                            billing_details: {
                                name: $('#ccname').val(),
                                address: {
                                    city: $('.billing-detail-city').val(),
                                    country: $('.billing-detail-country').val(),
                                    line1: $('.billing-detail-address-line-1').val(),
                                    line2: $('.billing-detail-address-line-2').val(),
                                    postal_code: $('.billing-detail-zip').val(),
                                    state: $('.billing-detail-state').val(),
                                }
                            }
                        }
                    }
                ).then(stripeResponseHandler);
            });
        },
        updateNextBilling: function() {
            var newPeriod = $("input[name=billing_detail\\[active_subscription\\]\\[billing_period\\]]:checked").val();
            var currentPeriod = $("#subscription-prorate").data("period");
            var nextRenewal = moment($("#subscription-prorate").data("next"));
            if (newPeriod != currentPeriod) {
                nextRenewal = moment().endOf("month").add(1, 'days');
            }
            setValue("next-renewal", nextRenewal);
        },
        updatePrice: function() {
            var period = $(".btn.active > input[name=billing_detail\\[active_subscription\\]\\[billing_period\\]]").val();
            var price = parseFloat($(".btn.active > input[name=billing_detail\\[active_subscription\\]\\[billing_period\\]]").data(period + "-price"));
            var months = period == 'monthly' ? 1 : 12;
            setValue("price", price * months);
            methods.calcPrice();
        },
        updateQuantity: function() {
            var users = parseInt($("#users_input").val());
            setValue("quantity", users);
            methods.calcPrice();
        },
        calcTaxes: function() {
            if ($("#billing_detail_country").length == 0) {
                return;
            }
            var taxes = $("#billing_detail_country").val().length > 0 ? $("#billing_detail_country").find("option[value=" + $("#billing_detail_country").val() + "]").data("taxes") : 0;
            var validVatNumber = $("#billing_detail_vat_number").data("valid");
            if (validVatNumber && ($("#billing_detail_country").val() != "ES" || $("#billing_detail_zip").val().trim().matches(/^(35|38)[0-9]{3}$/))) {
                taxes = 0;
            }
            $("#bill-tax-tpc-value").text(taxes);
        },
        calcPrice: function() {
            var price = getValue("price");
            var quantity = getValue("quantity");
            var taxTpc = getValue("tax-tpc");
            var rowTotal = quantity * price;
            var taxes = rowTotal * taxTpc / 100;
            var total = rowTotal + taxes;
            var last = moment($("#subscription-prorate").data("last"));
            var next = moment($("#subscription-prorate").data("next"));
            var nr = getValueDate("next-renewal");
            if (nr)  next = nr;
            var unit = $("input[name=billing_detail\\[active_subscription\\]\\[billing_period\\]]:checked").val();
            unit = unit == "monthly" ? "month" : "year";
            if (!next.isValid()) {
                next = moment().endOf('month').startOf('day').add(1, 'days');
            }
            if (!last.isValid()) {
                last = next.clone().subtract(1, unit);
            }
            var remaining_days = next.diff(moment().startOf('day'), 'days');
            var total_days = next.diff(last, 'days');
            if (total_days == 366) total_days = 365;
            if (remaining_days < 0) {
                remaining_days = total_days;
            }
            var subscription_remaining = $("#subscription-prorate").data("remaining");
            var pay_now = rowTotal * remaining_days / total_days;
            var credit = $("#subscription-prorate").data("credit");
            pay_now = Math.round(pay_now * 100) / 100
            pay_now = (pay_now - subscription_remaining) * (taxTpc/100+1) - credit;
            if (pay_now < 0) {
                credit = -pay_now;
                pay_now = 0;
                $("#subscription-credit").show();
            } else {
                $("#subscription-credit").hide();
            }
            setValue("total-row", rowTotal);
            setValue("taxes", taxes);
            setValue("total", total);
            setValue("month-remaining-days", remaining_days);
            setValue("pay-now", pay_now);
            setValue("credit", credit);
        }
    };
    
    function getValue(name) {
            return parseLocalFloat($(getSelector(name)).text());
    }

    function getValueDate(name) {
        var format = $('body').find("[data-rapid-page-data]").data("rapid-page-data").dateformat.toUpperCase();
        return moment($(getSelector(name)).text(), format);
    }
    
    function setValue(name, value) {
        var text = "-";
        if (typeof value == "number") {
            text = value.formatMoney();
        } else if (value instanceof moment) {
            var format = $('body').find("[data-rapid-page-data]").data("rapid-page-data").dateformat.toUpperCase();
            text = value.format(format);
        }
        $(getSelector(name)).text(text);
    }
    
    function getSelector(name) {
            return "#bill-" + name + "-value";
    }

    function stripeResponseHandler(response) {

        // Grab the form:
        var $form = $('form.payment');

        if (response.error) { // Problem!
            $form.find('.payment-errors').text(response.error.message);
            $form.find('button').prop('disabled', false); // Re-enable submission

        } else { // Token was created!

            // Get the payment_method:
            var payment_method = response.setupIntent.payment_method;

            // Insert the payment method into the form so it gets submitted to the server:
            $form.append($('<input type="hidden" name="billing_detail[stripe_payment_method]" />').val(payment_method));

            // Submit the form:
            $form.get(0).submit();

        }
    }

    $.billing = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on billing' );
        }
    };
    
})( jQuery );

