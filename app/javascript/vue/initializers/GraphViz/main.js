import { instance } from '@viz-js/viz'

function init(element) {
  const data = element.getAttribute('data-diagram')

  instance().then((viz) => {
    element.innerHTML = ''
    element.appendChild(viz.renderSVGElement(data))
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-graph-viz="true"]')) {
    document.querySelectorAll('[data-graph-viz="true"]').forEach((element) => {
      init(element)
    })
  }
})
