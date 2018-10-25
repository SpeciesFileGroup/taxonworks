var TW = TW || {}
TW.views = TW.views || {}
TW.views.tasks = TW.views.tasks || {}
TW.views.tasks.nomenclature = TW.views.tasks.nomenclature || {}
TW.views.tasks.nomenclature.new_taxon_name = TW.views.tasks.nomenclature.new_taxon_name || {}

import Vue from 'vue'
import vueResource from 'vue-resource'
import HelpSystem from '../../plugins/help/help'
import en from './lang/help/en'
import App from './app.vue'
import { init as initRequest } from './request/resources'
import { newStore } from './store/store.js'

Object.assign(TW.views.tasks.nomenclature.new_taxon_name, {
  init: function () {
    Vue.use(vueResource)
    Vue.use(HelpSystem, { 
      languages: {
        en: en
      }
    })
    Vue.use(require('vue-shortkey'))

    var token = $('[name="csrf-token"]').attr('content')
    Vue.http.headers.common['X-CSRF-Token'] = token
    new Vue({
      store: newStore,
      el: '#new_taxon_name_task',
      render: function (createElement) {
        return createElement(App)
      }
    })
  }
})

$(document).on('turbolinks:load', function () {
  if ($('#new_taxon_name_task').length) {
    initRequest()
    TW.views.tasks.nomenclature.new_taxon_name.init()
  }
})
