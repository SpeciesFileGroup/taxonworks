import { createApp } from 'vue'
import RadialModal from './RadialModal.vue'

function init(element) {
  const taxonNameId = element.getAttribute('data-taxon-name-id')
  const props = { taxonNameId }
  const app = createApp(RadialModal, props)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-radial-annotator="true"]')) {
    document
      .querySelectorAll('[data-otu-radial-annotator="true"]')
      .forEach((element) => {
        init(element)
      })
  }
})
