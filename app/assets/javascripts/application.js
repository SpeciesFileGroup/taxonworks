// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//

//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require turbolinks
//= require jquery.turbolinks
//= require_tree .

//function remove_fields(rf_link) {
//    $(rf_link).prev('.destroy_field').attr('value', '1');
//    $(rf_link).closest('.fields').hide();
//}
//
//function destroy_fields(rf_link) {
//    $(rf_link).prev('.destroy_field').attr('value', '1');
//    $(rf_link).closest('.fields').hide();
//}
//
//function add_fields(af_link, association, content) {
//    var new_id = new Date().getTime();
//    var regexp = new RegExp("new_" + association, "g");
//    $(af_link).prev().insertBefore(content.replace(regexp, new_id));
//}
//
//function a_fields(af_link) {
////    af_link.attributes.content.value or $(af_link).attr('content')
//    var content = $(af_link).attr('content');
//    var association = $(af_link).attr('association');
//    var new_id = new Date().getTime();
//    var regex = new RegExp("new_" + association, "g");
//    content = content.replace(regex, new_id);
//    $(content).insertBefore($(af_link));
//}
//
