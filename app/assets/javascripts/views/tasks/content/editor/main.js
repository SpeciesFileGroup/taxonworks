var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.content = TW.views.tasks.content || {};
TW.views.tasks.content.editor = TW.views.tasks.content.editor || {};


Object.assign(TW.views.tasks.content.editor, {
	init: function() {
		var Vue = require('vue');
		var vueResource = require('vue-resource');
		Vue.use(vueResource);

		var store = require('./store/store.js').newStore();
		var App = require('./App.vue');
		var token = $('[name="csrf-token"]').attr('content');
		Vue.http.headers.common['X-CSRF-Token'] = token;

		new Vue({
			store,
		  	el: '#content_editor',
		  	render: function (createElement) {
		  		return createElement(App);
		  	}
		})
	}
});

$(document).ready( function() {
  if ($("#content_editor").length) {
    TW.views.tasks.content.editor.init();
  }
});