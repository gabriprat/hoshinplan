/* image_input */
(function($) {
    var retries = 5;
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
			if (that.find(".placeholder").data("orig-html") == null) {
				that.find(".placeholder").data("orig-html", that.find(".placeholder").html());
			}
			that.find(".placeholder").html('<div class="progress"><div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%">0%</div></div>');
		};
		}(file));
		reader.readAsDataURL(file);
		
		// Uploading - for Firefox, Google Chrome and Safari
		var form = that.closest("form");
		var error = function(xhr, ajaxOptions, thrownError) {
			that.find(".placeholder").html(that.find(".placeholder").data("orig-html"));
		}
		var roptions = that.hjq('buildRequest', {type: 'put', attrs:{ajax:true, complete:methods.complete, error:error}});
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
		roptions["xhr"] = function () {
			var xhr = new window.XMLHttpRequest();
			if (xhr.upload) {
	                    xhr.upload.onprogress = function(event) {
	                        var percent = 0;
	                        var position = event.loaded || event.position; /*event.position is deprecated*/
	                        var total = event.total;
	                        if (event.lengthComputable) {
	                            percent = Math.ceil(position / total * 100);
	                        }
				if (percent == 100) {
					that.find(".placeholder").html('<div class="ic-spinner ic-pulse ic-3x ic-center"></div>');
				} else {
					that.find(".placeholder .progress-bar").attr("aria-value-now", percent)
						.css("width", percent + "%")
						.text(percent + "%");
				}
	                    };
			    
			    xhr.onerror = function(event) {
				    alert(event);
			    }
	                }
			return xhr;
		};
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
		retries = 5;
		setTimeout(methods.setSelect, 50);
	},
	setSelect: function() {
		try {
			if (!window.jcrop_api && retries > 0) {
				retries--;
				setTimeout(methods.setSelect, 50);
			}
			var bounds = window.jcrop_api.getBounds();
			var aspect = bounds[0] / bounds[1];
			if (aspect > 1.0) {
				window.jcrop_api.setSelect([(bounds[0]-bounds[1])/2,0,bounds[1],bounds[1]]);
			} else {
				window.jcrop_api.setSelect([0,(bounds[1]-bounds[0])/2,bounds[0],bounds[0]]);
			}
		} catch(err) {
			if (retries>0) {
				retries--;
				setTimeout(methods.setSelect, 50);
			}
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
