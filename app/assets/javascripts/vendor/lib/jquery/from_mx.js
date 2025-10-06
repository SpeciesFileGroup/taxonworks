function initialize_js(root) {
  var $root = $(root)
  var find = function (expr) {
    return $($root).is(expr) ? $(expr, $root).add($root) : $(expr, $root)
  }

  //find('*[data-mx-autocomplete-url]').mx_autocompleter();
  find('*[data-observe-field]').mx_field_observer()
  find('*[data-autoquery]').mx_autoquery()
  find('*[data-sortable]').mx_sortable()
  find('*[data-insert-content]').mx_insert_content()
  /*

  find("*[data-sortable-table]").mx_sortable_table();
   find("input[data-color-picker]").mx_color_picker();
   find("a[data-ajaxify], input[data-ajaxify]").ajaxify();
   find("*[data-tooltip]").mx_tooltip();
   find("*[data-observe-select]").mx_select_observer();
   find("*[data-basic-modal]").basicModal();
   find("*[data-inplace-editor]").mx_inplace_editor();
   find("*[data-sticky-header]").mx_sticky_header();
   find("*[data-save-warning]").mx_save_warning();
   find("*[data-figure-marker]").mx_figure_marker();
*/
}

$(document).on('turbolinks:load', function () {
  initialize_js($('body'))
  $('body').mx_flash()

  // Attach to the mx_spinner -- any link-to-remotes will trigger this spinner effect.
  $(document).on(
    'ajax:before',
    'form[data-remote],a[data-remote],input[data-remote]',
    function () {
      $('body').mx_spinner('show')
    }
  )
  $(document).on(
    'ajax:complete',
    'form[data-remote],a[data-remote],input[data-remote]',
    function () {
      $('body').mx_spinner('hide')
    }
  )
})
