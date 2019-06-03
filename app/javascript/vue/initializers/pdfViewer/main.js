import Vue from 'vue'
import App from './app.vue'

  function init(element) {
    let id = `pdf-viewer-${(Math.random().toString(36).substr(2, 5))}`
    element.id = id
    new Vue({
      el: `#${id}`,
      render: function (createElement) {
        return createElement(App, {})
      }
    })
  }

document.addEventListener('turbolinks:load', () => {
  if (document.querySelectorAll('[data-vue-pdf-app]').length) {
    document.querySelectorAll('[data-vue-pdf-app]').forEach((element) => {
      init(element)
    })
  }
})
