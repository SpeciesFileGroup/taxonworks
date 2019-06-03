import Vue from 'vue'
import App from './app.vue'

function init(element) {
  let id = `radial-annotator-${(Math.random().toString(36).substr(2, 5))}`
  let globalId = $(element).attr('data-global-id')
  let showCount = $(element).attr('data-show-count')

  if (globalId) {
    $(element).attr('id', id)

    new Vue({
      el: `#${id}`,
      render: function (createElement) {
        return createElement(App, {
          props: {
            id: id,
            globalId: globalId,
            showCount: (showCount == 'true') ? true : false
          }
        })
      }
    })
  }
}

$(document).on('turbolinks:load', function () {
  if (document.querySelector('[data-radial-annotator="true"]')) {
    document.querySelectorAll('[data-radial-annotator="true"]').forEach((element) => {
      init(element)
    })
  }
})
