var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.loan      = TW.views.tasks.loan || {};

import Vue from 'vue'

Object.assign(TW.views.tasks.loan, {
	init: function() {
		
		var App = require('./app.vue').default;

		new Vue({
		  	el: '#edit_loan_task',
		  	render: function (createElement) {
		  		return createElement(App);
		  	}
		})
	}
});

$(document).on('turbolinks:load', function() {
  if ($("#edit_loan_task").length) {
    TW.views.tasks.loan.init();
  }
});