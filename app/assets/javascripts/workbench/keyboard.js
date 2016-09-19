
$(document).ready(function() {

	keyShortcuts = function() {

		var 
			hubShortcuts = '<thead> \
								<th></th> \
									<th> \
										Hub tasks \
									</th> \
							</thead> \
							<tbody> \
								<tr>\
									<td> \
									<div class="key">←</div> \
									</td> \
									<td>Show previous card tasks</td> \
								</tr> \
								<tr> \
									<td> \
										<div class="key">→</div> \
									</td> \
									<td>Show next card tasks</td> \
								</tr> \
							<tbody>';
			generalShortcuts = '<thead> \
									<th></th> \
									<th> \
										General shortcuts \
									</th> \
								</thead> \
								<tbody> \
									<tr> \
										<td><div class="key">Alt Ctrl h</div></td> \
										<td>Go to hub</td> \
									</tr> \
								<tbody>';	

			taxonNameShortcuts = '<thead> \
									<th></th> \
									<th>Taxon names browse</th> \
								</thead> \
								<tbody> \
									<tr> \
										<td> \
											<div class="key">←</div> \
										</td> \
										<td>Go to previous</td> \
									</tr> \
									<tr> \
										<td> \
											<div class="key">→</div> \
										</td> \
										<td>Go to next</td> \
									</tr> \
									<tr> \
										<td> \
										<div class="key">↑</div> \
										</td> \
										<td>Go to ancestor</td> \
									</tr> \
									<tr> \
										<td> \
											<div class="key">↓</div> \
										</td> \
										<td>Go to descendant</td> \
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
										<div class="item"> \
											<table> \
											' + generalShortcuts + hubShortcuts + '\
											</table> \
										</div> \
										<div class="item"> \
											<table> \
											'+taxonNameShortcuts+'\
											</table> \
										</div> \
									</div> \
								</div> \
							</div> \
						</div> \
						');
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
	if((window.location.href).indexOf('/hub') > 0) {
		keyShortcuts();	
	}
});