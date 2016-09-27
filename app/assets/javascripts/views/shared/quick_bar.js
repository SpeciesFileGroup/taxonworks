$(document).ready(function() {

	if($("#quick_bar").length) {

		createShortcut("alt+h","Show/hide quick bar", "General shortcuts", function() {hideQuickBar()} );

		$('body').append("<div class='button-collapse-header'></div>");
		$('.button-collapse-header').on('click', function() {
			hideQuickBar(250);
		});

		function hideQuickBar(time) {

			if($('.button-collapse-header').css('display') == "none") {
				$('.button-collapse-header').fadeIn(time);
			}
			else {
				$('.button-collapse-header').fadeOut(0);
			}			
			$('#quick_bar').slideToggle(time);
			$('#header_bar').slideToggle(time);
			$('.task_bar').slideToggle(time);
		}

		Mousetrap.bind('alt+ctrl+h', function(e) {
			window.location = "/hub";
		});

		if((window.location.href).indexOf('/tasks/') > 0) {
			hideQuickBar(0);
		}


	}
});

