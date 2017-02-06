/*

To active and use:

Add data-help attribute on the elements to make enable the text legend and bubbles on each element.
Example:

<div data-help="This is a test"></div>

*/

var TW = TW || {};
TW.workbench = TW.workbench || {};
TW.workbench.help = TW.workbench.help || {};

Object.assign(TW.workbench.help, {
	
  	init_helpSystem: function () {
		firstClick = true;
		helpLoaded = false,

		$('body').append('<div class="help-legend"></div>');
		$('body').append('<div class="help-background-active"></div>');
		$('body').append('<div class="help-button"><div class="help-button-description">Help</div></div>');	

		$(document).on({
		    mouseenter: function (evt) {
		    	if(TW.workbench.help.helpActive()) {
		    		var
		    			position = this.getBoundingClientRect();

		    		$('.help-legend').empty();
		    		$('.help-legend').css("left", (position.left) + "px");
		    		$('.help-legend').css("top", (position.top+$(this).height()+14) + "px");
			    	$('.help-legend').show(100);
			    	$('.help-legend').append('<span>' + $(this).parent().attr("data-help") + '</span>');
			    	TW.workbench.help.hideAllExcept($(this).attr("data-bubble-id"));
			    }
		    },
		    mouseleave: function () {
		    	$('.help-legend').empty();
				$('.help-legend').hide(100);
				TW.workbench.help.showAll('.help-bubble-tip');
		    }
		}, ".help-bubble-tip");

		Mousetrap.bind("alt+shift+/", function() { 
			TW.workbench.help.activeDisableHelp(); 
		});	


		$(".help-button").on('click', function() {
			TW.workbench.help.activeDisableHelp();
		});	

		$(".help-background-active").on('click', function() {
			TW.workbench.help.activeDisableHelp();
		});	
	},
	
	addBubbleTips: function(className) {
		$(className).each(function(i) {
			$(this).addClass('help-tip');
			$(this).append('<div class="help-bubble-tip" data-bubble-id="'+ (i) +'">'+ (i+1) +'</div>');
		});
	},

	activeDisableHelp: function() {	
	
		if(firstClick) {
			TW.workbench.help.addBubbleTips('[data-help]');
			firstClick = false;
		}
		if(!TW.workbench.help.helpActive()) {
			$('.help-background-active').fadeIn(100);
			$('.help-bubble-tip').show(100);
			$('.help-button').addClass('help-button-active');
			$('.help-legend').empty();
		}
		else {
			$('.help-background-active').fadeOut(100);
			$('.help-bubble-tip').fadeOut(100);	
			$('.help-button').removeClass('help-button-active');
			$('.help-legend').hide(250);							
		}
	},

	helpActive: function() {
		if($('.help-background-active').css('display') === "none") {
			return false;
		}
		else {
			return true;
		}
	},

	hideAllExcept: function(value) {
		$('.help-bubble-tip').each(function(i) {
			if($(this).attr('data-bubble-id') != value) {
				$(this).fadeOut(250);
			}
		})
	},

	showAll: function(className) {
		$(className).fadeIn(250);
	},

});

$(document).ready( function() {
	if($("[data-help]").length) {
	    TW.workbench.help.init_helpSystem();
	}	
});
