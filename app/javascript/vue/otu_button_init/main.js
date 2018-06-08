var TW = TW || {}
TW.vue = TW.vue || {}
TW.vue.otuRadial = TW.vue.otuRadial || {}

import Vue from 'vue'

Object.assign(TW.vue.otuRadial, {
  init: function (element) {
    var App = require('./app.vue').default

    let id = `otu-radial-${(Math.random().toString(36).substr(2, 5))}`
    let taxonId = $(element).attr('data-taxon-id')
    let taxonName = $(element).attr('data-taxon-name')
    let redirect = $(element).attr('data-redirect')

    if (taxonId && taxonName) {
      $(element).attr('id', id)

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
})

$(document).on('turbolinks:load', function () {
  if ($('[data-otu-button="true"]').length) {
    $('[data-otu-button="true"]').each(function () {
      TW.vue.otuRadial.init(this)
    })
  }
})