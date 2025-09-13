import { createApp } from 'vue'
import VToggleTheme from '@/components/ui/VToggleTheme.vue'

function init(element) {
  const app = createApp(VToggleTheme)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const element = document.querySelector('#toggle-theme')

  if (element) {
    init(element)
  }
})
