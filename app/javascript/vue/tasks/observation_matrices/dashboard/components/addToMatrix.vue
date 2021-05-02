<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="showModal = true"
      :disabled="!selectedIds.length">
      Open in matrix
    </button>
    <modal-component
      v-if="showModal"
      :container-style="{ width: '600px' }"
      @close="closeModal">
      <h3 slot="header">Add OTUs to matrix</h3>
      <div slot="body">
        <spinner-component
          v-if="isLoading"
          legend="Loading..."/>
        <div class="horizontal-left-content">
          <select
            class="full_width margin-small-right"
            v-model="matrix">
            <option :value="undefined">Select a observation matrix</option>
            <option
              v-for="item in observationMatrices"
              :key="item.id"
              :value="item">
              {{ item.name }}
            </option>
          </select>
          <button
            @click="addRows"
            :disabled="!matrix"
            class="button normal-input button-submit">
            Add
          </button>
          <button
            type="button"
            class="button normal-input button-default margin-small-left"
            :disabled="!matrix"
            @click="openInteractiveKeys(matrix.id)">
            Interactive keys
          </button>
          <button
            v-if="matrix && matrix.is_media_matrix"
            type="button"
            class="button normal-input button-default margin-small-left"
            @click="openImageMatrix(matrix.id)">
            Image matrix
          </button>
        </div>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import SpinnerComponent from 'components/spinner'
import { RouteNames } from 'routes/routes'
import { ObservationMatrix, ObservationMatrixRowItem } from 'routes/endpoints'

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
    addRows () {
      const promises = []
      const data = this.selectedIds.map(id => {
        return {
          observation_matrix_id: this.matrix.id,
          otu_id: id,
          type: 'ObservationMatrixRowItem::Single::Otu'
        }
      })

      data.forEach(row => { promises.push(ObservationMatrixRowItem({ observation_matrix_row_item: row })) })

      Promise.all(promises).then(() => {
        TW.workbench.alert.create('Rows was successfully added to matrix.', 'notice')
        this.closeModal()
      })
    },
    closeModal () {
      this.showModal = false
      this.$emit('close')
    },
    openInteractiveKeys (id) {
      window.open(`${RouteNames.InteractiveKeys}?observation_matrix_id=${id}`, '_self')
    },
    openImageMatrix (id) {
      window.open(`${RouteNames.ImageMatrix}?observation_matrix_id=${id}`, '_self')
    }
  }
}
</script>
