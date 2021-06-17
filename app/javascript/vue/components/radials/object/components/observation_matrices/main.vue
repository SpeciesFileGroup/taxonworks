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
            @getId="setMatrix"
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
      loadOnMounted: false,
      types: {
        Otu: {
          propertyName: 'otu_id',
          type: 'ObservationMatrixRowItem::Single::Otu'
        },
        CollectionObject: {
          propertyName: 'collection_object_id',
          type: 'ObservationMatrixRowItem::Single::CollectionObject'
        }
      }
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
    ObservationMatrixRow.where({ [this.types[this.metadata.object_type].propertyName]: this.metadata.object_id }).then(response => {
      this.rows = response.body
    })
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

    reset () {
      this.selectedMatrix = undefined
      this.rows = []
      this.show = false
    },

    createRow () {
      return new Promise((resolve, reject) => {
        if (window.confirm(`Are you sure you want to add this ${this.metadata.object_type} to this matrix?`)) {
          const data = {
            observation_matrix_id: this.selectedMatrix.id,
            [this.types[this.metadata.object_type].propertyName]: this.metadata.object_id,
            type: this.types[this.metadata.object_type].type
          }
          ObservationMatrixRowItem.create({ observation_matrix_row_item: data }).then(response => {
            ObservationMatrixRow.where({ [this.types[this.metadata.object_type].propertyName]: this.metadata.object_id }).then(response => {
              this.rows = response.body
              resolve(response)
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
        this.$emit('close')
      } else {
        this.createRow().then(() => {
          window.open(`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${this.alreadyInCurrentMatrix[0].id}`, '_blank')
          this.$emit('close')
        })
      }
    },

    openImageMatrix () {
      if (this.alreadyInCurrentMatrix.length) {
        window.open(`/tasks/matrix_image/matrix_image/index?observation_matrix_id=${this.selectedMatrix.id}&row_filter=${this.alreadyInCurrentMatrix[0].id}`, '_blank')
        this.$emit('close')
      } else {
        this.createRow().then(() => {
          window.open(`/tasks/matrix_image/matrix_image/index?observation_matrix_id=${this.selectedMatrix.id}&row_filter=${this.alreadyInCurrentMatrix[0].id}`, '_blank')
          this.$emit('close')
        })
      }
    }
  }
}
</script>
