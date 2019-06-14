import Vue from 'vue'
import App from './app.vue'

function init (){
  new Vue({
    el: '#vue-task-matrix-image',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-matrix-image')) {
    init()
  }
})