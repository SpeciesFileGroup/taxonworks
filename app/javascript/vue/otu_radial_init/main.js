
import Vue from 'vue'
import App from './app.vue'

function init(element) {
  let id = `otu-radial-${(Math.random().toString(36).substr(2, 5))}`
  let globalId = $(element).attr('data-global-id')

  if (globalId) {
    $(element).attr('id', id)

    new Vue({
      el: `#${id}`,
      render: function (createElement) {
        return createElement(App, {
          props: {
            id: id,
            globalId: globalId
          }
        })
      }
    })
  }
}

$(document).on('turbolinks:load', function () {
  if (document.querySelector('[data-otu-radial="true"]')) {
    document.querySelectorAll('[data-otu-radial="true"]').forEach((element) => {
      init(element)
    })
  }
})
