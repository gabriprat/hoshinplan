/* connectedsortable */
(function($) {
    var methods = {
        init: function(annotations) {
		var that = $(this);
		var annotations=that.data('rapid')['connectedsortable'];
		that.sortable({
		  connectWith: annotations.connect_with,
		  items: "li:not(.not-draggable)",
		  stop: function (event, ui) {
		      var that = ui.item.closest(".connected-sortable");
		      var annotations = that.data('rapid')['connectedsortable'];
		      $form = that.find(".csupdate.formlet");
		      $form.find("input[name='task[status]']").val(annotations.list_id);
		      $form.find("input[name='task[lane_pos]']").val(ui.item.index());
		      $form.data('rapid').formlet.form_attrs.action = "/tasks/" + ui.item.data("id");
		      $form.hjq_formlet("submit");
		  }
		}).disableSelection();
		
        }
    };

    $.fn.hjq_connectedsortable = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_click_editor' );
        }
    };

})( jQuery );
