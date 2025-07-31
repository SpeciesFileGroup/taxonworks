import { createApp } from 'vue'
import RadialOtu from '@/components/radials/object/radial.vue'

function init(element) {
  const id = `otu-radial-${Math.random().toString(36).substr(2, 5)}`
  const globalId = element.getAttribute('data-global-id')

  if (globalId) {
    const props = {
      id,
      globalId,
      buttonTitle: 'OTU quick forms',
      buttonClass: 'btn-hexagon-w button-default'
    }
    const app = createApp(RadialOtu, props)
    app.mount(element)
  }
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-otu-radial="true"]')) {
    document.querySelectorAll('[data-otu-radial="true"]').forEach((element) => {
      init(element)
    })
  }
})
