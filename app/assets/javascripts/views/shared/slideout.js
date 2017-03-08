var TW = TW || {};
TW.views = TW.views || {};
TW.views.shared = TW.views.shared || {};
TW.views.shared.slideout = TW.views.shared.slideout || {};

Object.assign(TW.views.shared.slideout, {
	init: function() {
		var that = this;
		$(document).on('click', '.slide-panel-circle-icon', function() {		
			that.closeHideSlideoutPanel($(this).closest('.slide-panel'));
		});

		$(document).on('click', '.slide-panel-category-header', function() {
			$(this).parent().find('.slide-panel-category-content').toggle(250);
		});	

		$('.slide-panel').each(function(i) {
			$(this).find('.slide-panel-description').text($(this).children('.slide-panel-header').text());
		});

		$('[data-pdfviewer]').on("click", function() {
	      	that.closeHideSlideoutPanel($('[data-panel-name="pinboard"]'));
	      	that.closeHideSlideoutPanel($('[data-panel-name="pdfviewer"]'));
	  	});
	},

	closeHideSlideoutPanel: function(panel) {
			if($(panel).attr('data-panel-position') == 'relative') {
				$(panel).css('position','absolute');
			}
			if($(panel).hasClass("slide-left")){
				$(panel).css("right", "");		
				if($(panel).css('left') == '0px') {
					$(panel).attr('data-panel-open','false');
					$(panel).animate({left: "-" + $(panel).css("width")}, 500, function() {
						$(panel).css('position','fixed');
					});
					$(panel).css('z-index',"1000");					
				}
				else {
					$(panel).attr('data-panel-open','true');
					$(panel).animate({left: "0px"}, 500, function() {
						$(panel).css('position','relative');
					});
					$(panel).css('z-index',"1100");
				}
			}
			else {
				$(panel).css("left", "");		
				if($(panel).css('right') == '0px') {
					$(panel).attr('data-panel-open','false');
					$(panel).animate({right: "-" + $(panel).css("width")}, 500, function() {
						if($(panel).attr('data-panel-position') == 'relative') {
							$(panel).css('position','fixed');
						}
					});
					$(panel).css('z-index',"1000");
				}
				else {
					$(panel).attr('data-panel-open','true');
					$(panel).animate({right: "0px"}, 500, function() {
						if($(panel).attr('data-panel-position') == 'relative') {
							$(panel).css('position','relative');
						}
					});
					$(panel).css('z-index',"1100");
				}
			}		
		}
});

$(document).ready(function() {
	var slideout = TW.views.shared.slideout;
	slideout.init();
});