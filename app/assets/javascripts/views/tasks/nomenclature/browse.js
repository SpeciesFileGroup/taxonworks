var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.nomenclature = TW.views.tasks.nomenclature || {};
TW.views.tasks.nomenclature.browse = TW.views.tasks.nomenclature.browse || {};

Object.assign(TW.views.tasks.nomenclature.browse, {

	init: function() {
		var soft_validations = undefined;
		function fillSoftValidation() {
			if(soft_validations == undefined) {
				if ($('[data-global-id]').length) {
					soft_validations = {};
					$('[data-filter=".soft_validation_anchor"]').mx_spinner('show');
					$('[data-global-id]').each(function() {
						var 
							that = this;
						$.ajax({
							url: "/soft_validations/validate?global_id=" + $(this).attr("data-global-id"),
							dataType: "json",
						}).done(function(response) {
							if(response.validations.soft_validations.length) {
								if(!soft_validations.hasOwnProperty($(that).attr('id'))) {
							  		Object.defineProperty(soft_validations, $(that).attr('id'), { value: response.validations.soft_validations });
							  	}
							  	console.log(soft_validations);
							}
							else {
							  	$(that).remove();
							}
						});
					});
				}
			}
		}

		$('.filter .open').on('click', function() {
			$(this).css('transform', 'rotate(' + ($(this).rotationInfo().deg + 180) + 'deg)');
			if($(this).rotationInfo().deg == 360) { 
				$(this).css('transform', 'rotate(1deg)');
			}
		});

    // TODO: move to an external generic utilities helper
		function isActive(tag, className) {
			if($(tag).hasClass(className)) {
				$(tag).removeClass(className);
				return true;
			}
			else {
				$(tag).addClass(className);
				return false;
			}
		}

		$('[data-history-valid-name="true"]').each(function() {
			$(this).prepend('<span data-icon="ok"></span>');
		})

		$('[data-global-id]').on('click', function() {
			var list = '';
			if(soft_validations.hasOwnProperty($(this).attr('id'))) {

				soft_validations[$(this).attr('id')].forEach(function(item) {
					list += '<li class="list">' + item.message + '</li>';
				});

				$('#browse-view').append(' \
				<div class="modal-mask"> \
			      <div class="modal-wrapper"> \
			        <div class="modal-container"> \
			          <div class="modal-header"> \
			            <div class="modal-close"></div> \
			            <h3> \
			              Validation \
			            </h3> \
			          </div>\
			          <div class="modal-body soft_validation list"> \
			              <ul>' + list + '</ul> \
			          </div> \
			          <div class="modal-footer"> \
			          </div> \
			        </div>\
			      </div> \
			    </div>');
			}
		});

		$( document ).ajaxStop(function() {
		   $('[data-filter=".soft_validation_anchor"]').mx_spinner('hide');
		});
		
		$(document).on('click', '.modal-close', function() {
			$('.modal-mask').remove();
		});		

		$.fn.rotationInfo = function() {
		    var el = $(this),
		        tr = el.css("-webkit-transform") || el.css("-moz-transform") || el.css("-ms-transform") || el.css("-o-transform") || '',
		        info = {rad: 0, deg: 0};
		    if (tr = tr.match('matrix\\((.*)\\)')) {
		        tr = tr[1].split(',');
		        if(typeof tr[0] != 'undefined' && typeof tr[1] != 'undefined') {
		            info.rad = Math.atan2(tr[1], tr[0]);
		            info.deg = parseFloat((info.rad * 180 / Math.PI).toFixed(1));
		        }
		    }
		    return info;
		};
		
		$('#filterBrowse_button').on('click', function() {
			$('[data-filter-slide]').slideToggle(250);
		});

		$('#filterBrowse').on('click', '[data-filter=".soft_validation_anchor"]', function(selector) {
			fillSoftValidation();
		});

		$('#filterBrowse').on('click', '.navigation-item', function(selector) {

			if($(this).attr('data-filter-reset') === 'reset') {
				fillSoftValidation();
				$('[data-filter], [data-filter-font], [data-filter-row]').each( function(element) {
					if($(this).hasClass("active")) {
						isActive($(this),'active');
					}
					$($(this).attr('data-filter-font')).animate({
	            		fontSize: '100%'
	        		});
	        		$($(this).attr('data-filter-row')).parents('.history__record').show(255);
	        		$($(this).attr('data-filter')).show(255);
					$($(this).children()).attr('data-icon', 'show');
				});
			}
			else {
				isActive($(this),'active');
				if($(this).children().attr('data-icon') == "show") {
					$($(this).children()).attr('data-icon', 'hide');
					$($(this).attr('data-filter-font')).animate({
	            		fontSize: '0px'
	        		});
					$($(this).attr('data-filter-row')).parents('.history__record').hide(255);
					$($(this).attr('data-filter')).hide(255);
				}
				else {
					$($(this).children()).attr('data-icon', 'show');
					$($(this).attr('data-filter-font')).animate({
	            	fontSize: '100%'
	        		});
	        		$($(this).attr('data-filter-row')).parents('.history__record').show(255);		
	        		$($(this).attr('data-filter')).show(255);
				}
			}
		});
	}
});

$(document).on('turbolinks:load', function() {
  if($("#browse-view").length) {
    // no need for var, right?
    TW.views.tasks.nomenclature.browse.init();
  }
});
