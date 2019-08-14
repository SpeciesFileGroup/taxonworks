import Vue from 'vue'
import vueResource from 'vue-resource'
import HelpSystem from 'plugins/help/help'
import en from './lang/help/en'
import vueShortkey from 'vue-shortkey'
import App from './app.vue'

function init () {
  Vue.use(vueResource)
  Vue.use(vueShortkey)
  Vue.use(HelpSystem, { 
    languages: {
      en: en
    }
  })

  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

  new Vue({
    el: '#vue_new_combination',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue_new_combination')) {
    init()
  }
})
