var TW = TW || {};
TW.views = TW.views || {};
TW.views.hub = TW.views.hub || {};
TW.views.hub.filter = TW.views.hub.filter || {};

Object.assign(TW.views.hub.filter, {
	filterHubTask: undefined,
	init: function() {
		if(!$("#filter").attr('loaded') == true) { 
			$("#filter").attr('loaded', 'true');
			this.filterHubTask = new FilterHub();
			if(document.querySelector('#task_carrousel')) {
				this.resizeTaskCarrousel();
			}
			this.loadCategoriesIcons();
			this.handleEvents();
		}
	},

	resizeTaskCarrousel() {
		var userWindowWidth = $(window).width();
		var userWindowHeight = $(window).height();
		var minWindowWidth = ($("#favorite-page").length ? 1000 : 700);
		var cardWidth = 427.5;
		var cardHeight = 180;

		var tmpHeight = userWindowHeight - document.querySelector('.task-section').offsetTop
		tmpHeight = tmpHeight / cardHeight

		if(userWindowWidth < minWindowWidth) {
			if($("#favorite-page").length)
				this.filterHubTask.changeTaskSize(1)
			else
				this.filterHubTask.changeTaskSize(1, Math.floor(tmpHeight))
		}
		else {
			var tmp = userWindowWidth - minWindowWidth

			tmp = tmp / cardWidth
			if(tmp > 0) {
				if($("#favorite-page").length)
					this.filterHubTask.changeTaskSize(Math.ceil(tmp))
				else 
					this.filterHubTask.changeTaskSize(Math.ceil(tmp), Math.floor(tmpHeight))
			}
		}
	},

	handleEvents: function() {
		var that = this
		window.addEventListener("resize", function(){ that.resizeTaskCarrousel() })
	},

	loadCategoriesIcons: function() {
		$('.data_card div[data-category-collecting_event="true"]').append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 34 51"><path fill="currentColor" d="M33.2,23.2L21,49.1c-0.7,1.5-2.2,2.4-3.9,2.4s-3.1-0.9-3.8-2.4L1.1,23.2c-0.9-1.8-1.1-4-1.1-6C0,7.8,7.7,0.1,17.1,0.1s17.1,7.7,17.1,17.1C34.3,19.3,34,21.4,33.2,23.2z M17.1,8.7c-4.7,0-8.6,3.9-8.6,8.6s3.9,8.6,8.6,8.6s8.6-3.9,8.6-8.6S21.9,8.7,17.1,8.7z"/></svg>');
		$('.data_card div[data-category-nomenclature="true"]').append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="363.6 252.8 71.8 56.6"><path fill="currentColor" d="M420.2,297.8c0,6.4-5.2,11.6-11.6,11.6h-33.4c-6.4,0-11.6-5.2-11.6-11.6v-33.4c0-6.4,5.2-11.6,11.6-11.6h33.4c1.6,0,3.2,0.3,4.7,1c0.4,0.2,0.6,0.5,0.7,0.9s0,0.8-0.4,1.2l-2,2c-0.4,0.4-0.8,0.5-1.3,0.3c-0.6-0.2-1.2-0.2-1.8-0.2h-33.4c-3.5,0-6.4,2.9-6.4,6.4v33.4c0,3.5,2.9,6.4,6.4,6.4h33.4c3.5,0,6.4-2.9,6.4-6.4v-5.1c0-0.3,0.1-0.6,0.4-0.9l2.6-2.6c0.4-0.4,0.9-0.5,1.4-0.3s0.8,0.6,0.8,1.2L420.2,297.8L420.2,297.8z M427.9,272.1l-27,27h-11.6v-11.6l27-27L427.9,272.1zM404,290.6l-6.1-6.1l-4.7,4.7v2.2h3.9v3.9h2.2L404,290.6z M415.7,266.4l-14.1,14.1c-0.4,0.4-0.4,1,0,1.3c0.4,0.4,1,0.3,1.3,0l14.1-14.1c0.4-0.4,0.4-1,0-1.3C416.7,266,416.1,266,415.7,266.4z M430.5,269.6L419,258l3.7-3.7c1.5-1.5,4-1.5,5.5,0l6.1,6.1c1.5,1.5,1.5,4,0,5.5L430.5,269.6z"/></svg>');
		$('.data_card div[data-category-collection_object="true"]').append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="-633 395 12 12"><path fill="currentColor" d="M-622.9,395.3l1.9,4.1c-2.6,0.9-2.7,4.2-2.8,5.2c0,0.3-0.8-0.1-1-0.4c-0.5-0.6,0.2-2.5-0.1-3.2c-0.4-1-1.5-0.9-2-0.8c-1.2,0.4-1.9,2.8-2.5,3.9c-0.2,0.3-1,0.3-1.2,0c-0.5-0.8,1.5-3.6,1.5-3.6s-2.6,1.5-3.1,1.6c-0.3,0.1-1-0.6-0.7-0.8c1.6-1.3,3.5-2.3,3.5-2.3s-2.5,1.1-3.3,0.7c-0.3-0.1-0.4-0.5-0.2-0.8c0.3-0.4,3.2-1.2,3.2-1.2s-2,0-2.4-0.1c-0.3-0.1-0.5-0.6,0.2-1c0.1-0.1,5.6-0.3,7.1-0.5C-623.8,396-622.9,395.3-622.9,395.3z"/><rect fill="currentColor" x="-628.5" y="403.8" width="2.9" height="2.9"/></svg>');
		$('.data_card div[data-category-source="true"]').append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="-451 255.2 55.8 51.8"><path fill="currentColor" d="M-395.5,271.5l-9.2,30.3c-0.8,2.8-3.8,5.1-6.7,5.1h-30.9c-3.4,0-7.1-2.7-8.3-6.2c-0.5-1.5-0.5-3-0.1-4.3c0.1-0.7,0.2-1.3,0.2-2.1c0-0.5-0.3-1-0.2-1.4c0.1-0.8,0.8-1.4,1.4-2.3c1-1.7,2.1-4.4,2.5-6.1c0.2-0.6-0.2-1.4,0-1.9c0.2-0.6,0.8-1.1,1.1-1.7c0.9-1.5,2.1-4.5,2.2-6.1c0.1-0.7-0.3-1.5-0.1-2c0.2-0.8,1-1.1,1.5-1.8c0.8-1.1,2.1-4.3,2.3-6.1c0.1-0.6-0.3-1.1-0.2-1.7c0.1-0.6,0.9-1.3,1.5-2.1c1.4-2.1,1.7-6.7,5.9-5.5l0,0.1c0.6-0.1,1.1-0.3,1.7-0.3h25.5c1.6,0,3,0.7,3.8,1.9c0.9,1.2,1.1,2.8,0.6,4.4L-410,292c-1.6,5.2-2.4,6.3-6.7,6.3h-29.1c-0.4,0-1,0.1-1.3,0.5c-0.3,0.4-0.3,0.7,0,1.4c0.7,1.9,3,2.3,4.8,2.3h30.9c1.2,0,2.7-0.7,3-1.9l10-33c0.2-0.6,0.2-1.3,0.2-1.9c0.8,0.3,1.5,0.8,2,1.4C-395.3,268.4-395.1,269.9-395.5,271.5z M-433.8,276.9h20.4c0.6,0,1.2-0.5,1.4-1.1l0.7-2.1c0.2-0.6-0.1-1.1-0.7-1.1h-20.4c-0.6,0-1.2,0.5-1.4,1.1l-0.7,2.1C-434.7,276.4-434.4,276.9-433.8,276.9z M-431,268.3h20.4c0.6,0,1.2-0.5,1.4-1.1l0.7-2.1c0.2-0.6-0.1-1.1-0.7-1.1h-20.4c-0.6,0-1.2,0.5-1.4,1.1l-0.7,2.1C-432,267.8-431.6,268.3-431,268.3z"/></svg>');
		$('.data_card div[data-category-biology="true"]').append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12"><path fill="currentColor" d="M1.9,11.7V0.3h4c1.4,0,2.4,0.3,3.1,0.8c0.7,0.5,1.1,1.3,1.1,2.3c0,0.6-0.1,1-0.4,1.5C9.4,5.3,9,5.6,8.5,5.8c0.6,0.1,1,0.4,1.4,0.9c0.3,0.4,0.5,1,0.5,1.6c0,1.1-0.3,1.9-1,2.5s-1.7,0.8-3,0.9H1.9z M4.3,5.1H6c1.2,0,1.8-0.5,1.8-1.4c0-0.5-0.2-0.9-0.4-1.1C7,2.3,6.6,2.2,5.9,2.2H4.3V5.1z M4.3,6.7v3.1h2c0.6,0,1-0.1,1.3-0.4C7.9,9.1,8,8.8,8,8.3c0-1-0.5-1.6-1.6-1.6H4.3z"/></svg>');
		$('.data_card div[data-category-matrix="true"]').append('<?xml version="1.0" encoding="iso-8859-1"?><svg version="1.1" id="Matrix" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 28.051 28.051" width="12px" height="12px" style="enable-background:new 0 0 28.051 28.051;" xml:space="preserve"><g><path d="M25.351,0H2.698C1.446,0,0.434,1.004,0.434,2.232v23.59c0,1.23,1.012,2.229,2.264,2.229h22.653c1.248,0,2.266-0.998,2.266-2.229V2.232C27.617,1.004,26.599,0,25.351,0z M8.662,26.373H4.053c-1.101,0-1.994-0.877-1.994-1.963v-4.586h6.603C8.662,19.824,8.662,26.373,8.662,26.373z M8.662,17.527H2.059v-6.625h6.603C8.662,10.902,8.662,17.527,8.662,17.527zM8.662,8.605H2.059v-4.96c0-1.082,0.894-1.963,1.994-1.963h4.608v6.923H8.662z M17.582,26.373h-6.624v-6.549h6.624V26.373zM17.582,17.527h-6.624v-6.625h6.624V17.527z M17.582,8.605h-6.624V1.682h6.624V8.605z M25.989,24.41c0,1.086-0.895,1.963-1.992,1.963H19.88v-6.549h6.109V24.41z M25.989,17.527H19.88v-6.625h6.109V17.527z M25.989,8.605H19.88V1.682h4.117c1.098,0,1.992,0.881,1.992,1.963V8.605z"/></g></svg>');
		$('.data_card div[data-category-dna="true"]').append('<?xml version="1.0" encoding="utf-8"?><svg version="1.1" id="Helix" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="-633 395 12 12" style="enable-background:new -633 395 12 12;" xml:space="preserve" width="12px" height="12px"><path d="M-625.8,395.5"/><path d="M-626,397.9c0.6-0.3,1-0.6,1.3-0.9c0.7-0.6,1-1.2,1-1.9c0-0.1,0-0.1-0.1-0.1h-0.6c-0.1,0-0.1,0-0.1,0.1s0,0.2,0,0.3v0.2c0,0.2-0.1,0.4-0.3,0.6l-0.1,0.2c-0.2,0.2-0.4,0.4-0.7,0.6l-0.3,0.2c-0.2,0.1-0.6,0.3-0.8,0.4"/><path d="M-624.7,403c0.7-0.5,1-1.2,1-1.9l0,0l0,0l0,0l0,0l0,0c0-0.7-0.3-1.3-1-1.9c-0.6-0.5-1.3-0.9-2.1-1.2c-1.4-0.7-2.7-1.4-2.7-2.7c0-0.1,0-0.1-0.1-0.1h-0.6c-0.1,0-0.1,0-0.1,0.1c0,0.7,0.3,1.4,1,1.9c0.5,0.4,1,0.6,1.5,0.9c-0.5,0.3-1.1,0.6-1.6,1c-0.6,0.6-0.9,1.2-0.9,1.9l0,0l0,0l0,0l0,0l0,0c0,0.7,0.3,1.3,1,1.9c0.6,0.5,1.3,0.9,2.1,1.2c1.4,0.7,2.7,1.4,2.7,2.7c0,0.1,0,0.1,0.1,0.1h0.6c0.1,0,0.1,0,0.1-0.1c0-0.7-0.3-1.4-1-1.9c-0.5-0.4-1.1-0.7-1.6-1C-625.7,403.6-625.2,403.2-624.7,403z M-625.7,402.9l-0.3,0.2c-0.3,0.2-0.6,0.4-1,0.5c-1.3-0.7-2.4-1.3-2.4-2.6c0-0.1,0-0.2,0-0.3v-0.2c0-0.2,0.4-0.8,0.4-0.8c0.2-0.2,0.4-0.4,0.7-0.6l0.3-0.2c0.3-0.2,0.6-0.4,1-0.5c1.3,0.7,2.4,1.3,2.4,2.6l0,0c0,0,0,0.1,0,0.2C-624.6,402.1-625.5,402.6-625.7,402.9z"/><path d="M-629.4,406.4"/><path d="M-628,404.1c-0.6,0.3-1,0.6-1.3,0.9c-0.7,0.6-1,1.2-1,1.9c0,0.1,0,0.1,0.1,0.1h0.5c0.1,0,0.1,0,0.1-0.1s0.1-0.5,0.1-0.5c0-0.2,0.4-0.8,0.4-0.8c0.2-0.2,0.4-0.4,0.7-0.6l0.3-0.2c0.2-0.1,0.5-0.3,0.7-0.4"/></svg>');
		$('.data_card div[data-category-image="true"]').append('<?xml version="1.0" encoding="iso-8859-1"?><!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"><svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 315.58 315.58" style="enable-background:new 0 0 315.58 315.58;" xml:space="preserve"><g><path d="M310.58,33.331H5c-2.761,0-5,2.238-5,5v238.918c0,2.762,2.239,5,5,5h305.58c2.763,0,5-2.238,5-5V38.331C315.58,35.569,313.343,33.331,310.58,33.331z M285.58,242.386l-68.766-71.214c-0.76-0.785-2.003-0.836-2.823-0.114l-47.695,41.979l-60.962-75.061c-0.396-0.49-0.975-0.77-1.63-0.756c-0.631,0.013-1.22,0.316-1.597,0.822L30,234.797V63.331h255.58V242.386z"/><path d="M210.059,135.555c13.538,0,24.529-10.982,24.529-24.531c0-13.545-10.991-24.533-24.529-24.533c-13.549,0-24.528,10.988-24.528,24.533C185.531,124.572,196.511,135.555,210.059,135.555z"/></g></svg>');
	}
});


$(document).on('turbolinks:load', function() {
	if($("#data_cards").length || $("#task_carrousel").length) {
		TW.views.hub.filter.init();
	}
});
