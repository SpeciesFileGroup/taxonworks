var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.nomenclature      = TW.views.tasks.nomenclature || {};
TW.views.tasks.nomenclature.new_taxon_name = TW.views.tasks.nomenclature.new_taxon_name || {};

import Vue from 'vue'
import vueResource from 'vue-resource'

Object.assign(TW.views.tasks.nomenclature.new_taxon_name, {
	init: function() {

		Vue.use(vueResource);
		Vue.use(require('vue-shortkey'))
		
		var store = require('./store/store.js').newStore();
		var App = require('./app.vue');
		var token = $('[name="csrf-token"]').attr('content');
		Vue.http.headers.common['X-CSRF-Token'] = token;

		new Vue({
			store,
		  	el: '#new_taxon_name_task',
		  	render: function (createElement) {
		  		return createElement(App);
		  	}
		})
	}
});

$(document).on('turbolinks:load', function() {
  if ($("#new_taxon_name_task").length) {
    TW.views.tasks.nomenclature.new_taxon_name.init();
  }
});