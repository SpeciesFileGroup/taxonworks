import { createApp } from 'vue'
import App from './App.vue'

let app

function init(linkElement) {
  const containerElement = document.querySelector(
    '#curation-issue-tracker-container'
  )

  app = createApp(App, {
    element: linkElement
  })
  app.mount(containerElement)
}

document.addEventListener('turbolinks:load', () => {
  const issueTrackerElement = document.querySelector(
    '[data-curation-issue-tracker]'
  )

  if (issueTrackerElement) {
    init(issueTrackerElement)
  }
})

document.addEventListener('turbolinks:before-render', () => {
  if (app) app.unmount()
})
