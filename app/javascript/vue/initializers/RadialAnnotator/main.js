import { createApp } from 'vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'

function init(element) {
  const id = `radial-annotator-${Math.random().toString(36).substr(2, 5)}`
  const globalId = element.getAttribute('data-global-id')
  const showCount = element.getAttribute('data-show-count')
  const pulse = element.getAttribute('data-pulse')
  const props = {
    id,
    globalId,
    showCount: showCount === 'true',
    pulse: pulse === 'true'
  }
  const app = createApp(RadialAnnotator, props)

  app.mount(element)
}

document.addEventListener('turbolinks:load', (_) => {
  if (document.querySelector('[data-radial-annotator="true"]')) {
    document
      .querySelectorAll('[data-radial-annotator="true"]')
      .forEach((element) => {
        init(element)
      })
  }
})
