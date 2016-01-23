/* health */
(function($) {
    var methods = {
        init: function(annotations) {
		$(".health-popover-toggle").popover('destroy');
		$("#health-popover").html("");
		$('.health-popover-toggle').each( function() {
			$(this).popover({
			    container: '#health-popover',
			    html: true,
			    placement: function() {return $( window ).width() < 767 ? 'bottom' : 'right auto'},
				title: function () {
				    var close = '<button type="button" class="close" data-dismiss="modal" aria-hidden="true" onclick="$(\'#health\').popover(\'hide\');$.undim();">&times;</button>';
				    return $(this).data("title") + close;
			    },
			    viewport: function(elem) {  
				    	var sel = null;
				    	var cl = elem.closest('.section').attr('class');
					if (cl) {
						sel = "." + cl.trim().replace(/\s/gi, ".");
					} 
					return {"selector": sel, "padding": "0"};
				}($(this)),
			    content: function () {
			        return $(this).next().html();
			    }
			});
		});
		$( ".health-popover-toggle" ).click(function( event ) {
		  $('.health-popover-toggle').not(this).popover('hide');
		  event.stopPropagation();
		});
		$("#tutorial").hjq_tutorial("update");
		$('body').on('keyup.dismiss.healthPopover', function (e) {
			e.which == 27 && $('.health-popover-toggle').popover('hide');
		});
		$('body').on('click.dismiss.healthPopover', function (e) {
			if ($('#health-popover div.popover:visible').length){
				$('.health-popover-toggle').popover('hide');
			}
		});
        }
    };

    $.fn.hjq_health = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_health' );
        }
    };

})( jQuery );