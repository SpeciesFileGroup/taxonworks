var TW = TW || {};
TW.views = TW.views || {};
TW.views.shared = TW.views.shared || {};
TW.views.shared.index = TW.views.shared.index || {};


Object.assign(TW.views.shared.index, {

	init: function() {
		TW.workbench.keyboard.createShortcut("shift+alt+n","Create a new record", "Data index", function() {
			if($('[data-icon="new"]').length) {
				$(location).attr('href', $('[data-icon="new"]').parent().attr('href'));
			}
		});

		TW.workbench.keyboard.createShortcut("shift+alt+l","List records", "Data index", function() {
			if($('[data-icon="list"]').length) {
				$(location).attr('href', $('[data-icon="list"]').attr('href'));
			}
		});		

		TW.workbench.keyboard.createShortcut("shift+alt+d","Download records list", "Data index", function() {
			if($('[data-icon="download"]').length) {
				$(location).attr('href', $('[data-icon="download"]').attr('href'));
			}
		});	

		TW.workbench.keyboard.createShortcut("shift+alt+b","Batch load", "Data index", function() {
			if($('[data-icon="batch"]').length) {
				$(location).attr('href', $('[data-icon="batch"]').attr('href'));
			}
		});					
	}	
});

$(document).ready(function() {
	if($('#model_index').length) {
		var _init_index = TW.views.shared.index;
		_init_index.init();
	}
});