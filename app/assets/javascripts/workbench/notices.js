$(document).ready(function() {
	$(document).on("click", ".alert-close", function() {
		$(this).parent(".alert").animate({
    		bottom: "-="+ ($(this).height()*2),
  		}, 250, function() {
    		$(this).remove();
  		});	
	});
});