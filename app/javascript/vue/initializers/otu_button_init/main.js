import { createApp } from 'vue'
import App from './app.vue'

function init (element) {
  const id = `otu-radial-${(Math.random().toString(36).substr(2, 5))}`
  const objectId = element.getAttribute('data-id')
  const taxonName = element.getAttribute('data-taxon-name')
  const klass = element.getAttribute('data-klass')
  const redirect = element.getAttribute('data-redirect')

  if (objectId && taxonName) {
    const props = {
      id: id,
      taxonName: taxonName,
      objectId: objectId,
      klass: klass,
      redirect: (redirect === 'true')
    }
    const app = createApp(App, props)
    app.mount(element)
  }
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-otu-button="true"]')) {
    document.querySelectorAll('[data-otu-button="true"]').forEach(element => {
      init(element)
    })
  }
})
