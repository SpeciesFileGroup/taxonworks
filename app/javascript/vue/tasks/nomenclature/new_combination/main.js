import Vue from 'vue'
import HelpSystem from 'plugins/help/help'
import en from './lang/help/en'
import vueShortkey from 'vue-shortkey'
import App from './app.vue'

function init () {
  Vue.use(vueShortkey)
  Vue.use(HelpSystem, {
    languages: {
      en: en
    }
  })

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
