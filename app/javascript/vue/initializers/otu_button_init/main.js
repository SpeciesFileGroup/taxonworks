import Vue from 'vue'
import App from './app.vue'

function init (element) {
  const id = `otu-radial-${(Math.random().toString(36).substr(2, 5))}`
  const objectId = element.getAttribute('data-id')
  const taxonName = element.getAttribute('data-taxon-name')
  const klass = element.getAttribute('data-klass')
  const redirect = element.getAttribute('data-redirect')

  if (objectId && taxonName) {
    element.setAttribute('id', id)

    const app = new Vue({
      el: `#${id}`,
      render: function (createElement) {
        return createElement(App, {
          props: {
            id: id,
            taxonName: taxonName,
            objectId: objectId,
            klass: klass,
            redirect: (redirect === 'true')
          }
        })
      }
    })
  }
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('[data-otu-button="true"]')) {
    document.querySelectorAll('[data-otu-button="true"]').forEach((element) => {
      init(element)
    })
  }
})
