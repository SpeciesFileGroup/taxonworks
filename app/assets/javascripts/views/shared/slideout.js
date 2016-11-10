$(document).ready(function() {
	$('.slide-panel-circle-icon').on('click', function() {		
		closeHideSlideoutPanel($(this).parent());
	});

	$('.slide-panel-category-header').on('click', function() {
		$(this).parent().find('.slide-panel-category-content').toggle(250);
	});	


	function closeHideSlideoutPanel(panel) {
		$(panel).css("left", "");		
		if($(panel).css('right') == '0px') {
			$(panel).animate({right: "-" + $(panel).css("width")}, 500);
			$(panel).css('z-index',"1000");
		}
		else {
			$(panel).animate({right: "0px"}, 500);
			$(panel).css('z-index',"1100");
		}		
	}
	$('[data-pdfviewer]').on("click", function() {
      	closeHideSlideoutPanel($('[data-panel-name="pinboard"]'));
      	closeHideSlideoutPanel($('[data-panel-name="pdfviewer"]'));
  	});
});