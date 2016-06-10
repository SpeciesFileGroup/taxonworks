$(document).ready( function() {
  	if($('#hub_tabs').length) {	
/*		$('#favorite').children('a').attr("data-icon", "favorite");
		$('#tasks').children('a').attr("data-icon", "task");
		$('#data').children('a').attr("data-icon", "data");
		$('#data').children('a').addClass("small-icon");
		$('#recent').children('a').attr("data-icon", "recent");
		$('#worker').children('a').attr("data-icon", "options");
		$('#worker').children('a').addClass("small-icon");
		$('#related').children('a').attr("data-icon", "related");
		$('#related').children('a').addClass("small-icon");
		$('#icons').children('a').attr("data-icon", "icons");
		$('#icons').children('a').addClass("small-icon");
*/
		$('.hub_tabs').on('click', 'li', function() {
			location.href = $(this).children("a").attr('href');
		});
/*		$('.hub_link').addClass('on_hub'); */
	}	
});
