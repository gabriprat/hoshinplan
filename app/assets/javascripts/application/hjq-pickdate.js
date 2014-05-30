/* pickdate */
(function($) {
    var methods = {
        init: function(annotations) {
		var that=$(this);
		var language = that.data("date-language");
		var weekstart = that.data("date-weekstart");
		var format = that.data("date-format");
		var languages = { 'es' : {
		    monthsFull: [ 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre' ],
		    monthsShort: [ 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic' ],
		    weekdaysFull: [ 'domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado' ],
		    weekdaysShort: [ 'dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb' ],
		    today: 'hoy',
		    clear: 'borrar',
		    firstDay: 1
		}, 'en' : {}};
		var settings = languages[language];
		var options = {
			format: format,
			firstDay: weekstart,
			onClose: methods.triggerChange,
			editable: true
		};
		jQuery.extend(settings, options);
		$(this).pickadate(
			settings
		);
        },
	triggerChange: function(context) {
		this.$node.trigger("changeDate");
		console.log("Trigger changeDate");
	}
    };

    $.fn.hjq_pickdate = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_pickdate' );
        }
    };

})( jQuery );
