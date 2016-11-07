// display.js
// A temporary place to write display altering bindings 

function render_attribute_set_headers() {
	$('.attribute_set').each(function() {
		title = '<div class="attribute_set_title">' + $(this).data().title + '<div>';
		$(this).prepend(title);
	});
}

$(document).ready(function() {
	if($('.attribute_set').length > 0) {
		render_attribute_set_headers()
	}
});

//Expand buttons
$(document).ready(function() {
	$('[expand-container]').each(function(i) {

		var id = $(this).attr('expand-container');

		if($(id).css('display') == "none") {
			$(this).addClass('expand');
		}
		else {
			$(this).addClass('contract');
		}
	});

	$('[expand-container]').on('click', function() {
		
		var id = $(this).attr('expand-container');

		if($(id).css('display') == "none") {
			$(this).addClass('contract');
			$(this).removeClass('expand');
		}
		else {
			$(this).removeClass('contract');
			$(this).addClass('expand');
		}
		$(id).toggle(250);
	});
});