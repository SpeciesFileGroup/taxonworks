var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.descriptor = TW.views.tasks.descriptor || {}

import Vue from 'vue'
import vueResource from 'vue-resource'

Object.assign(TW.views.tasks.descriptor, {
  init: function () {
    Vue.use(vueResource)

    var App = require('./app.vue').default
    Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

    new Vue({
		  	el: '#descriptor_task',
		  	render: function (createElement) {
		  		return createElement(App)
		  	}
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#descriptor_task').length) {
    TW.views.tasks.descriptor.init()
  }
})