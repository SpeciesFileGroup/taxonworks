<template>
  <modal-component
    @close="showModal = false"
    v-if="showModal">
    <template #header>
      <h3>Soft validation</h3>
    </template>
    <template #body>
      <ul class="no_bullets soft_validation list">
        <li v-for="validation in validations">
          <span v-html="validation"/>
        </li>
      </ul>
    </template>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import { SoftValidation } from 'routes/endpoints'

export default {
  components: { ModalComponent },

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
        SoftValidation.find(globalId).then(response => {
          this.validations = response.body.validations.soft_validations.map(validation => validation.message)
          this.showModal = true
        }).finally(() => {
          this.isLoading = false
        })
      }
    }
  },

  unmounted () {
    document.removeEventListener('click', this.checkValidation)
  }
}
</script>
