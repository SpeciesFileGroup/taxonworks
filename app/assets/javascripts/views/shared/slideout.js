var TW = TW || {};
TW.views = TW.views || {};
TW.views.shared = TW.views.shared || {};
TW.views.shared.slideout = TW.views.shared.slideout || {};

Object.assign(TW.views.shared.slideout, {
	init: function() {

		$('.slide-panel-circle-icon').on('click', function() {		
			closeHideSlideoutPanel($(this).closest('.slide-panel'));
		});

		$('.slide-panel-category-header').on('click', function() {
			$(this).parent().find('.slide-panel-category-content').toggle(250);
		});	

		$('.slide-panel').each(function(i) {
			$(this).find('.slide-panel-description').text($(this).children('.slide-panel-header').text());
		});


		function closeHideSlideoutPanel(panel) {
			if($(panel).hasClass("slide-left")){
				$(panel).css("right", "");		
				if($(panel).css('left') == '0px') {
					$(panel).attr('data-panel-open','false');
					$(panel).animate({left: "-" + $(panel).css("width")}, 500);
					$(panel).css('z-index',"1000");
				}
				else {
					$(panel).attr('data-panel-open','true');
					$(panel).animate({left: "0px"}, 500);
					$(panel).css('z-index',"1100");
				}
			}
			else {
				$(panel).css("left", "");		
				if($(panel).css('right') == '0px') {
					$(panel).attr('data-panel-open','false');
					$(panel).animate({right: "-" + $(panel).css("width")}, 500);
					$(panel).css('z-index',"1000");
				}
				else {
					$(panel).attr('data-panel-open','true');
					$(panel).animate({right: "0px"}, 500);
					$(panel).css('z-index',"1100");
				}
			}		
		}
		$('[data-pdfviewer]').on("click", function() {
	      	closeHideSlideoutPanel($('[data-panel-name="pinboard"]'));
	      	closeHideSlideoutPanel($('[data-panel-name="pdfviewer"]'));
	  	});
	}
});

$(document).ready(function() {
	var slideout = TW.views.shared.slideout;
	slideout.init();
});