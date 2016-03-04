$(document).ready( function() {
	$('#favorite').prepend('<img src="/assets/icons/star.svg"/>');
	$('#tasks').prepend('<img src="/assets/icons/task.svg"/>');
	$('#data').prepend('<img src="/assets/icons/data.svg"/>');
	$('#recent').prepend('<img src="/assets/icons/recent.svg"/>');	
	$('#worker').prepend('<img src="/assets/icons/options.svg"/>');	
	$('#related').prepend('<img src="/assets/icons/related.svg"/>');
	$('#hub_tabs').on('click', 'li', function() {
		location.href = $(this).children("a").attr('href');
	});	
});