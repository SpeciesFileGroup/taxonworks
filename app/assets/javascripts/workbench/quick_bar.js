$(document).ready(function() {
	if($("#quick_bar").length) {
		Mousetrap.bind('ctrl+h ctrl+h', function(e) {
			window.location = "/hub";
		});

		$('body').append("<div class='button-collapse-header button-collapse-arrow-up'></div>");
		$('.button-collapse-header').on('click', function() {
			if($(this).hasClass('button-collapse-arrow-down')) {
				$(this).removeClass('button-collapse-arrow-down');
				$(this).addClass('button-collapse-arrow-up');
			}
			else {
				$(this).addClass('button-collapse-arrow-down');
				$(this).removeClass('button-collapse-arrow-up');
			}
			$('#quick_bar').slideToggle(250);
			$('#header_bar').slideToggle(250);
		});
	}
});

