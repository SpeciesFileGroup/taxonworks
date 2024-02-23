import { createApp } from 'vue'
import OtuButton from '@/components/otu/otu.vue'

function init(element) {
  const id = `otu-radial-${Math.random().toString(36).substr(2, 5)}`
  const objectId = element.getAttribute('data-id')
  const taxonName = element.getAttribute('data-taxon-name')
  const klass = element.getAttribute('data-klass')
  const redirect = element.getAttribute('data-redirect')

  if (objectId && taxonName) {
    const props = {
      id,
      taxonName,
      objectId,
      klass,
      redirect: redirect === 'true'
    }
    const app = createApp(OtuButton, props)
    app.mount(element)
  }
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-otu-button="true"]')) {
    document.querySelectorAll('[data-otu-button="true"]').forEach((element) => {
      init(element)
    })
  }
})
