
import Vue from 'vue'
import App from './app.vue'

function init(element) {
  let id = `collection-object-radial-${(Math.random().toString(36).substr(2, 5))}`
  let globalId = element.getAttribute('data-global-id')

  if (globalId) {
    element.setAttribute('id', id)

    new Vue({
      el: `#${id}`,
      render: function (createElement) {
        return createElement(App, {
          props: {
            id: id,
            globalId: globalId
          }
        })
      }
    })
  }
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('[data-collection-object-radial="true"]')) {
    document.querySelectorAll('[data-collection-object-radial="true"]').forEach((element) => {
      init(element)
    })
  }
})
