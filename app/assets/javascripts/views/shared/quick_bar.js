var TW = TW || {};
TW.views = TW.views || {};
TW.views.shared = TW.views.shared || {};
TW.views.shared.quick_bar = TW.views.shared.quick_bar || {};

Object.assign(TW.views.shared.quick_bar, {

	init_quickBar: function() {
		var timer;		
									
		if($("#quick_bar").length) {

			TW.workbench.keyboard.createShortcut("alt+h","Show/hide quick bar", "General shortcuts", function(that) { 
				TW.views.shared.quick_bar.hideShowBars();
			});

			$('body').append("<div class='button-collapse-header'></div>");
		}

		Mousetrap.bind('alt+ctrl+h', function(e) {
			window.location = "/hub";
		});			

		$('.button-collapse-header').on("mouseenter", function() {
			if($("#quick_bar").attr("data-hide-quickbar-active")) {
		        if(timer) {
		            clearTimeout(timer);
		            timer = null
		        }		
		        timer = setTimeout( function() {		
					if(!$("#quick_bar").attr("data-hide-quickbar")) {
						$("#quick_bar").attr("data-hide-quickbar", "true");
						TW.views.shared.quick_bar.hideQuickBar();
					}
				}, 200);
			}
		});	
		$('#quick_bar, .button-collapse-header, #header_bar').on("mouseout", function() {
			if($("#quick_bar").attr("data-hide-quickbar-active")) {
		        if(timer) {
		            clearTimeout(timer);
		            timer = null
		        }
                timer = setTimeout( function() {
				    if (!TW.views.shared.quick_bar.checkHover()) {
				    	$("#quick_bar").removeAttr("data-hide-quickbar");
						TW.views.shared.quick_bar.hideQuickBar();
				    }	
				}, 200);	
			}	    		
		});	
	},

	hideShowBars: function(time) {
		if(!$("#quick_bar").attr("data-hide-quickbar-active")) {
			$("#quick_bar").attr("data-hide-quickbar-active", "true");
		}
		else {
			$("#quick_bar").removeAttr("data-hide-quickbar-active");
		}
		TW.views.shared.quick_bar.hideQuickBar(time);
	},

	checkHover: function() {
		if($('#quick_bar').is(':hover') || $('.button-collapse-header').is(':hover') || $('#header_bar').is(':hover')) {
			return true;
		}
		return false;
	},

	hideQuickBar: function(time) {	
		$('.button-collapse-header').slideToggle(time);		
		$('#quick_bar').slideToggle(time);
		$('#header_bar').slideToggle(time);
		$('.task_bar').slideToggle(time);
	}
	
});

$(document).ready( function() {
	var init_quickBar = TW.views.shared.quick_bar;
	init_quickBar.init_quickBar();
});

