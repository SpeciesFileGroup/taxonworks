import Vue from 'vue'
import App from './app.vue'

function init (element) {
  const id = `default-confidence-${(Math.random().toString(36).substr(2, 5))}`
  const globalId = element.getAttribute('data-confidence-object-global-id')
  const count = element.getAttribute('data-inserted-confidence-level-count')

  if (globalId) {
    element.setAttribute('id', id)
    new Vue({
      el: `#${id}`,
      render: function (createElement) {
        return createElement(App, {
          props: {
            globalId: globalId,
            count: count
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