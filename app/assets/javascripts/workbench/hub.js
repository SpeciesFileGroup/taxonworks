$(document).ready( function() {
	$('#favorite').children('a').attr("data-icon", "favorite");
	$('#tasks').children('a').attr("data-icon", "task");
	$('#data').children('a').attr("data-icon", "data");
	$('#recent').children('a').attr("data-icon", "recent");
	$('#worker').children('a').attr("data-icon", "options");
	$('#related').children('a').attr("data-icon", "related");
	$('#hub_tabs').on('click', 'li', function() {
		location.href = $(this).children("a").attr('href');
	});	
});