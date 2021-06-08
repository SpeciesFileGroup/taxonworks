<template>
  <div class="separate-top">
    <autocomplete
      url="/observation_matrix_rows/autocomplete"
      param="term"
      :label="(item) => { return `(${item.observation_matrix_label}): ${item.label}` }"
      placeholder="Search a row"
      :clear-after="true"
      @getItem="selectRow"
    />
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Select task</h3>
      <div slot="body">
        <button
          class="button normal-input button-default"
          type="button"
          :disabled="!matrix.is_media_matrix"
          @click="openImageMatrix">
          Image matrix
        </button>
        <button
          :disabled="matrix.is_media_matrix"
          type="button"
          class="button normal-input button-default"
          @click="openMatrixRowCoder">
          Matrix row coder
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'
import ModalComponent from 'components/ui/Modal'
import { RouteNames } from 'routes/routes'
import { ObservationMatrix } from 'routes/endpoints'

export default {
  components: {
    Autocomplete,
    ModalComponent
  },
  data () {
    return {
      showModal: false,
      row: undefined,
      matrix: undefined
    }
  },
  methods: {
    openImageMatrix () {
      window.open(`${RouteNames.ImageMatrix}?observation_matrix_id=${this.matrix.id}&row_id=${this.row.id}&row_position=${this.row.position}`, '_self')
    },
    openMatrixRowCoder () {
      window.open(`${RouteNames.MatrixRowCoder}?observation_matrix_row_id=${this.row.id}`, '_self')
    },
    selectRow (row) {
      ObservationMatrix.find(row.observation_matrix_id).then(response => {
        this.row = row
        this.matrix = response.body
        this.showModal = true
      })
    }
  }
}
</script>
<style lang="scss" scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
