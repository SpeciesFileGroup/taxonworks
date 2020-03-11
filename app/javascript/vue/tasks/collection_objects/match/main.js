import Vue from 'vue'
import App from './app.vue'

function init (){
  new Vue({
    el: '#vue-task-collection-object-match',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-collection-object-match')) {
    init()
  }
})