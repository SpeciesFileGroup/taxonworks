
import Vue from 'vue'

var TW = TW || {}
TW.vue = TW.vue || {}
TW.vue.otuRadial = TW.vue.otuRadial || {}

Object.assign(TW.vue.otuRadial, {
  init: function (element) {
    var App = require('./app.vue').default

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
})

$(document).on('turbolinks:load', function () {
  if ($('[data-otu-radial="true"]').length) {
    $('[data-otu-radial="true"]').each(function () {
      TW.vue.otuRadial.init(this)
    })
  }
})
