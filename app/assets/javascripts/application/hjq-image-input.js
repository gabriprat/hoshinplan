/* image_input */
(function($) {
    var methods = {
        init: function(annotations) {
		$(this).find('input').change(methods.fileSelect);
        },
	fileSelect: function(evt) {
	    var that = $(this);
	    if (window.File && window.FileReader && window.FileList && window.Blob) {
	        var file = evt.originalEvent.target.files[0];
 	        if (!file) {
 	        	var img = that.siblings(".preview").find("img");
			img.attr('src', img.data('originalSrc'));
			return;
 	        }
	        var result = '';
        
		    // if the file is not an image, continue
		    if (!file.type.match('image.*')) {
		        return;
		    }

		    reader = new FileReader();
		    reader.onload = (function (tFile) {
		        return function (evt) {
		            var img = that.siblings(".preview").find("img");
			    if (!img.data('originalSrc')) {
			    	img.data('originalSrc', img.attr('src'));
			    }
			    img.attr('src', evt.target.result);
		        };
		    }(file));
		    reader.readAsDataURL(file);
	    }
	}
    };

    $.fn.hjq_image_input = function( method ) {

        if ( methods[method] ) {
            return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on hjq_image_input' );
        }
    };

})( jQuery );
