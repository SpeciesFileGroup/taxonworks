$(document).ready(function() {
	$(".alert").on("click", ".alert-close", function() {
		$(this).parent().fadeOut(250);
	});
});