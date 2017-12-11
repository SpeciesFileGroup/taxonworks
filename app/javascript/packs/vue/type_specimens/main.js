var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.type_specimens      = TW.views.tasks.type_specimens || {};

import Vue from 'vue'
import vueResource from 'vue-resource'

Object.assign(TW.views.tasks.type_specimens, {
	init: function() {
		
		Vue.use(vueResource);
		var App = require('./app.vue').default;
		var store = require('./store/store.js').newStore();
		Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

		new Vue({
			store,
		  	el: '#vue_type_specimens',
		  	render: function (createElement) {
		  		return createElement(App);
		  	}
		})
	}
});

$(document).on('turbolinks:load', function() {
  if ($("#vue_type_specimens").length) {
    TW.views.tasks.type_specimens.init();
  }
});
