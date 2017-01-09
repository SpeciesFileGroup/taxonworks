/*
 *  Mx_Spinner will spin against an element it is called on.
 *
 *  Or against an element -- if defined on that element.
 */
(function ($) {
  $.fn.mx_spinner = function(action) {
      if (!this.length) {   return this; }
      return this.each(function() {
        var target = $(this);
        var overlay =  target.data('mx_spinner');


        target.data('mx_spinner', null);
        if (action == 'hide') {
          if (overlay) {
            overlay.fadeOut(300, function() { overlay.remove(); });
          }
        } else  {
          if (overlay) {
            overlay.remove();
          }
          var offset = target.offset();
          overlay = $("<div class='middle box-spinner'><div class='spinner'></div></div>")
                        .outerWidth(target.outerWidth())
                        .outerHeight(target.outerHeight())
                        .css('left', offset.left)
                        .css('top', offset.top)
                        .css('margin', target.css('margin'))
                        .addClass('mx-spinner')
                        .hide();
          target.data('mx_spinner', overlay);
          $('body').append(overlay);
          overlay.fadeIn(300);
        }
    });
  };
})(jQuery);
