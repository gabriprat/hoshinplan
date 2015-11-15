var __boxSelect;
var launchBoxSelect = function(elem) {
	loadJs('https://app.box.com/js/static/select.js', null, function() {	
		if (typeof(__boxSelect) == "undefined") {
			__boxSelect = new BoxSelect({
		    	    clientId: 'xp2amwwyx7pmz2zhkco6pe351datue23',
		    	    linkType: 'shared',
		    	    multiselect: 'false'
			});
			__boxSelect.success(function(response) {
				var val = '"'+response[0].name+'":'+response[0].url;
				elem.insertAtCaret(val);
			});
		}
		__boxSelect.launchPopup();
	});
}

var launchDropBoxSelect = function(elem) {
	loadJs('https://www.dropbox.com/static/api/2/dropins.js', {"id":"dropboxjs","data-app-key":"810pe0uue1stsz9"}, function() {	
		Dropbox.choose({
    		    success: function(response) {
				var val = '"'+response[0].name+'":'+response[0].link;
				elem.insertAtCaret(val);
			}
		});
	});
}