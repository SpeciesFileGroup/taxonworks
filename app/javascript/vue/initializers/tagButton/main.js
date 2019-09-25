import Vue from 'vue'
import App from './app.vue'

function init (element) {
  const id = `tag-default-${(Math.random().toString(36).substr(2, 5))}`
  const globalId = element.getAttribute('data-tag-object-global-id')
  const count = element.getAttribute('data-inserted-keyword-count')

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
  if (document.querySelector('[data-tag-default="true"]')) {
    document.querySelectorAll('[data-tag-default="true"]').forEach((element) => {
      init(element)
    })
  }
})