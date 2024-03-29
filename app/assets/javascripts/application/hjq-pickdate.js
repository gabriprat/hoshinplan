/* pickdate */
(function($) {
    var languages = { 'es' : {
	    monthsFull: [ 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre' ],
	    monthsShort: [ 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic' ],
	    weekdaysFull: [ 'domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado' ],
	    weekdaysShort: [ 'dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb' ],
	    today: 'hoy',
	    clear: 'borrar',
		close: 'cerrar',
	    firstDay: 1
    }, 'en' : {}};
    var methods = {
        init: function(annotations) {
		var that=$(this);
		var language = that.data("date-language");
		var weekstart = that.data("date-week-start");
		var format = that.data("date-format");
		var settings = languages[language];
		var options = {
			format: format.replace("/yyyy",""),
			formatSubmit: format,
			hiddenName: true,
			firstDay: weekstart,
			onClose: methods.triggerChange,
			container: "body",
			klass: {picker: 'dpicker'}
		};
		jQuery.extend(settings, options);
		$(this).pickadate(
			settings
		);
        },
	triggerChange: function(context) {
		this.$node.trigger("changeDate");
		console.log("Trigger changeDate");
	},
	languages: function() {
		return languages;
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
