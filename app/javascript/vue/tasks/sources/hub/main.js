import Vue from 'vue'
import App from './app.vue'

function init() {
  new Vue({
    el: '#vue-task-source-hub',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-task-source-hub')) {
    init()
  }
})
