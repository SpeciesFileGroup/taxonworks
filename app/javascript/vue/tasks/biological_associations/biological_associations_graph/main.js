import { createApp } from 'vue'
import App from './App.vue'
import VNetworkGraph from 'v-network-graph'
import 'v-network-graph/lib/style.css'
import HelpSystem from '@/plugins/help/help'
import en from './lang/help/en.js'

function initApp(element) {
  const app = createApp(App)

  app.use(HelpSystem, {
    languages: {
      en
    }
  })

  app.use(VNetworkGraph)
  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  const el = document.querySelector('#vue-biological-associations-graph-task')

  if (el) {
    initApp(el)
  }
})
