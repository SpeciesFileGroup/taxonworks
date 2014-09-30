function initialize_js(root) {
  var $root = $(root);
  var find = function(expr){
    return $($root).is(expr) ? $(expr, $root).add($root) : $(expr, $root);
  };

  find('*[data-mx-autocomplete-url]').mx_autocompleter();
  find("*[data-observe-field]").mx_field_observer();
  find("*[data-autoquery]").mx_autoquery();
  find("*[data-sortable]").mx_sortable();
/*

  find("*[data-sortable-table]").mx_sortable_table();
   find("input[data-color-picker]").mx_color_picker();
   find("a[data-ajaxify], input[data-ajaxify]").ajaxify();
   find("*[data-insert-content]").mx_insert_content();
   find("*[data-tooltip]").mx_tooltip();
   find("*[data-observe-select]").mx_select_observer();
   find("*[data-basic-modal]").basicModal();
   find("*[data-inplace-editor]").mx_inplace_editor();
   find("*[data-sticky-header]").mx_sticky_header();
   find("*[data-save-warning]").mx_save_warning();
   find("*[data-figure-marker]").mx_figure_marker();
*/

}


$(document).ready(function() {
  initialize_js($("body"));
  $('body').mx_flash();

  // Attach to the mx_spinner -- any link-to-remotes will trigger this spinner effect.
  $("form[data-remote],a[data-remote],input[data-remote]")
    .bind('ajax:before', function() {
      $('body').mx_spinner('show');
    })
    .bind('ajax:complete', function() {
      $('body').mx_spinner('hide');
    });
});
