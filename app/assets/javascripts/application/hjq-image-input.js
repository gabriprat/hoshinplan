/* image_input */
(function($) {
    var methods = {
        init: function(annotations) {
		var that = $(this);
		var input = that.find('input');
		var button = that.find("a");
		
		input.change(methods.fileSelect);
		that.on("dragenter", methods.noopHandler)
			.on("dragexit", methods.noopHandler)
			.on("dragover", methods.noopHandler)
			.on("drop", methods.drop);
		button.click(function() { input.click() });
        },
	noopHandler: function(e) {
		var evt = e.originalEvent;
		evt.stopPropagation();
		evt.preventDefault();
	},
	drop: function(e) {
		var evt = e.originalEvent;
		evt.stopPropagation();
		evt.preventDefault();
 
		var files = evt.dataTransfer.files;
		var count = files.length;
 
		// Only call the handler if 1 or more files was dropped.
		if (count > 0)
			methods.handleFile.call(this, files[0]);
	},
	handleFile: function(file) {
		
		var that = $(this);
		if (!file) {
			var img = that.find(".preview img");
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
		    var img = that.find(".preview img");
		    if (!img.data('originalSrc')) {
		    	img.data('originalSrc', img.attr('src'));
		    }
		    img.attr('src', evt.target.result);
		    img.removeAttr('srcset');
		    that.find(".placeholder").html('<div class="ic-spinner ic-pulse ic-3x ic-center"></div>');
		};
		}(file));
		reader.readAsDataURL(file);
		
		var li = document.createElement("li"),
			div = document.createElement("div"),
			img,
			progressBarContainer = document.createElement("div"),
			progressBar = document.createElement("div"),
			reader,
			xhr,
			fileInfo;
			
		li.appendChild(div);
		
		progressBarContainer.className = "progress-bar-container";
		progressBar.className = "progress-bar";
		progressBarContainer.appendChild(progressBar);
		li.appendChild(progressBarContainer);
		
		// Uploading - for Firefox, Google Chrome and Safari
		var form = that.closest("form");		
		var roptions = that.hjq('buildRequest', {type: 'put', attrs:{ajax:true, complete:methods.complete}});
		roptions.data["user[image]"] = file;
		
		form.find(".hidden-fields input").each(function() {
			roptions.data[$(this).attr("name")] = $(this).attr("value");
		});
		var fd = new FormData();
		for (var f in roptions.data) {
			fd.append(f, roptions.data[f]);
		}
		roptions.data = fd;
		roptions['processData'] = false;
		roptions['contentType'] = false;
		$.ajax(form.attr("action"), roptions);
	},
	fileSelect: function(evt) {
	    if (window.File && window.FileReader && window.FileList && window.Blob) {
	        var file = evt.originalEvent.target.files[0];
 	        methods.handleFile.call(this.closest(".image-input"), file);
	    }
	},
	complete: function () {
		window.init_papercrop();
		setTimeout(methods.setSelect, 50);
	},
	setSelect: function() {
		if (!window.jcrop_api) {
			setTimeout(methods.setSelect, 50);
		}
		var bounds = window.jcrop_api.getBounds();
		var aspect = bounds[0] / bounds[1];
		if (aspect > 1.0) {
			window.jcrop_api.setSelect([(bounds[0]-bounds[1])/2,0,bounds[1],bounds[1]]);
		} else {
			window.jcrop_api.setSelect([0,(bounds[1]-bounds[0])/2,bounds[0],bounds[0]]);
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
