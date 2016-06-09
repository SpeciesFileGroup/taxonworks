/*
 *  mx-field-observer will observe fields for change,
 *  and fire off an ajaxify request, while also spinning the element (or it's target area)
 */
(function ($) {
  $.fn.mx_field_observer = function() {

    if (!this.length) {   return this; }

    return this.each(function() {
      var $source = $(this);
      var frequency= $source.data('observeFieldFrequency') || 0.5;
      var url      = $source.data('observeFieldAction');
      var spinner_target = $($source.data('observeFieldSpinnerTarget') || $source);
      var method = $source.data('observeMethod') || 'POST' ;

      $source.data('observeFieldActive', true);

      $source.change(function(evt) {
        if ($source.data('observeFieldActive')) {

          // Deactivate for the frequency, set timeout to reactivate
          $source.data('observeFieldActive', null);
          setTimeout(function() { $source.data('observeFieldActive', true); }, frequency * 1000);

          // Get the URL -- serialize the element.
          var data = {};
          data[$source.attr('name')] = $source.val();

          // Spinner-ify the target
          spinner_target.mx_spinner();

          // Do the AJAX call to the server
          $.ajax({
            type: method,
            url: url,
            data: data,
            dataType: 'script',
            complete: function() {
            spinner_target.mx_spinner('hide');
            }
          });
        }
      });
    });
  };
})(jQuery);
