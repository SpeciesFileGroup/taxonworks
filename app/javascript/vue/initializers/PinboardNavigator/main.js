import { createApp } from 'vue'
import App from '@/components/pinboard/navigator.vue'

function init() {
  const app = createApp(App)
  app.mount('#vue-pinboard-navigator')
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#vue-pinboard-navigator')) {
    init()
  }
})
