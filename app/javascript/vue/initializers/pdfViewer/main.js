var TW = TW || {}
TW.vue = TW.vue || {}
TW.vue.pdf = TW.vue.pdf || {}
TW.vue.pdf.viewer = TW.vue.pdf.viewer || {}

import Vue from 'vue'
import App from './app.vue'

Object.assign(TW.vue.pdf.viewer, {
  init: function (element) {
    let id = `pdf-viewer-${(Math.random().toString(36).substr(2, 5))}`
    element.id = id
    new Vue({
      el: `#${id}`,
      render: function (createElement) {
        return createElement(App, {})
      }
    })
  }
})


document.addEventListener('turbolinks:load', () => {
  if (document.querySelectorAll('[data-vue-pdf-app]').length) {
    document.querySelectorAll('[data-vue-pdf-app]').forEach((element) => {
      TW.vue.pdf.viewer.init(element)
    })
  }
})
