$(document).ready(function() {
  if($("#browse-view").length) {
    browseView();
  }
});
function browseView() {

	$('.filter .open').on('click', function() {
		activeColor($(this))
	});

	function activeColor(tag) {

		if($(tag).hasClass('active')) {
			$(tag).removeClass('active');
		}
		else {
			$(tag).addClass('active');
		}
	}
	
	$('#filterBrowse_button').on('click', function() {
		$('[data-filter-slide]').slideToggle(250);
	});

	$('#filterBrowse').on('click', '.navigation-item', function(selector) {

		activeColor($(this));
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