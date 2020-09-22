/*
Keyboard shortcuts


Use TW.workbench.keyboard.createShortcut(key, description, section, func) to create a shortcut.

Create: 
createShortcut("left", "Move to left", "Lists", function() { do something });

Result: 
<span data-shortcut-key="left" data-shortcut-description="Move to left" data-shortcut-section="Lists"></div>

*/

var TW = TW || {};
TW.workbench = TW.workbench || {};
TW.workbench.keyboard = TW.workbench.keyboard || {};

Object.assign(TW.workbench.keyboard, {

	init_keyShortcuts: function() {

		var 

		keyCode = [ "UP", "DOWN", "LEFT", "RIGHT", "COMMAND" ],
		keyCodeReplace = [ "↑", "↓", "←", "→", "⌘" ],

		generalShortcuts = '<thead> \
								<th></th> \
								<th> \
									General shortcuts \
								</th> \
							</thead> \
							<tbody data-shortcut-section="General shortcuts"> \
								<tr> \
									<td><div class="key">'+ (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt') +'+h</div></td> \
									<td>Go to hub</td> \
								</tr> \
								<tr> \
									<td><div class="key">alt+shft+?</div></td> \
									<td>Show/hide help</td> \
								</tr> \
							<tbody>';	


		$('body').append('<div id="keyShortcuts"> \
							<a class="legend">Keyboard shortcuts available</a> \
							<div class="keyboard-background-active"></div> \
								<div class="panel"> \
									<div class="header"> \
										<span class="title">Keyboard shortcuts</span> \
										<div data-icon="close" class="close small-icon"></div> \
									</div> \
									<div class="list"> \
										<div class="item default-shortcuts"> \
											<table> \
											' + generalShortcuts + '\
											</table> \
										</div> \
										<div class="item page-shortcuts"> \
											<table> \
											</table> \
										</div> \
									</div> \
								</div> \
							</div> \
						</div> \
						');

		this.createTable();
		this.handleEvents();
	},


	createShortcut: function(key, description, section, func) {
		function customFunction(event) {
			event.preventDefault();
			func(event);
		}
  		Mousetrap.bind(key, customFunction);
		$('body').append('<span style="display;hidden" data-shortcut-key="'+ key +'" data-shortcut-description="'+ description +'" data-shortcut-section="'+ section +'"></span>');
	},

	createLegend: function(key, description, section) {
		$('body').append('<span style="display;hidden" data-shortcut-key="'+ key +'" data-shortcut-description="'+ description +'" data-shortcut-section="'+ section +'"></span>');
		this.addNewShortcut('[data-shortcut-key="'+ key +'"]')
	},
		

	createTable: function() {
		$('[data-shortcut-key]').each(function() {
			TW.workbench.keyboard.addNewShortcut(TW.workbench.keyboard.checkReplaceKeyCode(this));
		});
	},

	checkReplaceKeyCode: function(keyShortcut) {
		var
			find = $.inArray($(keyShortcut).attr('data-shortcut-key').toUpperCase(),TW.workbench.keyboard.keyCode);
		
		if(find > -1) {
			$(keyShortcut).attr('data-shortcut-key',TW.workbench.keyboard.keyCodeReplace[find]);
		}
		return keyShortcut;
	},

	addNewShortcut: function(shortcut) {

		var
			section = $(shortcut).attr('data-shortcut-section');

		if($('#keyShortcuts .list table tbody[data-shortcut-section="'+section+'"]').length == 0) {
			$('#keyShortcuts .list .page-shortcuts table').append('<thead><th></th><th>'+ section +'</th></thead><tbody data-shortcut-section="'+ section +'"></tbody>');
		}
		$('#keyShortcuts .list table tbody[data-shortcut-section="'+section+'"]').append('<tr><td><div class="key">'+ $(shortcut).attr('data-shortcut-key') +' </div></td><td>'+ $(shortcut).attr('data-shortcut-description')+'</td></tr>');
	},		

	hideShortcuts: function() {
		$('#keyShortcuts .keyboard-background-active').fadeOut();
		$('#keyShortcuts .panel').fadeOut();
	},

	handleEvents: function() {
		$('#keyShortcuts').on("click", ".legend", function() {
			$('#keyShortcuts .keyboard-background-active').fadeIn();
			$('#keyShortcuts .panel').fadeIn();
		});

		$('#keyShortcuts').on("click", ".keyboard-background-active", function() {
			TW.workbench.keyboard.hideShortcuts();
		});		

		$('#keyShortcuts').on("click", ".close", function() {
			TW.workbench.keyboard.hideShortcuts();
		});	
	}	
});

$(document).on('turbolinks:load', function() {
	if($("[data-shortcut-key]").length) {
	  	if (!$("[data-help]").length) {
		    TW.workbench.help.init_helpSystem();
	  	}
	    TW.workbench.keyboard.init_keyShortcuts();	
	}
});