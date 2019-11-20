import Vue from 'vue'
import App from './app.vue'
import VueShortkey from 'vue-shortkey'

function init (){
  Vue.use(VueShortkey)
  new Vue({
    el: '#vue-task-collection-objects-filter',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-task-collection-objects-filter')) {
    init()
  }
})