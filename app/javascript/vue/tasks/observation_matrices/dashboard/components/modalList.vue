<template>
  <div>
    <button 
      type="button"
      class="button normal-input button-submit"
      :class="{ 'button-default': otuSelected }"
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
          <h3 v-if="!otuSelected">OTU will be created for this taxon name</h3>
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
              <ul class="no_bullets">
                <template v-for="item in alreadyInMatrices">
                  <li
                    :key="item.id"
                    v-if="item.object_tag.toLowerCase().includes(filterType.toLowerCase())">
                    <button
                      class="button normal-input button-default margin-small-bottom"
                      @click="loadMatrix(item)"
                      v-html="item.object_tag"/>
                  </li>
                </template>
              </ul>
              <ul class="no_bullets">
                <template v-for="item in matrices">
                  <li
                    :key="item.id"
                    v-if="item.object_tag.toLowerCase().includes(filterType.toLowerCase()) && !alreadyInMatrices.includes(item)">
                    <button
                      class="button normal-input button-submit margin-small-bottom"
                      @click="loadMatrix(item)"
                      v-html="item.object_tag"/>
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

import ModalComponent from 'components/ui/Modal'
import SpinnerComponent from 'components/spinner'
import DefaultPin from 'components/getDefaultPin'
import {
  ObservationMatrix,
  ObservationMatrixRow,
  ObservationMatrixRowItem,
  Otu
} from 'routes/endpoints'

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
    },
    taxonNameId: {
      type: Number,
      required: true
    }
  },
  computed: {
    alreadyInMatrices () {
      return this.matrices.filter(item => this.rows.find(row => item.id === row.observation_matrix_id))
    },
    alreadyInCurrentMatrix () {
      return this.rows.filter(row => this.selectedMatrix.id === row.observation_matrix_id)
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
      loading: false,
      otuSelected: undefined
    }
  },
  watch: {
    otuId: {
      handler(newVal) {
        this.otuSelected = newVal
      },
      immediate: true
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
      ObservationMatrix.all().then(response => {
        this.matrices = response.body.sort((a, b) => { 
          const compareA = a.object_tag
          const compareB = b.object_tag
          if (compareA < compareB) {
            return -1
          } else if (compareA > compareB) {
            return 1
          } else {
            return 0
          }
        })
        this.loading = false
      })
      if (this.otuSelected) {
        ObservationMatrixRow.where({ otu_id: this.otuSelected }).then(response => {
          this.rows = response.body
        })
      }
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
          const promises = []

          if (!this.otuSelected) {
            promises.push(Otu.create({ otu: { taxon_name_id: this.taxonNameId } }).then(response => {
              this.otuSelected = response.body.id
            }))
          }
          Promise.all(promises).then(() => {
            const data = {
              observation_matrix_id: this.selectedMatrix.id,
              otu_id: this.otuSelected,
              type: 'ObservationMatrixRowItem::Single::Otu'
            }
            ObservationMatrixRowItem.create({ observation_matrix_row_item: data }).then(() => {
              ObservationMatrixRow.where({ otu_id: this.otuSelected }).then(response => {
                this.rows = response.body
                resolve(response)
              })
            })
          })
        }
      })
    },
    setMatrix (id) {
      ObservationMatrix.find(id).then(response => {
        this.selectedMatrix = response.body
        this.loadMatrix(this.selectedMatrix)
      })
    },
    openMatrixRowCoder () {
      if (this.alreadyInCurrentMatrix.length) {
        window.open(`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${this.alreadyInCurrentMatrix[0].id}`, '_blank')
        this.show = false
      } else {
        this.createRow().then(() => {
          window.open(`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${this.alreadyInCurrentMatrix[0].id}`, '_blank')
          this.show = false
        })
      }
    },
    openImageMatrix () {
      if (this.alreadyInCurrentMatrix.length) {
        window.open(`/tasks/matrix_image/matrix_image/index?observation_matrix_id=${this.selectedMatrix.id}&row_filter=${this.alreadyInCurrentMatrix[0].id}`, '_blank')
        this.show = false
      } else {
        this.createRow().then(() => {
          window.open(`/tasks/matrix_image/matrix_image/index?observation_matrix_id=${this.selectedMatrix.id}&row_filter=${this.alreadyInCurrentMatrix[0].id}`, '_blank')
          this.show = false
        })
      }
    }
  }
}
</script>

<style scoped>
  ::v-deep .modal-body {
    max-height: 80vh;
    overflow-y: scroll;
  }
  ::v-deep .modal-container {
    width: 800px;
  }
</style>
