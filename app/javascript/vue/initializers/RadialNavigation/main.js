import { createApp } from 'vue'
import { convertType } from '@/helpers'
import RadialNavigation from '@/components/radials/navigation/radial.vue'

function init(element) {
  const id = `radial-navigation-${Math.random().toString(36).substr(2, 5)}`
  const globalId = element.getAttribute('data-global-id')
  const teleport = convertType(element.getAttribute('data-teleport'))
  const props = {
    id,
    globalId,
    teleport
  }
  const app = createApp(RadialNavigation, props)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-radial-navigation="true"]')) {
    document
      .querySelectorAll('[data-radial-navigation="true"]')
      .forEach((element) => {
        init(element)
      })
  }
})
