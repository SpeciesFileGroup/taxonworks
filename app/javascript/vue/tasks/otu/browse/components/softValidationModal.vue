<template>
  <modal-component
    @close="showModal = false"
    v-if="showModal">
    <h3 slot="header">Soft validation</h3>
    <div slot="body">
      <ul class="no_bullets soft_validation list">
        <li v-for="validation in validations">
          <span v-html="validation"/>
        </li>
      </ul>
    </div>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import { GetSoftValidation } from '../request/resources'

export default {
  components: {
    ModalComponent
  },
  data () {
    return {
      isLoading: false,
      validations: undefined,
      showModal: false
    }
  },
  mounted () {
    document.addEventListener('click', this.checkValidation)
  },
  methods: {
    checkValidation (event) {
      if (event.target.getAttribute('data-global-id') && !this.isLoading) {
        const globalId = event.target.getAttribute('data-global-id')
        this.isLoading = true
        GetSoftValidation(globalId).then(response => {
          this.validations = response.body.validations.soft_validations.map(validation => validation.message)
          this.showModal = true
          this.isLoading = false
        }, () => {
          this.isLoading = false
        })
      }
    }
  },
  destroyed () {
    document.removeEventListener('click', this.checkValidation)
  }
}
</script>
