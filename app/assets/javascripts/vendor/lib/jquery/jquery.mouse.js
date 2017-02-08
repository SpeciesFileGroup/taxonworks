(function($) {
    $.fn.getCursorPosition = function() {
        var input = this.get(0);
        if (!input) return;
        if ('selectionStart' in input) {
            return input.selectionStart;
        } 
    }
})(jQuery);