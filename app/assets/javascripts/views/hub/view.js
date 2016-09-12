$(document).ready(function(){
	if($('#filter').length) {
	$('#filter').css({"margin-top":"0px",
					  "margin-right":"1em"});
	$('#filter .navigation-controls').css({ "flex-direction":"column",
											"justify-content":"flex-start !important",
											"align-items":"left"});

	$('#filter .navigation-controls .navigation-item').css("border","0px");	
	$('#filter .navigation-controls .navigation-item').css({"border-bottom":"1px solid #F5F5F5",
															"box-sizing":"border-box",
															"width":"100%",
															"padding":"1em",
															"justify-content":"flex-start"
															});

	$('#filter .navigation-controls .navigation-item:first-child').css("border-top","1px solid #F5F5F5");

	$('#filter .flexbox').css("justify-content",null);
	$('#filter .flexbox').css("width","250px");
	$('#filter .flexbox .item2').css("min-width",null);
	$('#navigation_list').css({	"flex-direction": "row",
								"align-items": "flex-start",
								"margin-top": "1em",
								"justify-content": "flex-start"});

	$('#data_cards').css({"flex-direction": "column",
						 "width": "100%"});

	$('[data-section="Core"').css("min-width", "100%");
	$('[data-section="Supporting"').css("min-width", "100%");
	$('[data-section="Annotations"').css("min-width", "100%");
}
});