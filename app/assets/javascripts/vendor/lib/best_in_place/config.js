$(document).on('turbolinks:load', function() {
  /* Activating Best In Place */
  jQuery(".best_in_place").best_in_place();
  $('.best_in_place').bind("ajax:success", function () {$(this).closest('div').effect('highlight'); });
});
