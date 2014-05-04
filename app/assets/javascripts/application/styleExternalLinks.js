(function( $ ) {
	var getServerAndTld = function(host) {
		var arr = host.split(".");
		arr = arr.slice(Math.max(arr.length - 2, 0));
		return arr.join(".");
	};

	var styleExternalLinks = function(event) {
		var target = $(document);
		if (event.target) {
			target = $(event.target);
		}
		target.find('.in-place-edit a, .description-help a, .header-help a').filter(function() {
		   return this.hostname && getServerAndTld(this.hostname) !== getServerAndTld(location.hostname);
		}).each(function () {
			$(this).addClass("external");
			$(this).attr('target', '_blank');
			$(this).click(function (event) { event.stopPropagation(); });
		});
	}
	$(document).on("rapid:ajax:success", styleExternalLinks);
	$(document).ready(styleExternalLinks);
}( jQuery ));