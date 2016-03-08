$(document).ready(function() {
	if($("#quick_bar").length) {
	    	Mousetrap.bind('ctrl+h ctrl+h', function(e) {
			window.location = "/hub";
		});
  	}
});