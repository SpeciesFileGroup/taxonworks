/*

To active and use:

Add data-help attribute on the elements to make enable the text legend and bubbles on each element.
Example:

<div data-help="This is a test"></div>

*/

var	helpSystem;
var helpLoaded = false;
$(document).ready(function() {

  helpSystem = function () {
	 
	firstClick = true;

	$('body').append('<div class="help-legend"></div>');
	$('body').append('<div class="help-background-active"></div>');
	$('body').append('<div class="help-button"></div>');

	
	function addBubbleTips(className) {
		$(className).each(function(i) {
			$(this).addClass('help-tip');
			$(this).append('<div class="help-bubble-tip" data-bubble-id="'+ (i) +'">'+ (i+1) +'</div>');
		});
	}

	function activeDisableHelp() {
		if(firstClick) {
			addBubbleTips('[data-help]');
			firstClick = false;
		}
		if(!helpActive()) {
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
	}

	function helpActive() {
		if($('.help-background-active').css('display') === "none") {
			return false;
		}
		else {
			return true;
		}
	}

	function hideAllExcept(value) {
		$('.help-bubble-tip').each(function(i) {
			if($(this).attr('data-bubble-id') != value) {
				$(this).fadeOut(250);
			}
		})
	}

	function showAll(className) {
		$(className).fadeIn(250);
	}

  	Mousetrap.bind("alt+shift+/", function() { 
		activeDisableHelp(); 
	});

	$(document).on({
	    mouseenter: function (evt) {
	    	if(helpActive()) {
	    		$('.help-legend').empty();
	    		$('.help-legend').css("left", (evt.clientX+10) + "px");
	    		$('.help-legend').css("top", (evt.clientY+10) + "px");
		    	$('.help-legend').show(100);
		    	$('.help-legend').append('<span>' + $(this).parent().attr("data-help") + '</span>');
		    	hideAllExcept($(this).attr("data-bubble-id"));
		    }
	    },
	    mouseleave: function () {
	    	$('.help-legend').empty();
			$('.help-legend').hide(100);
			showAll('.help-bubble-tip');
	    }
	}, ".help-bubble-tip");

	if(!helpLoaded)
	$(document).on('click','.help-button', function() {
		activeDisableHelp();
	});	
	if(!helpLoaded)
	$(document).on('click','.help-background-active', function() {
		activeDisableHelp();
	});		
};

  if($("[data-help]").length) {
    helpSystem();
    helpLoaded = true;
  }
}

);

