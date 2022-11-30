<template>
  <div>
    <h3>Select observation matrix to open MRC or Image matrix</h3>
    <div>
      <spinner-component
        v-if="loading"
        legend="Loading"
      />
      <div>
        <div
          class="separate-bottom horizontal-left-content"
        >
          <input
            v-model="filterType"
            type="text"
            placeholder="Filter matrix"
          >
          <default-pin
            section="ObservationMatrices"
            type="ObservationMatrix"
            @get-id="setMatrix"
          />
        </div>
        <div class="flex-separate">
          <div>
            <ul class="no_bullets">
              <template v-for="item in alreadyInMatrices">
                <li
                  :key="item.id"
                  v-if="item.object_tag.toLowerCase().includes(filterType.toLowerCase())"
                >
                  <button
                    class="button normal-input button-default margin-small-bottom"
                    @click="loadMatrix(item)"
                    v-html="item.object_tag"
                  />
                </li>
              </template>
            </ul>
            <ul class="no_bullets">
              <template v-for="item in matrices">
                <li
                  :key="item.id"
                  v-if="item.object_tag.toLowerCase().includes(filterType.toLowerCase()) && !alreadyInMatrices.includes(item)"
                >
                  <button
                    class="button normal-input button-submit margin-small-bottom"
                    @click="loadMatrix(item)"
                    v-html="item.object_tag"
                  />
                </li>
              </template>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import CRUD from '../../request/crud'
import annotatorExtend from '../annotatorExtend'
import SpinnerComponent from 'components/spinner'
import DefaultPin from 'components/getDefaultPin'
import { ObservationMatrix, ObservationMatrixRow, ObservationMatrixRowItem } from 'routes/endpoints'
import { OBSERVATION_MATRIX_ROW_SINGLE } from 'constants/index'

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    DefaultPin,
    SpinnerComponent
  },

  emits: [
    'updateCount',
    'close'
  ],

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
      filterType: '',
      loading: false,
      otuSelected: undefined,
      loadOnMounted: false
    }
  },

  watch: {
    alreadyInMatrices (newVal) {
      this.$emit('updateCount', newVal.length)
    }
  },

  mounted () {
    this.loading = true
    this.show = true
    ObservationMatrix.all({ per: 500 }).then(response => {
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
    ObservationMatrixRow.where({
      observation_object_type: this.metadata.object_type,
      observation_object_id: this.metadata.object_id
    }).then(response => {
      this.rows = response.body
    })
  },

  methods: {
    loadMatrix (matrix) {
      this.selectedMatrix = matrix
      if (matrix.is_media_matrix) {
        this.openImageMatrix(matrix.id)
      } else {
        this.openMatrixRowCoder(matrix.id)
      }
    },

    reset () {
      this.selectedMatrix = undefined
      this.rows = []
      this.show = false
    },

    async createRow () {
      const data = {
        observation_matrix_id: this.selectedMatrix.id,
        observation_object_type: this.metadata.object_type,
        observation_object_id: this.metadata.object_id,
        type: OBSERVATION_MATRIX_ROW_SINGLE
      }

      await ObservationMatrixRowItem.create({ observation_matrix_row_item: data })

      const rowList = (await ObservationMatrixRow.where({
        observation_object_id: this.metadata.object_id,
        observation_object_type: this.metadata.object_type
      }))

      this.rows = rowList.body

      return rowList
    },

    setMatrix (id) {
      ObservationMatrix.find(id).then(response => {
        this.selectedMatrix = response.body
        this.loadMatrix(this.selectedMatrix)
      })
    },

    getRowId (observationMatrixId) {
      return this.rows.find(m => m.observation_matrix_id === observationMatrixId).id
    },

    openMatrixRowCoder (observationMatrixId) {
      if (this.alreadyInCurrentMatrix.length) {
        window.open(`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${this.getRowId(observationMatrixId)}`, '_blank')
        this.$emit('close')
      } else {
        this.createRow().then(_ => {
          window.open(`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${this.getRowId(observationMatrixId)}`, '_blank')
          this.$emit('close')
        })
      }
    },

    openImageMatrix (observationMatrixId) {
      if (this.alreadyInCurrentMatrix.length) {
        window.open(`/tasks/matrix_image/matrix_image/index?observation_matrix_id=${this.selectedMatrix.id}&row_filter=${this.getRowId(observationMatrixId)}&edit=true`, '_blank')
        this.$emit('close')
      } else {
        this.createRow().then(() => {
          window.open(`/tasks/matrix_image/matrix_image/index?observation_matrix_id=${this.selectedMatrix.id}&row_filter=${this.getRowId(observationMatrixId)}&edit=true`, '_blank')
          this.$emit('close')
        })
      }
    }
  }
}
</script>
