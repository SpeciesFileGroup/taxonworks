/*

To active and use:

Add data-help attribute on the elements to make enable the text legend and bubbles on each element.
Example:

<div data-help="This is a test"></div>

*/

var TW = TW || {};
TW.workbench = TW.workbench || {};
TW.workbench.help = TW.workbench.help || {};

Object.assign(TW.workbench.help, {

	init_helpSystem: function () {
		var timeOut = undefined
		firstClick = true;
		helpLoaded = false,

		$('body').append('<div class="help-legend"></div>');
		$('body').append('<div class="help-background-active"></div>');
		$('body').append('<div class="help-button"><div class="help-button-description">Help</div></div>');
		if ($("[data-help]").length) {
			$('.help-button').addClass("help-button-present");
		}

		$(document).off('mouseenter, mouseleave', '.help-bubble-tip');

		$(document).on({
			mouseenter: function (evt) {
				if (TW.workbench.help.helpActive()) {
					var
						position = $(this).offset();

					$('.help-legend').empty();
					$('.help-legend').css({ "top": (position.top + $(this).height()) + "px", maxWidth: '' });
					$('.help-legend').show();
					$('.help-legend').html($(this).parent().attr("data-help"));

					var containerLegend = $('.help-legend').width()
					var distanceRight = $(window).width() - position.left

				if(containerLegend > distanceRight) {
					$('.help-legend').addClass('tooltip-help-legend-right');
					$('.help-legend').removeClass('tooltip-help-legend-left');
					$('.help-legend').css({
						left: '',
						right: distanceRight - $(this).width() + 'px',
						maxWidth: $(window).width() - distanceRight + 'px'
					})
				} else {
					$('.help-legend').removeClass('tooltip-help-legend-right');
					$('.help-legend').addClass('tooltip-help-legend-left');
					$('.help-legend').css({
						left: position.left + 'px',
						right: ''
					});
				}
				TW.workbench.help.hideAllExcept($(this).attr("data-bubble-id"));
				}
			},
			mouseleave: function () {
				$('.help-legend').empty();
				$('.help-legend').hide();
				$('.help-legend').css('max-width', '');
				TW.workbench.help.showAll('.help-bubble-tip');
			}
		}, ".help-bubble-tip");

		Mousetrap.bind("alt+shift+/", function () {
			TW.workbench.help.activeDisableHelp();
		});


		$(".help-button").on('click', function () {
			TW.workbench.help.activeDisableHelp();
		});

		$(".help-background-active").on('click', function () {
			TW.workbench.help.activeDisableHelp();
		});
	},

	discoverDataHelp: function () {

	},

	addBubbleTips: function (className) {
		$(className).each(function (i) {
			if (!$(this).attr('help-discovered')) {
				$(this).append('<div class="help-bubble-tip" data-bubble-id="' + (i) + '">' + (i + 1) + '</div>');
				$(this).attr('help-discovered', true);
			}
		});
	},

	activeDisableHelp: function () {

		if (firstClick) {
			TW.workbench.help.addBubbleTips('[data-help]');
			firstClick = false;
		}
		if (!TW.workbench.help.helpActive()) {
			TW.workbench.help.addBubbleTips('[data-help]');
			$('.help-background-active').fadeIn(100);
			$('.help-bubble-tip').show(100);
			$('.help-button').addClass('help-button-active');
			$('.help-legend').empty();
			$('[data-help]').each(function() {
				$(this).addClass('help-tip');
			});
		}
		else {
			$('.help-background-active').fadeOut(100);
			$('.help-bubble-tip').hide();
			$('.help-button').removeClass('help-button-active');
			$('.help-legend').hide(250);
			$('[data-help]').each(function() {
				$(this).removeClass('help-tip');
			});
		}
	},

	helpActive: function () {
		if ($('.help-background-active').css('display') === "none") {
			return false;
		}
		else {
			return true;
		}
	},

	hideAllExcept: function (value) {
		$('.help-bubble-tip').each(function (i) {
			if ($(this).attr('data-bubble-id') != value) {
				$(this).addClass('help-bubble-tip-hidden');
			}
		})
	},

	showAll: function (className) {
		$(className).removeClass('help-bubble-tip-hidden');
	},

});

$(document).on('turbolinks:load', function () {
	if ($("[data-help]").length) {
		TW.workbench.help.init_helpSystem();
	}
});
