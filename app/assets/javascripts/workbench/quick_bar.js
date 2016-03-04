$(document).ready(function() {
	if($("#quick_bar").length) {
	    	Mousetrap.bind("h", function(e) {
			window.location = "/hub";
		});
  	}
});

