var TW = TW || {};
TW.workbench = TW.workbench || {};
TW.workbench.alert = TW.workbench.alert || {};

Object.assign(TW.workbench.alert, {

	init: function() {
		$(document).on("click", ".alert-close", function() {
			$(this).parent(".alert").animate({
	    		bottom: "-="+ ($(this).height()*2),
	  		}, 250, function() {
	    		$(this).remove();
	  		});	
		});		
	},

	create: function(text) {
		$("body").append('<div class="alert alert-error"><div class="message">' + text + '</div><div class="alert-close"></div></div>');
	}
});

$(document).ready(function() {
	var _init_alerts = TW.workbench.alert;
		_init_alerts.init();
});