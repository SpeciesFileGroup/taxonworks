/*
Keyboard shortcuts

Example:

<span data-shortcut-key="e" data-shortcut-description="Example key" data-shortcut-section="Shortcuts for examples"></div>

Or using function createShortcut() to register on Mousetrap too.

Example: 
createShortcut("left", "Move to left", "Lists", function() { do something });

*/


function createShortcut(key, description, section, funcion) {
  Mousetrap.bind(key, funcion);
	$('body').append('<span style="display;hidden" data-shortcut-key="'+ key +'" data-shortcut-description="'+ description +'" data-shortcut-section="'+ section +'"></span>');
}

$(document).ready(function() {

	keyShortcuts = function() {

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
									<td><div class="key">alt+ctrl+h</div></td> \
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

		createTable();

		function createTable() {
			$('[data-shortcut-key]').each(function() {
				addNewShortcut(checkReplaceKeyCode(this));
			});
		}

		function checkReplaceKeyCode(keyShortcut) {
			var
			find = $.inArray($(keyShortcut).attr('data-shortcut-key').toUpperCase(),keyCode);
			if(find > -1) {
				$(keyShortcut).attr('data-shortcut-key',keyCodeReplace[find]);
			}
			return keyShortcut;
		}

		function addNewShortcut(shortcut) {

			var
				section = $(shortcut).attr('data-shortcut-section');

			if($('#keyShortcuts .list table tbody[data-shortcut-section="'+section+'"]').length == 0) {
				$('#keyShortcuts .list .page-shortcuts table').append('<thead><th></th><th>'+ section +'</th></thead><tbody data-shortcut-section="'+ section +'"></tbody>');
			}
			$('#keyShortcuts .list table tbody[data-shortcut-section="'+section+'"]').append('<tr><td><div class="key">'+ $(shortcut).attr('data-shortcut-key') +' </div></td><td>'+ $(shortcut).attr('data-shortcut-description')+'</td></tr>');
		}		

		function hideShortcuts() {
			$('#keyShortcuts .keyboard-background-active').fadeOut();
			$('#keyShortcuts .panel').fadeOut();
		}

		$('#keyShortcuts').on("click", ".legend", function() {
			$('#keyShortcuts .keyboard-background-active').fadeIn();
			$('#keyShortcuts .panel').fadeIn();
		});

		$('#keyShortcuts').on("click", ".keyboard-background-active", function() {
			hideShortcuts();
		});		

		$('#keyShortcuts').on("click", ".close", function() {
			hideShortcuts();
		});		
	}
	if($("[data-shortcut-key]").length) {
	  	if (!$("[data-help]").length) {
		    TW.workbench.help.init_helpSystem();
	  	}
	    keyShortcuts();	
	}
});