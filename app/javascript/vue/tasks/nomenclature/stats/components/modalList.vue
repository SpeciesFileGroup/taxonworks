<template>
  <div>
    <button 
      type="button"
      class="button normal-input button-default"
      @click="openModal">
      Select matrix
    </button>
    <modal-component
      v-if="show"
      @close="reset">
      <h3 slot="header">Select matrix</h3>
      <div
        slot="body">
        <spinner-component
          v-if="loading"
          legend="Loading"/>
        <div v-if="!selectedMatrix">
          <div
            class="separate-bottom horizontal-left-content">
            <input
              v-model="filterType"
              type="text"
              placeholder="Filter matrix">
            <default-pin 
              section="ObservationMatrices"
              type="ObservationMatrix"
              @getId="setMatrix"/>
          </div>
          <ul class="no_bullets">
            <template v-for="item in matrices">
              <li
                :key="item.id"
                v-if="item.object_tag.toLowerCase().includes(filterType.toLowerCase())">
                <label>
                  <input
                    @click="loadMatrix(item)"
                    :value="item"
                    name="select-matrix"
                    type="radio">
                  <span v-html="item.object_tag"/>
                </label>
              </li>
            </template>
          </ul>
        </div>
        <div v-else>
          <div class="horizontal-left-content middle">
            <h3 class="separate-right">{{ selectedMatrix.name }}</h3>
            <span
              class="button button-circle btn-undo button-default"
              @click="selectedMatrix = undefined"/>
          </div>
          <div v-if="row">
            <div
              v-if="!row.length"
              class="separate-bottom">
              <label>
                <input
                  v-model="create"
                  type="checkbox">
                Add to matrix
              </label>
            </div>
            <button
              type="button"
              class="button normal-input button-default"
              @click="openMatrixRowCoder"
              :disabled="!create && !row.length">
              Matrix row coder
            </button>
            <button
              v-if="selectedMatrix.is_media_matrix"
              type="button"
              class="button normal-input button-default"
              :disabled="!create && !row.length"
              @click="openImageMatrix">
              Image matrix
            </button>
          </div>
        </div>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import SpinnerComponent from 'components/spinner'
import DefaultPin from 'components/getDefaultPin'

import { GetObservationMatrices, GetObservationRow, CreateObservationMatrixRow, GetObservationMatrix } from '../request/resources'

export default {
  components: {
    ModalComponent,
    SpinnerComponent,
    DefaultPin
  },
  props: {
    otuId: {
      type: [String, Number],
      default: undefined
    }
  },
  data () {
    return {
      show: false,
      matrices: [],
      selectedMatrix: undefined,
      row: undefined,
      create: false,
      filterType: '',
      loading: false
    }
  },
  mounted () {

  },
  methods: {
    loadMatrix (matrix) {
      return new Promise((resolve, reject) => {
        this.selectedMatrix = matrix
        GetObservationRow(matrix.id, this.otuId).then(response => {
          this.row = response.body
          return resolve()
        })
      })
    },
    openModal () {
      this.loading = true
      this.show = true
      GetObservationMatrices().then(response => {
        this.matrices = response.body
        this.loading = false
      })
    },
    reset () {
      this.selectedMatrix = undefined
      this.row = undefined
      this.create = false
      this.show = false
    },
    createRow () {
      return new Promise((resolve, reject) => {
        let data = {
          observation_matrix_id: this.selectedMatrix.id,
          otu_id: this.otuId,
          type: 'ObservationMatrixRowItem::Single::Otu'
        }
        CreateObservationMatrixRow(data).then(response => {
          this.loadMatrix(this.selectedMatrix).then(() => {
            return resolve()
          })
        })
      })
    },
    setMatrix (id) {
      GetObservationMatrix(id).then(response => {
        this.selectedMatrix = response.body
      })
    },
    openMatrixRowCoder () {
      if (this.row.length) {
        window.open(`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${this.row[0].id}`, '_self')
      } else {
        this.createRow().then(() => {
          window.open(`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${this.row[0].id}`, '_self')
        })
      }
    },
    openImageMatrix () {
      if (this.row.length) {
        window.open(`/tasks/matrix_image/matrix_image/index?observation_matrix_id=${this.selectedMatrix.id}&row_id=${this.row[0].id}&row_position=${this.row[0].position}`, '_self')
      } else {
        this.createRow().then(() => {
          window.open(`/tasks/matrix_image/matrix_image/index?observation_matrix_id=${this.selectedMatrix.id}&row_id=${this.row[0].id}&row_position=${this.row[0].position}`, '_self')
        })
      }
    }
  }
}
</script>

<style scoped>
  /deep/ .modal-body {
    max-height: 80vh;
    overflow-y: scroll;
  }
  /deep/ .modal-container {
    width: 800px;
  }
</style>
