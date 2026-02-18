import { createApp } from 'vue'
import VToggleLockHeader from '@/components/ui/VToggleLockHeader.vue'

function init(element) {
  const app = createApp(VToggleLockHeader)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const element = document.querySelector('#toggle-lock-header')

  if (element) {
    init(element)
  }
})
