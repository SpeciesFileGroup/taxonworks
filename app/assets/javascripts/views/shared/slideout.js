var TW = TW || {};
TW.views = TW.views || {};
TW.views.shared = TW.views.shared || {};
TW.views.shared.slideout = TW.views.shared.slideout || {};

Object.assign(TW.views.shared.slideout, {
	init: function() {
		var that = this;

		$(document).off('click', '.slide-panel-category-header');
		$(document).off('click', '.slide-panel-circle-icon');

		$(document).on('click', '.slide-panel-circle-icon', function() {
      //TODO: Remove this after make a new interface for filter CO and Otu by area
      if($("#filter-collection-objects").length || $("#otu_by_area_and_nomen").length) {
        that.closeHideSlideoutPanel($(this).closest('.slide-panel'));
      }
      //
      else {
        if($(this).closest('.slide-panel').hasClass("slice-panel-show")) {
					document.dispatchEvent(new CustomEvent('onSlidePanelClose', { detail: { name: $(this).closest('.slide-panel').attr('data-panel-name') } } ));
					$(this).closest('.slide-panel').removeClass("slice-panel-show").addClass("slice-panel-hide");
        }
        else {
					document.dispatchEvent(new CustomEvent('onSlidePanelOpen', { detail: { name: $(this).closest('.slide-panel').attr('data-panel-name') } } ));
					$(this).closest('.slide-panel').removeClass("slice-panel-hide").addClass("slice-panel-show");
				}
      }
			
		});

		$(document).on('click', '.slide-panel-category-header', function() {
			$(this).parent().find('.slide-panel-category-content').toggle(250);
		});	

		$('.slide-panel').each(function(i) {
			$(this).find('.slide-panel-description').text($(this).children('.slide-panel-header').text());
		});

		document.body.addEventListener("click", function (event) {
			if (event.target.getAttribute('data-pdfviewer')) {
				document.dispatchEvent(new CustomEvent('pdfViewer:load', { detail: {
					url: event.target.getAttribute('data-pdfviewer'),
					sourceId: event.target.getAttribute('data-sourceid')
				} 
			}));
			}
		});
	},

	closeHideSlideoutPanel: function(panel) {
			this.closeSlideoutPanel(panel);	
			this.openSlideoutPanel(panel);
	},
	closeSlideoutPanel: function(panel) {
		if($(panel).hasClass("slide-left")) {
			$(panel).css("right", "");		
			if($(panel).css('left') == '0px') {
				$(panel).attr('data-panel-open','false');
				$(panel).css('z-index',"1000");					
				$(panel).animate({left: "-" + $(panel).css("width")}, 500, function() {
					$(panel).css('position','fixed');
				});			
			}
		}
		else {
			$(panel).css("left", "");		
			if($(panel).css('right') == '0px') {
				$(panel).attr('data-panel-open','false');
				$(panel).css('z-index',"1000");						
				$(panel).animate({right: "-" + $(panel).css("width")}, 500, function() {
					$(panel).css('position','fixed');
				});
			}
		}
	},
	openSlideoutPanel: function(panel) {
		if($(panel).hasClass("slide-left")){
			$(panel).css("right", "");		
			if($(panel).css('left') != '0px') {
		if($(panel).attr('data-panel-position') == 'relative') {
			$(panel).css('position','absolute');
		}				
				$(panel).attr('data-panel-open','true');
				$(panel).animate({left: "0px"}, 500, function() {
					$(panel).css('position','relative');
				});
				$(panel).css('z-index',"1100");
			}
		}
		else {
			$(panel).css("left", "");		
			if($(panel).css('right') != '0px') {
		if($(panel).attr('data-panel-position') == 'relative') {
			$(panel).css('position','absolute');
		}				
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

$(document).on('turbolinks:load', function() {
	TW.views.shared.slideout.init();
});