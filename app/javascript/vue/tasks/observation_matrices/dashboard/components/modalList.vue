<template>
  <div>
    <button
      type="button"
      class="button normal-input button-submit"
      :class="{ 'button-default': otuSelected }"
      @click="openModal"
    >
      Open in matrix
    </button>
    <modal-component
      v-if="show"
      @close="reset"
    >
      <template #header>
        <h3>Select observation matrix to open MRC or Image matrix</h3>
      </template>
      <template #body>
        <spinner-component
          v-if="loading"
          legend="Loading"
        />
        <div>
          <h3 v-if="!otuSelected">OTU will be created for this taxon name</h3>
          <div class="separate-bottom horizontal-left-content">
            <input
              v-model="filterType"
              type="text"
              placeholder="Filter matrix"
            />
            <default-pin
              section="ObservationMatrices"
              type="ObservationMatrix"
              @getId="setMatrix"
            />
          </div>
          <div class="flex-separate">
            <div>
              <ul class="no_bullets">
                <template
                  v-for="item in alreadyInMatrices"
                  :key="item.id"
                >
                  <li
                    v-if="
                      item.object_tag
                        .toLowerCase()
                        .includes(filterType.toLowerCase())
                    "
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
                <template
                  v-for="item in matrices"
                  :key="item.id"
                >
                  <li
                    v-if="
                      item.object_tag
                        .toLowerCase()
                        .includes(filterType.toLowerCase()) &&
                      !alreadyInMatrices.includes(item)
                    "
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
      </template>
    </modal-component>
  </div>
</template>

<script>
import ModalComponent from '@/components/ui/Modal'
import SpinnerComponent from '@/components/ui/VSpinner'
import DefaultPin from '@/components/ui/Button/ButtonPinned'
import {
  ObservationMatrix,
  ObservationMatrixRow,
  ObservationMatrixRowItem,
  Otu
} from '@/routes/endpoints'
import { OBSERVATION_MATRIX_ROW_SINGLE, OTU } from '@/constants/index.js'
import { RouteNames } from '@/routes/routes'

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
    alreadyInMatrices() {
      return this.matrices.filter((item) =>
        this.rows.find((row) => item.id === row.observation_matrix_id)
      )
    },

    alreadyInCurrentMatrix() {
      return this.rows.filter(
        (row) => this.selectedMatrix.id === row.observation_matrix_id
      )
    }
  },

  data() {
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
    loadMatrix(matrix) {
      this.selectedMatrix = matrix
      if (matrix.is_media_matrix) {
        this.openImageMatrix()
      } else {
        this.openMatrixRowCoder()
      }
    },

    openModal() {
      this.loading = true
      this.show = true
      ObservationMatrix.all({ per: 500 }).then((response) => {
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
        ObservationMatrixRow.where({
          observation_object_type: OTU,
          observation_object_id: this.otuSelected
        }).then((response) => {
          this.rows = response.body
        })
      }
    },

    reset() {
      this.selectedMatrix = undefined
      this.rows = []
      this.create = false
      this.show = false
    },

    createRow() {
      return new Promise((resolve, reject) => {
        if (
          window.confirm(
            'Are you sure you want to add this otu to this matrix?'
          )
        ) {
          const promises = []

          if (!this.otuSelected) {
            promises.push(
              Otu.create({ otu: { taxon_name_id: this.taxonNameId } }).then(
                (response) => {
                  this.otuSelected = response.body.id
                }
              )
            )
          }
          Promise.all(promises).then(() => {
            const data = {
              observation_matrix_id: this.selectedMatrix.id,
              observation_object_id: this.otuSelected,
              observation_object_type: OTU,
              type: OBSERVATION_MATRIX_ROW_SINGLE
            }

            ObservationMatrixRowItem.create({
              observation_matrix_row_item: data
            }).then(() => {
              ObservationMatrixRow.where({
                observation_object_type: OTU,
                observation_object_id: this.otuSelected
              }).then((response) => {
                this.rows = response.body
                resolve(response)
              })
            })
          })
        }
      })
    },

    setMatrix(id) {
      ObservationMatrix.find(id).then((response) => {
        this.selectedMatrix = response.body
        this.loadMatrix(this.selectedMatrix)
      })
    },

    openMatrixRowCoder() {
      if (this.alreadyInCurrentMatrix.length) {
        window.open(
          `/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${this.alreadyInCurrentMatrix[0].id}`,
          '_blank'
        )
        this.show = false
      } else {
        this.createRow().then(() => {
          window.open(
            `/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${this.alreadyInCurrentMatrix[0].id}`,
            '_blank'
          )
          this.show = false
        })
      }
    },

    openImageMatrix() {
      if (this.alreadyInCurrentMatrix.length) {
        window.open(
          `${RouteNames.ImageMatrix}?observation_matrix_id=${this.selectedMatrix.id}&edit=true&row_filter=${this.alreadyInCurrentMatrix[0].id}`,
          '_blank'
        )
        this.show = false
      } else {
        this.createRow().then(() => {
          window.open(
            `${RouteNames.ImageMatrix}?observation_matrix_id=${this.selectedMatrix.id}&edit=true&row_filter=${this.alreadyInCurrentMatrix[0].id}`,
            '_blank'
          )
          this.show = false
        })
      }
    }
  }
}
</script>

<style scoped>
:deep(.modal-body) {
  max-height: 80vh;
  overflow-y: scroll;
}
:deep(.modal-container) {
  width: 800px;
}
</style>
