import Vue from 'vue'
import App from './app.vue'

function init() {
  new Vue({
    el: '#vue-task-labels-print-labels',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-task-labels-print-labels')) {
    init()
  }
})
