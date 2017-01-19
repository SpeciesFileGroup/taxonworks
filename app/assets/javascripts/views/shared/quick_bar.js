var TW = TW || {};
TW.views = TW.views || {};
TW.views.shared = TW.views.shared || {};
TW.views.shared.quick_bar = TW.views.shared.quick_bar || {};

Object.assign(TW.views.shared.quick_bar, {

	init_quickBar: function() {
		if($("#quick_bar").length) {

			TW.workbench.keyboard.createShortcut("alt+h","Show/hide quick bar", "General shortcuts", function() { TW.views.shared.quick_bar.hideQuickBar() } );

			$('body').append("<div class='button-collapse-header'></div>");
			$('.button-collapse-header').on('click', function() {
				TW.views.shared.quick_bar.hideQuickBar(250);
			});
		}

		Mousetrap.bind('alt+ctrl+h', function(e) {
			window.location = "/hub";
		});			

		if((window.location.href).indexOf('/tasks/') > 0) {
			this.handleEvents();
			this.hideQuickBar(0);
		}
	},


	handleEvents: function() {
		$(".button-collapse-header").one("mouseenter", function() {
			TW.views.shared.quick_bar.hideQuickBar();
		});		
	},

	hideQuickBar: function(time) {

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
	
});

$(document).ready( function() {
	TW.views.shared.quick_bar.init_quickBar();
});

