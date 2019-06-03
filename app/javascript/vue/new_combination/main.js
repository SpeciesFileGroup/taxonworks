import Vue from 'vue'
import vueResource from 'vue-resource'
import HelpSystem from '../plugins/help/help'
import en from './lang/help/en'
import vueShortkey from 'vue-shortkey'

function init () {
  Vue.use(vueResource)
  Vue.use(vueShortkey)
  Vue.use(HelpSystem, { 
    languages: {
      en: en
    }
  })

  var App = require('./app.vue').default
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

  new Vue({
    el: '#vue_new_combination',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

$(document).on('turbolinks:load', function () {
  if ($('#vue_new_combination').length) {
    init()
  }
})
