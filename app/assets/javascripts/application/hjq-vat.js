/* vat an input type for VAT numbers */
(function($) {
    var csrf;
    var form;
    var country_input;
    var zip_input;
    var ajax_attrs;

    var methods = {
        init: function(annotations) {
            var that = this;
            var options = this.hjq('getOptions', annotations);
            ajax_attrs = annotations.ajax_attrs;
            country_input = $(options.country_input);
            zip_input = $(options.zip_input);
            var taxes = country_input.val().length > 0 ? country_input.find("option[value=" + country_input.val() + "]").data("taxes") : 0;
            if (taxes > 0) {
                that.prev().html(country_input.val() || "&middot;&middot;");
            } else {
                that.prev().html("&nbsp;&nbsp;");
            }
            zip_input.on("change", function() {
                console.log('----------change')
                that.trigger("vat:validate");
            });
            country_input.on("change", function() {
                var taxes2 = $(this).val().length > 0 ? $(this).find("option[value=" + $(this).val() + "]").data("taxes") : 0;
                if (taxes2 > 0) {
                    that.prev().html(country_input.val() || "&middot;&middot;");
                } else {
                    that.prev().html("&nbsp;&nbsp;");
                }
            });
            csrf = $("meta[name=csrf-token]").attr("content");
            form = that.closest("form");
            this.change(methods.change);
        },
        change: function(target) {
            var that = $(this);
            if (that.val() == "") {
                that.data("valid", false);
                that.trigger("vat:validate");
                return;
            }
            var vat = that.val();
            vat = vat.replace(/[^a-z0-9]/gi,'');
            vat = vat.toUpperCase();
            that.val(vat);
            var value = country_input.val() + that.val();
            var options = {
                method: 'POST',
                data: $.param({
                    'authenticity_token': $('body').find("[data-rapid-page-data]").data("rapid-page-data").form_auth_token.value,
                    'vat_number': value,
                    'country': country_input.val()
                })
            }
            that.next().find(".ic-spinner").show();
            $.ajax("/vat_validator/validate_vat", options).done(function (resp) {
                that.next().find(".ic-spinner").hide();
                that.data("valid", resp.valid);
                var html = "";
                if (resp.errors.length > 0) {
                    html += "<ul>"
                    for (var i=0; i < resp.errors.length; i++) {
                        html += "<li>" + resp.errors[i] + "</li>";
                    }
                    html += "</ul>"
                }
                that.parent().next().html(html);
                that.trigger("vat:validate");
            });
        }
    };

    $.fn.hjq_vat = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_vat' );
        }
    };

})( jQuery );
