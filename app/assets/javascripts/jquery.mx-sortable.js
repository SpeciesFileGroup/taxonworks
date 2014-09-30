/*
 * Wraps the sortable in some helpers so we can specify things in the DOM.
 * sortable-items -> describes a selector for what is being sorted
 * sortable-handle -> selector for the sortable handle
 * sortable-on-change-url > URL to serialize and POST the resorted things to (when you drag n drop)
 * Saves a sortable set whenever you change it - and POSTs the serialized information to the URL.
 *
 * Will flip to opacity 50% while saving... to give some visual indicator that it's doing something.
 */

(function ($) {
  $.fn.mx_sortable = function() {
    if (!this.length) {   return this; }
    return this.each(function() {
      var $this = $(this);
      var items = $this.data('sortableItems') || "li";
      var handle = $this.data('sortableHandle') || ".handle";
      $this.sortable({items:items, handle: handle}).bind( "sortupdate", function(event, ui) {
        var url = $this.data('sortableOnChangeUrl');
        if (url) {
        //  $this.mx_spinner('show');
          var serialized_data = $this.sortable("serialize");
          if (serialized_data) {
            $.ajax({
              type: 'POST',
              url: url,
              data: serialized_data,
              complete: function() {
               // $this.mx_spinner('hide');
              }
            });
          }
        }
      });
    });
  };
})(jQuery);
