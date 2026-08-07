import { createApp } from 'vue'
import QuickCitation from '@/components/citations/quick.vue'

function init(element) {
  const id = `quick-citation-${Math.random().toString(36).substr(2, 5)}`
  const sourceId = element.getAttribute('data-source-id')
  const globalId = element.getAttribute('data-global-id')
  const klass = element.classList.value
  const props = {
    id,
    sourceId,
    globalId,
    class: klass
  }
  const app = createApp(QuickCitation, props)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-quick-citation="true"]')) {
    document
      .querySelectorAll('[data-quick-citation="true"]')
      .forEach((element) => {
        init(element)
      })
  }
})
