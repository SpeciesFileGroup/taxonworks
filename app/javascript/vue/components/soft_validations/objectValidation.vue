<template>
  <div
    v-if="inPlace"
    class="position-relative flex-col soft-validation-in-place"
  >
    <VSpinner
      v-if="isLoading"
      legend="Loading validations..."
    />
    <ul
      v-else-if="validations.length"
      class="no_bullets soft_validation list"
    >
      <li
        v-for="(validation, index) in validations"
        :key="index"
      >
        <span v-html="validation" />
      </li>
    </ul>
    <div
      v-else
      class="horizontal-center-content flex-auto text-lg text-muted-color"
    >
      No validations found
    </div>
  </div>

  <template v-else>
    <v-icon
      v-if="isLoading"
      small
      name="question"
      color="gray"
      title="Loading validation."
    />
    <v-icon
      v-else-if="!validations.length"
      small
      name="check"
      color="green"
      title="Validation passed."
      class="cursor-pointer"
    />
    <v-icon
      v-else-if="validations.length"
      small
      name="attention"
      color="attention"
      class="cursor-pointer"
      @click="setModalView(true)"
      title="Click to show soft validations"
    />
    <modal-component
      v-if="showModal"
      @close="setModalView(false)"
    >
      <template #header>
        <h3>Soft validation</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            v-for="(validation, index) in validations"
            :key="index"
          >
            <span>
              <v-icon
                small
                name="attention"
                color="attention"
              />
              <span
                class="margin-small-left"
                v-html="validation"
              />
            </span>
          </li>
        </ul>
      </template>
    </modal-component>
  </template>
</template>

<script>
import ModalComponent from '@/components/ui/Modal.vue'
import { SoftValidation } from '@/routes/endpoints'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

export default {
  components: {
    ModalComponent,
    VIcon,
    VSpinner
  },

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

  data() {
    return {
      validations: [],
      showModal: false,
      isLoading: false,
      cancelRequest: undefined
    }
  },

  watch: {
    validateObject: {
      handler(newVal) {
        if (newVal) {
          this.getSoftValidation()
        }
      },
      deep: true
    }
  },

  mounted() {
    this.getSoftValidation()
  },

  methods: {
    getSoftValidation() {
      this.isLoading = true
      SoftValidation.find(this.globalId, {
        cancelRequest: (c) => {
          this.cancelRequest = c
        }
      })
        .then((response) => {
          this.validations = response.body.soft_validations.map(
            (validation) => validation.message
          )
        })
        .catch((_) => {})
        .finally(() => {
          this.isLoading = false
        })
    },

    setModalView(value) {
      this.showModal = value
    }
  },

  beforeUnmount() {
    if (this.cancelRequest) {
      this.cancelRequest()
    }
  }
}
</script>
