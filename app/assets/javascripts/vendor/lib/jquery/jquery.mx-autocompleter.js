/*
 * This attaches to an input element using the jquery autocompleter.
 * It reads off the data-mx-autocomplete-url variable, so set that:
 *
 * <input type="text" data-mx-autocomplete-url="/url/to/autocomplete">
 *
 *
 * When you pass in the JSON to the autocompleter, you need these values:
 * [
 *  {
 *    id:
 *    value:
 *    label: what is displayed in the drop down && in the text area when selected
 *    label_html: (opt) - the fancy HTML to use in the autocompleter
 *    response_values: (opt) - any key/val pairs to add to the response when selected
 *  }
 * ...
 * ]
 */

(function ($) {
  $.fn.mx_autocompleter = function(options) {
    if (!this.length) {   return this; }
    return this.each(function() {
      var $this = $(this);
      var $form = $this.parents("form");

      var url = $this.data('mxAutocompleteUrl');
      var default_response_values = {}; default_response_values[$this.data('mx-method')] = '';

      $this.autocomplete({
        close: function( event, ui ) { $(this).removeClass('ui-autocomplete-loading'); },
        source: url,
        minLength: 1,
        appendTo: $this.parent()
      })
        .bind( "autocompletefocus", function( event, ui ) {
          var selected = ui.item;
        })
        /* When you select an item you need add all the values which we are told to
         * -- add those values in the 'response_values' to the current form.
         *  This lets you add things like
         *  otu[id] as a response value.
         * !! If you want a controller[:method] combination in the response do
         *   params[:method] => obj.id in the autocomplete response. Set this in the autocomplete method of the respective controller, see ref_controller.rb for example.  
         * When the shared/picker partial is used params[:method] is set to "#{object}[#{method}]".
         * There is no name parameter in the visible picker, the name is set in the hidden field set here.
         */
        .bind( "autocompleteselect", function( event, ui ) {
          var selected = ui.item;
          var response_values = selected.response_values; // Not being set for -- None -- option

          if (response_values) {
            $.each(response_values, function(key, value) {
              var input = $form.find("input[name='"+key+"']").remove();
              $('<input>').attr({
                  type: 'hidden',
                  name: key,
                  value: value
              }).appendTo($form);
            });
          }
          if($this.data('send-select')) {
            $(event.target.form).submit();
          }
        });

      /* Update the response method to add a --NONE-- label when the response is present
       * but empty
       */
      $this.data( "uiAutocomplete" ).__response = function(a){
        this.element.removeClass("ui-autocomplete-loading");
        if(!this.options.disabled && a) {
          a=this._normalize(a);
          if (a.length === 0) {
            a.push({id: '', value: '', label: '-- None --', label_html: '-- None --',
            	response_values: default_response_values});
          }
          this._suggest(a);
          this._trigger("open");
        } else  {
          this.close();
        }
        this.pending -= 1;
      };

      /* The autocompletion select box needs (at times) HTML code.
       * to have a bit of HTML in the autocomplete dropdown, just add the label_html
       * as an attribute.
       */
      $this.data( "uiAutocomplete" )._renderItem = function( ul, item ) {
        return $( "<li></li>" )
          .data( "item.autocomplete", item )
          .append(
            $("<a data-model-id='" + item.id + "'>")
            .append(item.label_html || item.label ) // Just add the HTML from the label in directly
          )
          .appendTo( ul );
      };
    });
  };
})(jQuery);

