import Vue from 'vue'
import App from './app.vue'
import SoftValidation from 'tasks/nomenclature/browse/components/validations'

function initSearch () {
  new Vue({
    el: '#vue-browse-nomenclature-search',
    render: function (createElement) {
      return createElement(App)
    }
  })
}

function initValidations () {
  const globalIds = {
    'Taxon name': Array.from(document.querySelectorAll('#taxon-validations div')).map(node => node.getAttribute('data-global-id')),
    Status: Array.from(document.querySelectorAll('#status-validations div')).map(node => node.getAttribute('data-global-id')),
    Relationships: Array.from(document.querySelectorAll('#relationships-validations div')).map(node => node.getAttribute('data-global-id'))
  }

  new Vue({
    el: '#vue-browse-validation-panel',
    render: function (createElement) {
      return createElement(SoftValidation, {
        props: {
          globalIds
        }
      })
    }
  })
}

document.addEventListener('turbolinks:load', (event) => {
  if (document.querySelector('#vue-browse-nomenclature-search')) {
    initSearch()
  }
  if (document.querySelector('#vue-browse-validation-panel')) {
    initValidations()
  }
})
