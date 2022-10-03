import { createApp } from 'vue'
import VMap from 'components/georeferences/map.vue'

function init (element) {
  const geojson = [JSON.parse(element.getAttribute('data-feature-collection'))]
  const props = {
    geojson,
    width: '512px',
    height: '300px',
    zoom: 10,
    zoomBounds: 10
  }
  const app = createApp(VMap, props)

  app.mount(element)
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#_simple_map_form')) {
    document.querySelectorAll('#_simple_map_form').forEach((element) => {
      init(element)
    })
  }
})
