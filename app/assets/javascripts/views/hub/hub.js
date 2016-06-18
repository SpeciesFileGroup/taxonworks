$(document).ready( function() {
  	if($('#hub_tabs').length) {	
		$('.hub_tabs').on('click', 'li', function() {
			location.href = $(this).children("a").attr('href');
		});
	}	
});
