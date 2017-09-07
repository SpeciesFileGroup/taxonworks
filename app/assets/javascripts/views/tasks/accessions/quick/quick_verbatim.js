$(document).on("turbolinks:load", function() {
  if($("#quick_task").length) {
  	$('.biocuration_group_totals').each(function(element) {
		$(this).find('.add_total_row').detach().appendTo($(this).find('.one_third_width'));
  	});
  }
});