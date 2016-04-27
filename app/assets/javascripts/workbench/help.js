/*

To active and use:

Add data-help attribute on the elements to make enable the text legend and bubbles on each element.
Example:

<div data-help="This is a test"></div>

*/


$(document).ready(function() {
  if($("[data-help]").length) {
    helpSystem();
  }
});

function helpSystem() {
	var 
		firstClick = true;

	$('body').append('<div class="panel content help-legend"></div>');
	$('body').append('<div class="help-background-active"></div>');
	$('body').append('<div class="help-button"></div>');

	
	function addBubbleTips(className) {
		$(className).each(function(i) {
			$(this).addClass('help-tip');
			$(this).append('<div class="help-bubble-tip">'+ (i+1) +'</div>');
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
			$('.help-legend').append('<span>Pass mouse over the numbers for help</span>');
			$('.help-legend').show(250);
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

	$(document).on({
	    mouseenter: function () {
	    	if(helpActive()) {
	    		$('.help-legend').empty();
		    	$('.help-legend').show(250);
		    	$('.help-legend').append('<span>' + $(this).parent().attr("data-help") + '</span>');
		    }
	    },
	    mouseleave: function () {
	    	$('.help-legend').empty();
			$('.help-legend').hide(250);
	    }
	}, ".help-bubble-tip");


	$(document).on('click','.help-button', function() {
		activeDisableHelp();
	});	

	$(document).on('click','.help-background-active', function() {
		activeDisableHelp();
	});		
}

