<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="showModal = true"
      :disabled="!otuIds.length"
    >
      Open in interactive key
    </button>
    <modal-component
      v-if="showModal"
      :container-style="{ width: '600px' }"
      @close="showModal = false">
      <template #header>
        <h3>Select a matrix</h3>
      </template>
      <template #body>
        <spinner-component
          v-if="isLoading"
          legend="Loading..."/>
        <pin-component
          class="button-circle"
          type="ObservationMatrix"
          @getItem="openInteractiveKey($event.id)"
          section="ObservationMatrices"/>
        <ul class="no_bullets">
          <li
            class="margin-small-bottom"
            v-for="item in observationMatrices"
            :key="item.id">
            <button
              class="button normal-input button-default"
              @click="openInteractiveKey(item.id)">
              {{ item.name }}
            </button>
          </li>
        </ul>
      </template>
    </modal-component>
  </div>
</template>

<script>

import { RouteNames } from 'routes/routes'
import { ObservationMatrix } from 'routes/endpoints'
import ModalComponent from 'components/ui/Modal.vue'
import SpinnerComponent from 'components/spinner.vue'
import PinComponent from 'components/getDefaultPin.vue'

export default {
  components: {
    ModalComponent,
    SpinnerComponent,
    PinComponent
  },

  props: {
    otuIds: {
      type: Array,
      required: true
    }
  },

  data () {
    return {
      isLoading: false,
      showModal: false,
      observationMatrices: [],
      matrix: undefined
    }
  },

  watch: {
    showModal: {
      handler (newVal) {
        if (newVal) {
          this.isLoading = true
          ObservationMatrix.all().then(response => {
            this.observationMatrices = response.body
            this.isLoading = false
          })
        }
      },
      immediate: true
    }
  },

  methods: {
    openInteractiveKey (matrixId) {
      window.open(`${RouteNames.InteractiveKeys}?observation_matrix_id=${matrixId}&otu_filter=${this.otuIds.join('|')}`, '_blank')
      this.showModal = false
    }
  }
}
</script>
