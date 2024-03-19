import { createApp } from 'vue'
import App from './App.vue'

function init(element) {
  const weeksAgo = element.getAttribute('data-weeks-ago')
  const app = createApp(App, { weeksAgo })

  app.mount(element)
}

document.addEventListener('turbolinks:load', (_) => {
  if (document.querySelector('[data-weeks-review="true"]')) {
    document
      .querySelectorAll('[data-weeks-review="true"]')
      .forEach((element) => {
        init(element)
      })
  }
})
