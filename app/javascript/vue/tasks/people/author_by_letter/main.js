import Vue from 'vue'
import App from './app.vue'

function init() {
  new Vue({
    el: '#author_by_letter',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#author_by_letter')) {
    init()
  }
});