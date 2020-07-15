<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="showModal = true"
      :disabled="!selectedIds.length">
      Add to matrix
    </button>
    <modal-component
      v-if="showModal"
      :container-style="{ width: '500px' }"
      @close="closeModal">
      <h3 slot="header">Add OTUs to matrix</h3>
      <div slot="body">
        <spinner-component
          v-if="isLoading"
          legend="Loading..."/>
        <div class="horizontal-left-content">
          <select
            class="full_width margin-small-right"
            v-model="matrixId">
            <option :value="undefined">Select a observation matrix</option>
            <option
              v-for="item in observationMatrices"
              :key="item.id"
              :value="item.id">
              {{ item.name }}
            </option>
          </select>
          <button
            @click="addRows"
            :disabled="!matrixId"
            class="button normal-input button-submit">
            Add
          </button>
        </div>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import SpinnerComponent from 'components/spinner'
import { GetObservationMatrices, CreateObservationMatrixRow } from '../request/resources'

export default {
  components: {
    ModalComponent,
    SpinnerComponent
  },
  props: {
    selectedIds: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      isLoading: false,
      showModal: false,
      observationMatrices: [],
      matrixId: undefined
    }
  },
  watch: {
    showModal: {
      handler (newVal) {
        if (newVal) {
          this.isLoading = true
          GetObservationMatrices().then(response => {
            this.observationMatrices = response.body
            this.isLoading = false
          })
        }
      },
      immediate: true
    }
  },
  methods: {
    addRows () {
      const promises = []
      const data = this.selectedIds.map(id => {
        return {
          observation_matrix_id: this.matrixId,
          otu_id: id,
          type: 'ObservationMatrixRowItem::SingleOtu'
        }
      })

      data.forEach(row => { promises.push(CreateObservationMatrixRow(row)) })

      Promise.all(promises).then(() => {
        TW.workbench.alert.create('Rows was successfully added to matrix.', 'notice')
        this.closeModal()
      })
    },
    closeModal () {
      this.showModal = false
      this.$emit('close')
    }
  }
}
</script>
