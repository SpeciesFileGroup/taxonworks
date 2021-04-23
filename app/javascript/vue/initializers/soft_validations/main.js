import Vue from 'vue'
import SoftValidation from 'tasks/nomenclature/browse/components/validations'

function initValidations () {
  const globalIds = {
    '': Array.from(document.querySelectorAll('#validation-panel .soft_validation')).map(node => node.getAttribute('data-global-id'))
  }

  new Vue({
    el: '#validation-panel',
    render: function (createElement) {
      return createElement(SoftValidation, {
        props: {
          globalIds
        }
      })
    }
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#validation-panel')) {
    initValidations()
  }
})
