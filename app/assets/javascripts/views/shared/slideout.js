$(document).ready(function() {
	$('.slide-panel-circle-icon').on('click', function() {
		if($(this).parent().css('right') == '0px') {
			$(this).parent().animate({right: "-400px"}, 500);
		}
		else {
			$(this).parent().animate({right: "0px"}, 500);
		}
	});

	$('.slide-panel-category-header').on('click', function() {
		$(this).parent().find('.slide-panel-category-content').toggle(250);
	});	
});