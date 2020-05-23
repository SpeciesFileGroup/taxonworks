<template>
  <div>
    <button 
      type="button"
      class="button normal-input button-default"
      @click="openModal">
      Matrix row coder
    </button>
    <modal-component
      v-if="show"
      @close="reset">
      <h3 slot="header">Select observation matrix to open MRC or Image matrix</h3>
      <div
        slot="body">
        <spinner-component
          v-if="loading"
          legend="Loading"/>
        <div>
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
          <div class="flex-separate">
            <div>
              <h3>Already in observation matrices</h3>
              <ul class="no_bullets">
                <template v-for="item in alreadyInMatrices">
                  <li
                    :key="item.id"
                    v-if="item.object_tag.toLowerCase().includes(filterType.toLowerCase())">
                    <label>
                      <input
                        @click="loadMatrix(item)"
                        :value="item"
                        name="select-matrix-1"
                        type="radio">
                      <span v-html="item.object_tag"/>
                    </label>
                  </li>
                </template>
              </ul>
            </div>
            <div>
              <h3>Add to observation matrices</h3>
              <ul class="no_bullets">
                <template v-for="item in matrices">
                  <li
                    :key="item.id"
                    v-if="item.object_tag.toLowerCase().includes(filterType.toLowerCase()) && !alreadyInMatrices.includes(item)">
                    <label>
                      <input
                        @click="loadMatrix(item)"
                        :value="item"
                        name="select-matrix-2"
                        type="radio">
                      <span v-html="item.object_tag"/>
                    </label>
                  </li>
                </template>
              </ul>
            </div>
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
  computed: {
    alreadyInMatrices () {
      return this.matrices.filter(item => {
        return this.rows.find(row => { return item.id === row.observation_matrix_id })
      })
    },
    alreadyInCurrentMatrix () {
      return this.rows.filter(row => { return this.selectedMatrix.id === row.observation_matrix_id })
    }
  },
  data () {
    return {
      show: false,
      matrices: [],
      selectedMatrix: undefined,
      rows: [],
      create: false,
      filterType: '',
      loading: false
    }
  },
  methods: {
    loadMatrix (matrix) {
      this.selectedMatrix = matrix
      if (matrix.is_media_matrix) {
        this.openImageMatrix()
      } else {
        this.openMatrixRowCoder()
      }
    },
    openModal () {
      this.loading = true
      this.show = true
      GetObservationMatrices().then(response => {
        this.matrices = response.body
        this.loading = false
      })
      GetObservationRow({ otu_id: this.otuId }).then(response => {
        this.rows = response.body
      })
    },
    reset () {
      this.selectedMatrix = undefined
      this.rows = []
      this.create = false
      this.show = false
    },
    createRow () {
      return new Promise((resolve, reject) => {
        if (window.confirm('Are you sure you want to add this otu to this matrix?')) {
          let data = {
            observation_matrix_id: this.selectedMatrix.id,
            otu_id: this.otuId,
            type: 'ObservationMatrixRowItem::SingleOtu'
          }
          CreateObservationMatrixRow(data).then(response => {
            this.rows.push(response.body)
            resolve(response)
          })
        }
      })
    },
    setMatrix (id) {
      GetObservationMatrix(id).then(response => {
        this.selectedMatrix = response.body
        this.loadMatrix(this.selectedMatrix)
      })
    },
    openMatrixRowCoder () {
      if (this.alreadyInCurrentMatrix.length) {
        window.open(`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${this.alreadyInCurrentMatrix[0].id}`, '_blank')
      } else {
        this.createRow().then(() => {
          window.open(`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${this.alreadyInCurrentMatrix[0].id}`, '_blank')
        })
      }
    },
    openImageMatrix () {
      if (this.alreadyInCurrentMatrix.length) {
        window.open(`/tasks/matrix_image/matrix_image/index?observation_matrix_id=${this.selectedMatrix.id}&row_id=${this.alreadyInCurrentMatrix[0].id}&row_position=${this.alreadyInCurrentMatrix[0].position}`, '_blank')
      } else {
        this.createRow().then(() => {
          window.open(`/tasks/matrix_image/matrix_image/index?observation_matrix_id=${this.selectedMatrix.id}&row_id=${this.alreadyInCurrentMatrix[0].id}&row_position=${this.alreadyInCurrentMatrix[0].position}`, '_blank')
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
