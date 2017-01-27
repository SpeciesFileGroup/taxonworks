// display.js
// A temporary place to write display altering bindings 

var TW = TW || {};
TW.workbench = TW.workbench || {};
TW.workbench.display = TW.workbench.display || {};

Object.assign(TW.workbench.display, {
//Expand buttons
	init: function() {

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
	},

	render_attribute_set_headers: function() {
		$('.attribute_set').each(function() {
			title = '<div class="attribute_set_title">' + $(this).data().title + '<div>';
			$(this).prepend(title);
		});
	}
});

$(document).ready(function() {
	var _init_display = TW.workbench.display;
	_init_display.init();

	if($('.attribute_set').length > 0) {
		_init_display.render_attribute_set_headers();
	}
});