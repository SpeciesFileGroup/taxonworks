var _init_loan_completion_widget;
_init_loan_completion_widget = function init_loan_completion() {
  widget = $('#loan_completion_widget');
  if (widget.length) {
    widget.removeAttr('hidden');  // unhide the loan completion widget div
    var bio_object = $('#bio_object');
    if (bio_object.length) {
      bio_object.attr("hidden", true);
    }
  }
};

$(document).ready(_init_loan_completion_widget);
$(document).on("page:load", _init_loan_completion_widget);
