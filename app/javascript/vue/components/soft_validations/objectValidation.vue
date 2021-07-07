<template>
  <span>
    <template v-if="inPlace">
      <ul class="no_bullets soft_validation list">
        <li
          v-for="(validation, index) in validations"
          :key="index">
          <span v-html="validation"/>
        </li>
      </ul>
    </template>
    <template v-else>
      <span
        v-if="validations.length"
        data-icon="warning"
        class="cursor-pointer"
        @click="setModalView(true)"
        title="Click to show soft validations"
      />
      <modal-component
        v-if="showModal"
        @close="setModalView(false)">
        <template #header>
          <h3>Soft validation</h3>
        </template>
        <template #body>
          <ul class="no_bullets soft_validation list">
            <li
              v-for="(validation, index) in validations"
              :key="index">
              <span v-html="validation"/>
            </li>
          </ul>
        </template>
      </modal-component>
    </template>
  </span>
</template>

<script>

import ModalComponent from 'components/ui/Modal.vue'
import { SoftValidation } from 'routes/endpoints'

export default {
  components: { ModalComponent },

  props: {
    globalId: {
      type: String,
      required: true
    },

    validateObject: {
      type: Object,
      default: undefined
    },

    inPlace: {
      type: Boolean,
      default: false
    }
  },

  data () {
    return {
      validations: [],
      showModal: false
    }
  },

  watch: {
    validateObject: {
      handler (newVal) {
        if (newVal) {
          this.getSoftValidation()
        }
      },
      deep: true
    }
  },

  mounted () {
    this.getSoftValidation()
  },

  methods: {
    getSoftValidation () {
      SoftValidation.find(this.globalId).then(response => {
        this.validations = response.body.soft_validations.map(validation => validation.message)
      })
    },

    setModalView (value) {
      this.showModal = value
    }
  }
}
</script>
