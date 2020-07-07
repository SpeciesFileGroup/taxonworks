import Vue from 'vue'
import App from './app.vue'

function init () {
  new Vue({
    el: '#nomenclature_by_source',
    render: function (createElement) {
      return createElement(App);
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#nomenclature_by_source')) {
    init()
  }
})