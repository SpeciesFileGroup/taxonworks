$(document).ready(function() {
  if($("#browse-view").length) {
    browseView();
  }
});
function browseView() {
	var timeEffect = 150;

	$('#filterBrowse').on('click', '.navigation-item', function(selector) {
		if($(this).attr('data-filter-reset') === 'reset') {
			$('[data-filter]').each( function() {
				$($(this).attr('data-filter')).show(timeEffect);
				$($(this).children()).attr('data-icon', 'show');
			});
		}
		else {
			if($(this).children().attr('data-icon') == "show") {
				$($(this).children()).attr('data-icon', 'hide');
				$($(this).attr('data-filter')).css('font-size','0px');
			}
			else {
				$($(this).children()).attr('data-icon', 'show');
				$($(this).attr('data-filter')).css('font-size','100%');;			
			}
		}
	});


}