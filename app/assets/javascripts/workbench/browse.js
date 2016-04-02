$(document).ready(function() {
  if($("#browse-view").length) {
    browseView();
  }
});
function browseView() {
	var timeEffect = 150;

	$('#filterBrowse').on('click', '.navigation-item', function(selector) {
		if($(this).attr('data-filter') === 'reset') {
			$('[data-filter]').each( function() {
				$($(this).attr('data-filter')).show(timeEffect);
			});
		}
		else {
			$($(this).attr('data-filter')).hide(timeEffect);
		}
	});
}