$(document).ready(function() {
  if($("#browse-view").length) {
    browseView();
  }
});
function browseView() {

	$('.filter .open').on('click', function() {
		$(this).addClass('active');
	});
	
	$('#filterBrowse_button').on('click', function() {
		$('[data-filter-slide]').slideToggle(250);
	});

	$('#filterBrowse').on('click', '.navigation-item', function(selector) {
		if($(this).hasClass('active')) {
			$(this).removeClass('active');
		}
		else {
			$(this).addClass('active');
		}
		if($(this).attr('data-filter') === 'reset') {
			$('[data-filter]').each( function() {
				$($(this).attr('data-filter')).animate({
            	fontSize: '100%'
        		});
				$($(this).children()).attr('data-icon', 'show');
			});
		}
		else {
			if($(this).children().attr('data-icon') == "show") {
				$($(this).children()).attr('data-icon', 'hide');
				$($(this).attr('data-filter')).animate({
            	fontSize: '0px'
        		});
			}
			else {
				$($(this).children()).attr('data-icon', 'show');
				$($(this).attr('data-filter')).animate({
            	fontSize: '100%'
        		});			
			}
		}
	});
}