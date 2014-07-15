/*
 * This attaches to an input element.
 *
 * Waiting for changes (keydown / change / etc) and then we'll fire off a request to the server
 * waiting for it to come back.
 *
 * When it does return, if there is any data (and the response was success) - we'll update
 * the target selector with the response data.
 *
 * The server just sends back some HTML, and the plugin will just update the element pointed at
 * by the data-autoquery-target
 *

  attributes:
    data-autoquery => the URL to hit with a 'term' value which is retrieved from the input
    data-autoquery-target => CSS selector to identify which element's HTML to update with the response data

  Example code:
    <input data-autoquery='/account/login?type=foo_type_passed_into_server' data-autoquery-target='#autoquery_target' type='text'></input>
    <div id='autoquery_target'> </div>

 */
(function ($) {
  $.fn.mx_autoquery = function(type, options) {
    if (!this.length) {   return this; }
    return this.each(function() {
      var $this = $(this);

      var target = $($this.data('autoqueryTarget'));
      var uri = parseUri($this.data('autoquery'));
      var url    = uri.path;
      var params = uri.queryKey;
      var query_count = 0;

      // We max out at one call every 250 milliseconds
      $this.bind('keydown', $.debounce( 250, function(e) {
        var data = uri.queryKey;
        data.term = $this.val();

        // store the query count here -- so we can keep track of the queries we've made.
        query_count += 1;
        var this_query = query_count;

        // Add the spinner
        $this.addClass('autoquery-loading');

        $.get(url, data,
          function(data, textStatus, jqXHR){

            // Only update if this is the latest query.
            // If there were backed up queries, and one is coming after this one,
            // just hold off, don't update (because that one may have already
            // updated the div -- we don't want to stomp on it)
            if (this_query === query_count) {
              // Only remove the spinner if we're updating the target
              $this.removeClass('autoquery-loading');
              target.html(data);
            }
          });
      }));
    });
  };
})(jQuery);
