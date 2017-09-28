var TW = TW || {};
TW.workbench = TW.workbench || {};
TW.workbench.pinboard = TW.workbench.pinboard || {};

Object.assign(TW.workbench.pinboard, {
	
  	init: function () {
  		$('[data-panel-name="pinboard"] [data-insert]').each(function() {
  			if($(this).attr('data-insert') == "true") {
  				$(this).addClass('pinboard-default-item');
  			}
  			else {
  				$(this).removeClass('pinboard-default-item');
  			}
  		})
	},

});

$(document).on('turbolinks:load', function() {
	if($('[data-panel-name="pinboard"]').length) {
	    TW.workbench.pinboard.init();
	}	
});