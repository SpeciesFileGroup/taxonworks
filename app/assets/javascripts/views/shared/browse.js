$(document).ready(function() {
  if($("#browse-view").length) {
    browseView();
  }
});
function browseView() {

	$('.filter .open').on('click', function() {
		//alert(getRotationDegrees($(this)));
		$(this).css('transform', 'rotate(' + ($(this).rotationInfo().deg + 180) + 'deg)');
		if($(this).rotationInfo().deg == 360) { 
			$(this).css('transform', 'rotate(1deg)');
		}
	});

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

	$('#filterBrowse').on('click', '.navigation-item', function(selector) {

		if($(this).attr('data-filter-reset') === 'reset') {
			$('[data-filter]').each( function() {
				if($(this).hasClass("active")) {
					isActive($(this),'active');
				}
				$($(this).attr('data-filter')).animate({
            		fontSize: '100%'
        		});
				$($(this).children()).attr('data-icon', 'show');
			});
		}
		else {
			isActive($(this),'active');
			if($(this).children().attr('data-icon') == "show") {
				$($(this).children()).attr('data-icon', 'hide');
				$($(this).attr('data-filter')).animate({
            	fontSize: '0px'
        		});
			}
			else {
				$($(this).children()).attr('data-icon', 'show');
				$($(this).attr('data-filter')).animate({
            	fontSize: '100%'
        		});			
			}
		}
	});
}