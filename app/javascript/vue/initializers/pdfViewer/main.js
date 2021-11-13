import { createApp } from 'vue'
import App from 'components/pdf/pdfViewer.vue'

function init (element) {
  const app = createApp(App)
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelectorAll('[data-vue-pdf-app]').length) {
    document.querySelectorAll('[data-vue-pdf-app]').forEach(element => {
      init(element)
    })
  }
})
