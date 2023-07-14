import { createApp } from 'vue'
import VMap from '@/components/georeferences/map.vue'

function init(element) {
  const geojsonObj = element.getAttribute('data-geojson-object')
  const geojsonString = element.getAttribute('data-geojson-string')
  const geojsonData = JSON.parse(geojsonObj || geojsonString)
  const geojson = geojsonData.feature
    ? [geojsonData]
    : [
        {
          features: [
            {
              ...geojsonData,
              properties: { aggregate: true }
            }
          ]
        }
      ]

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
  if (document.querySelector('[data-map-shape]')) {
    document.querySelectorAll('[data-map-shape]').forEach((element) => {
      init(element)
    })
  }
})
