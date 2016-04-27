$(document).ready(function() {
  if($(".help-button").length) {
    helpSystem();
  }
});

function helpSystem() {
	var 
		firstClick = true;
		$('body').append('<div class="panel content help-legend"></div>');
	$('body').append('<div class="help-background-active"></div>');

	
	function addBubbleTips(className) {
		$(className).each(function(i) {
			$(this).append('<div class="help-bubble-tip">'+ (i+1) +'</div>');
			$('.help-legend').append('<span>' + $(this).attr("data-help") + '</span>');
		});
	}

	function activeDisableHelp() {
		if(firstClick) {
			addBubbleTips('.help-tip');
			firstClick = false;
		}
		if(!helpActive()) {
			$('.help-background-active').fadeIn(100);
			$('.help-bubble-tip').show(100);
			$('.help-button').css("bottom", "0px");
			$('.help-button').css("left", "0px");			
		}
		else {
			$('.help-background-active').fadeOut(100);
			$('.help-bubble-tip').fadeOut(100);	
			$('.help-button').css("bottom", "-15px");
			$('.help-button').css("left", "-15px");					
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
		    	$('.help-legend').show(250);
		    	$('.help-legend').append('<span>' + $(this).attr("data-help") + '</span>');
		    }
	    },
	    mouseleave: function () {
	    	$('.help-legend').empty();
			$('.help-legend').hide(250);
	    }
	}, ".help-tip");


	$(document).on('click','.help-button', function() {
		//alert();
		activeDisableHelp();
	});	

	$(document).on('click','.help-background-active', function() {
		activeDisableHelp();
	});		
}

