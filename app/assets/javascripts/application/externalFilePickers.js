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
				createPicker(oauthToken);
			}
		}
		function createPicker(oauthToken){    
			var picker = new google.picker.PickerBuilder()
			    .addView(new google.picker.DocsUploadView())
			    .addView(new google.picker.DocsView())                
			    .setOAuthToken(oauthToken)
			    .setDeveloperKey('AIzaSyDyunqzHgz5ohSQ2dSV69T_tgiecgPZgIs')
			    .setCallback(pickerCallback)
			    .build();
			picker.setVisible(true);
		}
		
		function pickerCallback(data) {
			var url = 'nothing';
			if (data[google.picker.Response.ACTION] == google.picker.Action.PICKED) {
				var doc = data[google.picker.Response.DOCUMENTS][0];
				url = doc[google.picker.Document.URL];
				var val = '"'+ url +'":' + url;
				elem.insertAtCaret(val);
			}
		}
		gapi.load('auth',{'callback':onGoogleAuthApiLoad}); 
		gapi.load('picker'); 
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