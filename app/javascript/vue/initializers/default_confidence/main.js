import Vue from 'vue'

function init (element) {
    var App = require('./app.vue').default

    let id = `default-confidence-${(Math.random().toString(36).substr(2, 5))}`
    let globalId = element.getAttribute('data-global-id')

    if (globalId) {
      element.setAttribute('id', id)

      new Vue({
        el: `#${id}`,
        render: function (createElement) {
          return createElement(App, {
            props: {
              globalId: globalId
            }
          })
        }
      })
    }
  }

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('[data-confidence-default="true"]')) {
    document.querySelectorAll('[data-confidence-default="true"]').forEach((element) => {
      init(element)
    })
  }
})