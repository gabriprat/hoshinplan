/* autosubmit */
(function($) {
    var methods = {
        init: function(annotations) {
		var that = $(this)
		that.find("input[type=text]").focus(methods.focus);
		that.find("input[type=text]").blur(methods.blur);
		that.find("button[type=submit], input[type=submit]").mousedown(methods.cancelBlur);
		that.find(".autosubmit-toggle").click(methods.toggle);
		that.find("form.autosubmit").submit(methods.submit);
		
        },
	focus: function(event) {
	        $(this).data('originalValue', this.value);
		$(this).on("changeDate", methods.submitClosestForm);
		
	},
	cancelBlur: function() {
		var that = $(this).closest('div.autosubmit')
		that.find("input[type=text]").off("blur");
	},
	blur: function(event) {
		var that = $(this);
		var original = that.data('originalValue');
		if (original !== this.value) {
			methods.submitClosestForm.call(this);
		} else {
			methods.toggle.call(this);
		}
	},
	toggle: function() {
		var that = $(this).closest('div.autosubmit')
		var $form = that.find("form.autosubmit");
		that.find(".autosubmit-toggle").each( function () {
			$(this).toggle();
			that.find("form.autosubmit").toggle();
			that.find("form.autosubmit input[type=text]:visible").first().focus();
		});
	},
	submit: function(e) {
		var $form = $(this);
		$(this).closest('div.autosubmit').find(".autosubmit-toggle").text("Saving...");
		$form.data('submitted', true);
		$form.find("input[type=text]").blur(methods.blur);
		$(this).find(".bootstrap-datepicker").off("changeDate");
	},
	submitClosestForm: function() {
		var $form = $(this).closest("form.autosubmit");
		if (!$form.data('submitted')) {
			$form.data('submitted', true);
			$form.submit();
		}
	}
    };

    $.fn.hjq_autosubmit = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_click_editor' );
        }
    };

})( jQuery );