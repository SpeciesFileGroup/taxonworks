import Vue from 'vue'
import App from './app.vue'

function init () {
  new Vue({
    el: '#descriptor_task',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#descriptor_task')) {
    init()
  }
})