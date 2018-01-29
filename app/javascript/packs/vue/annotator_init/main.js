var TW = TW || {}
TW.vue = TW.vue || {}
TW.vue.annotator = TW.vue.annotator || {}

import Vue from 'vue'

Object.assign(TW.vue.annotator, {
  init: function (element) {
    var App = require('./app.vue').default

    let id = `radial-annotator-${(Math.random().toString(36).substr(2, 5))}`
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
  if ($('[data-radial-annotator="true"]').length) {
  	$('[data-radial-annotator="true"]').each(function () {
  		TW.vue.annotator.init(this)
  	})
  }
})
