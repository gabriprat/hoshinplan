/* vat an input type for VAT numbers */
(function($) {
    var csrf;
    var form;
    var country_input;
    var ajax_attrs;

    var methods = {
        init: function(annotations) {
            var that = this;
            var options = this.hjq('getOptions', annotations);
            ajax_attrs = annotations.ajax_attrs;
            country_input = $(options.country_input);
            if (country_input.data('taxes') > 0) {
                that.prev().html(country_input.val() || "&middot;&middot;");
            } else {
                that.prev().html("&nbsp;&nbsp;");
            }
            country_input.on("change", function() {
                if (country_input.data('taxes') > 0) {
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
