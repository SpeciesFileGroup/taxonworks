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

      $this.autocomplete({
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
          var response_values = selected.response_values;

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
        });

      /* Update the response method to add a --NONE-- label when the response is present
       * but empty
       */
      $this.data( "autocomplete" )._response = function(a){
        if(!this.options.disabled && a) {
          a=this._normalize(a);
          if (a.length === 0) {
            a.push({id: '', value: '', label: '-- None --'});
          }
          this._suggest(a);
          this._trigger("open");
        } else  {
          this.close();
        }
        this.pending -= 1;
        if (this.pending === 0) {
          this.element.removeClass("ui-autocomplete-loading");
        }
      };

      /* The autocompletion select box needs (at times) HTML code.
       * to have a bit of HTML in the autocomplete dropdown, just add the label_html
       * as an attribute.
       */
      $this.data( "autocomplete" )._renderItem = function( ul, item ) {
        return $( "<li></li>" )
          .data( "item.autocomplete", item )
          .append(
            $("<a>")
            .append(item.label_html || item.label ) // Just add the HTML from the label in directly
          )
          .appendTo( ul );
      };
    });
  };
})(jQuery);
