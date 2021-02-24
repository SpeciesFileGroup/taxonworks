import Vue from 'vue'
import App from './app.vue'

function init () {
  new Vue({
    el: '#vue-browse-nomenclature-search',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-browse-nomenclature-search')) {
    init()
  }
})
