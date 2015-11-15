var __google_oauthToken;
var launchGoogleDriveSelect = function(elem) {
	loadJs('https://apis.google.com/js/api.js', null, function() {	
		var onGoogleAuthApiLoad = function() {
			window.gapi.auth.authorize({
			    'client_id':'561715127660-7mp6jik3o3rveadsmumlivplajiogcls.apps.googleusercontent.com',
			    'scope':['https://www.googleapis.com/auth/drive.readonly']
			},handleGoogleAuthResult);
		} 
		function handleGoogleAuthResult(authResult){
			if(authResult && !authResult.error){
				oauthToken = authResult.access_token;
				__google_oauthToken = oauthToken;
				createPicker(oauthToken);
			}
		}
		function createPicker(oauthToken){    
			var picker = new google.picker.PickerBuilder()
			    .addView(new google.picker.DocsView())
			    .setLocale($('html').attr('lang'))             
			    .addView(new google.picker.DocsUploadView())
			    .setOAuthToken(oauthToken)
			    .setDeveloperKey('AIzaSyDyunqzHgz5ohSQ2dSV69T_tgiecgPZgIs')
			    .setCallback(pickerCallback)
			    .build();
			picker.setVisible(true);
			$('.picker-dialog').css('z-index', 5000);
		}
		
		function pickerCallback(data) {
			var url = 'nothing';
			if (data[google.picker.Response.ACTION] == google.picker.Action.PICKED) {
				var doc = data[google.picker.Response.DOCUMENTS][0];
				var url = doc[google.picker.Document.URL];
				var nm = doc[google.picker.Document.NAME];
				var val = '"'+ nm +'":' + url;
				elem.insertAtCaret(val);
			}
		}
		if (__google_oauthToken == null) {
			gapi.load('auth',{'callback':onGoogleAuthApiLoad}); 
			gapi.load('picker'); 
		} else {
			createPicker(__google_oauthToken);
		}
	});
}

var __boxSelect;
var launchBoxSelect = function(elem) {
	loadJs('https://app.box.com/js/static/select.js', null, function() {	
		if (typeof(__boxSelect) == "undefined") {
			__boxSelect = new BoxSelect({
		    	    clientId: 'xp2amwwyx7pmz2zhkco6pe351datue23',
		    	    linkType: 'shared',
		    	    multiselect: 'false'
			});
		}
		var cb = function(response) {
			var val = '"'+response[0].name+'":'+response[0].url;
			elem.insertAtCaret(val);
		}
		__boxSelect.unregister(__boxSelect.SUCCESS_EVENT_TYPE);
		__boxSelect.success(cb);
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