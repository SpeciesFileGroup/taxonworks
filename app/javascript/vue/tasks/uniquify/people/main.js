import Vue from 'vue'
import App from './app.vue'

function init() {
  new Vue({
    el: '#uniquify_people',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#uniquify_people')) {
    init()
  }
});