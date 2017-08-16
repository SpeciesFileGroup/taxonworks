// quick_verbatim_material_task.js

function update_attribute_names(link) {
  var new_id = new Date().getTime();
  var regex = new RegExp("_update_", "g");
  $('input[name*="_update_"]').each(function(i) {
    var a = $(this).attr('name').replace(regex, new_id);
    var b = $(this).attr('id').replace(regex, new_id);
    $(this).attr('name', a);  
    $(this).attr('id', b);
  });
}

function bind_remove_row_link(link) {
  $('a[class*="_update_"]').each(function(i) {
   $(this).on("click",function (event) {
    $(this).parents('.biocuration_totals_row').hide();
    event.preventDefault(); 
  });
   $(this).attr('class', 'remove_row');
 });     
}

$(document).on("tubolinks:load", function() {
  $(".add_total_row").on("click", function(event) {
    update_attribute_names(this);
    bind_remove_row_link(this);
  });
});