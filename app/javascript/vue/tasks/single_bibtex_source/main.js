import Vue from 'vue'
import App from './app.vue'

function init() {
  new Vue({
    el: '#single_bibtex_source',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#single_bibtex_source')) {
    init()
  }
});