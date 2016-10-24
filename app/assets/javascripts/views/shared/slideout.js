$(document).ready(function() {
	$('.slide-panel-circle-icon').on('click', function() {
		if($(this).parent().css('right') == '0px') {
			$(this).parent().animate({right: "-400px"}, 500);
			$(this).parent().css('z-index',"1000");
		}
		else {
			$(this).parent().animate({right: "0px"}, 500);
			$(this).parent().css('z-index',"1100");
		}
	});

	$('.slide-panel-category-header').on('click', function() {
		$(this).parent().find('.slide-panel-category-content').toggle(250);
	});	
});