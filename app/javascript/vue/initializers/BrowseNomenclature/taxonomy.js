import TaxonomyPanel from '@/tasks/nomenclature/browse/components/Taxonomy/TaxonomyPanel.vue'
import { createApp } from 'vue'

let app

function init(element, taxonId) {
  app = createApp(TaxonomyPanel, {
    taxonId
  })

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const taxonomyPanel = document.querySelector('[data-taxonomy-panel]')

  if (taxonomyPanel) {
    const id = Number(taxonomyPanel.getAttribute('data-taxonomy-panel'))

    init(taxonomyPanel, id)
  }
})

document.addEventListener('turbolinks:before-render', () => {
  if (app) app.unmount()
})
