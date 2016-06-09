// This will handle ??
(function($) {
  $.mx_flash = function(type, message) {
    $.n(message, {'type':type, 'stick':false});
  };

  $.fn.mx_flash = function() {
    return this.each(function() {
      var flash_target = $(this);
      flash_target.ajaxComplete(function(data, xhr, settings) {
        if (! xhr || typeof xhr === 'undefined') {
          return this;
        }

        var content = [];
        var flash = $.parseJSON(xhr.getResponseHeader('X-JSON'));

        if (flash) {
          $.each(flash, function(k, v) {
            $.each(v,function(index,msg) {
              $.mx_flash(k, msg);
            });
          });
        }
      });
    });
  };
})(jQuery);
