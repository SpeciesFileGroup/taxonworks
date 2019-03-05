var TW = TW || {}
TW.vue = TW.vue || {}
TW.vue.radial = TW.vue.radial || {}
TW.vue.radial.object = TW.vue.radial.object || {}

import Vue from 'vue'
import App from './app.vue'

Object.assign(TW.vue.radial.object, {
  init: function (element) {
    let id = `radial-object-${(Math.random().toString(36).substr(2, 5))}`
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
})

$(document).on('turbolinks:load', function () {
  if ($('[data-radial-object="true"]').length) {
    $('[data-radial-object="true"]').each(function () {
      TW.vue.radial.object.init(this)
    })
  }
})
