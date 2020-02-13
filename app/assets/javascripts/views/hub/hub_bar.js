$(document).on('turbolinks:load', function() {
  if ($('#hub_tabs').length > 0) {
    $('#' + $('#hub_tabs').data('currentTab')).addClass('current_hub_category');

    TW.workbench.keyboard.createShortcut("shift+1", "Select first tab", "Hub", function () {
      document.querySelector('#hub_tabs li:nth-child(1) a').click();
    });
    TW.workbench.keyboard.createShortcut("shift+2", "Select second tab", "Hub", function () {
      document.querySelector('#hub_tabs li:nth-child(2) a').click();
    });
    TW.workbench.keyboard.createShortcut("shift+3", "Select third tab", "Hub", function () {
      document.querySelector('#hub_tabs li:nth-child(3) a').click();
    });
	}
});
