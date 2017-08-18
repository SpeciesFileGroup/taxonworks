$(document).on('turbolinks:load', function() {
  if ($('#hub_tabs').length > 0) {
   $('#' + $('#hub_tabs').data('currentTab')).addClass('current_hub_category');
	}
});
