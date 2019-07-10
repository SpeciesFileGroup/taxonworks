import Vue from 'vue'

function init (element) {
    var App = require('./app.vue').default

    let id = `otu-radial-${(Math.random().toString(36).substr(2, 5))}`
    let taxonId = element.getAttribute('data-taxon-id')
    let taxonName = element.getAttribute('data-taxon-name')
    let redirect = element.getAttribute('data-redirect')

    if (taxonId && taxonName) {
      element.setAttribute('id', id)

      new Vue({
        el: `#${id}`,
        render: function (createElement) {
          return createElement(App, {
            props: {
              id: id,
              taxonName: taxonName,
              taxonId: taxonId,
              redirect: (redirect == 'true' ? true : false)
            }
          })
        }
      })
    }
  }

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('[data-otu-button="true"]')) {
    document.querySelectorAll('[data-otu-button="true"]').forEach((element) => {
      init(element)
    })
  }
})