var TW = TW || {}
TW.vue = TW.vue || {}
TW.vue.otuButton = TW.vue.otuButton || {}

import Vue from 'vue'

Object.assign(TW.vue.otuButton, {
  init: function (element) {
    var App = require('./app.vue').default

    let id = `otu-button-${(Math.random().toString(36).substr(2, 5))}`
    let taxonId = $(element).attr('data-taxon-id')
    let taxonName = $(element).attr('data-taxon-name')

    if (taxonId && taxonName) {
      $(element).attr('id', id)

      new Vue({
        el: `#${id}`,
        render: function (createElement) {
          return createElement(App, {
            props: {
              id: id,
              taxonName: taxonName,
              taxonId: taxonId
            }
          })
        }
      })
    }
  }
})

$(document).on('turbolinks:load', function () {
  if ($('[data-otu-button="true"]').length) {
    $('[data-otu-button="true"]').each(function () {
      TW.vue.otuButton.init(this)
    })
  }
})