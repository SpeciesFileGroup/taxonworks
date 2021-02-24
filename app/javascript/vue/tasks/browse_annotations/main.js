import Vue from 'vue'
import App from './app.vue'

function init() {
  new Vue({
    el: '#browse_annotations',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#browse_annotations')) {
    init()
  }
});