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
