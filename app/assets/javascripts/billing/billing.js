/* billing */
(function($) {
    var methods = {
        init: function() {
            var card = new Card({
                form: '#form-payment-container', // *required*
                // a selector or DOM element for the container
                // where you want the card to appear
                container: '.card-wrapper', // *required*

                width: 350, // optional — default 350px

                // Strings for translation - optional
                messages: {
                    validDate: '',
                    monthYear: $('input[name=expiry]').attr('placeholder'), // optional - default 'month/year'
                },

                // Default placeholders for rendered fields - optional
                placeholders: {
                    number: '•••• •••• •••• ••••',
                    name: $('input[name=name]').attr('placeholder'),
                    expiry: '••/••',
                    cvc: '•••'
                },

                // if true, will log helpful messages for setting up Card
                debug: false // optional - default false
            });

            $("form.payment").on("submit", function(event) {
                var exp = $("#ccexpiry").val().split("/").map(function (s) { return s.trim() });
                $("#calc-total").val(getValue("total-row"));
                $("#calc-taxes").val(getValue("tax-tpc"));
                if (exp.length == 2) {
                    event.preventDefault();
                    Stripe.card.createToken({
                        name: $('#ccname').val(),
                        number: $('#ccnumber').val(),
                        cvc: $('#cccvc').val(),
                        exp_month: exp[0],
                        exp_year: exp[1],
                        address_line1: $('.billing-detail-address-line-1').val(),
                        address_line2: $('.billing-detail-address-line-2').val(),
                        address_state: $('.billing-detail-state').val(),
                        address_zip: $('.billing-detail-zip').val(),
                        address_city: $('.billing-detail-city').val(),
                        address_country: $('.billing-detail-country').val()
                    }, stripeResponseHandler);
                }
            });

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
            var taxes = $("#billing_detail_country").val().length > 0 ? $("#billing_detail_country").find("option[value=" + $("#billing_detail_country").val() + "]").data("taxes") : 0;
            var validVatNumber = $("#billing_detail_vat_number").data("valid");
            if (validVatNumber && $("#billing_detail_country").val() != "ES") {
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

    function stripeResponseHandler(status, response) {

        // Grab the form:
        var $form = $('form.payment');

        if (response.error) { // Problem!
            // Show the errors on the form
            if (response.error.param){
                var errorField = response.error.param.indexOf("exp_") == 0 ? 'expiry' : response.error.param;
                errorField =  $('#cc' + errorField);
                if (errorField.length == 1) {
                    errorField.closest(".form-group").addClass("has-error is-focused");
                    errorField.focus();
                } else {
                    $('.card-details .form-group').addClass("has-error is-focused");
                    $('.card-details .form-group input:first').focus();
                }
            }
            $form.find('.payment-errors').text(response.error.message);
            $form.find('button').prop('disabled', false); // Re-enable submission

        } else { // Token was created!

            // Get the token ID:
            var token = response.id;

            // Insert the token into the form so it gets submitted to the server:
            $form.append($('<input type="hidden" name="billing_detail[card_stripe_token]" />').val(token));

            // Insert card details
            $form.append($('<input type="hidden" name="billing_detail[card_name]" />').val(response.card.name));
            $form.append($('<input type="hidden" name="billing_detail[card_brand]" />').val(response.card.brand));
            $form.append($('<input type="hidden" name="billing_detail[card_last4]" />').val(response.card.last4));
            $form.append($('<input type="hidden" name="billing_detail[card_exp_month]" />').val(response.card.exp_month));
            $form.append($('<input type="hidden" name="billing_detail[card_exp_year]" />').val(response.card.exp_year));

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

