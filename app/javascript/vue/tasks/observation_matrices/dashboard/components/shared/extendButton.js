import { ObservationMatrix, ObservationMatrixRowItem } from '@/routes/endpoints'
import { sortArray } from '@/helpers/arrays'
import { OTU, OBSERVATION_MATRIX_ROW_SINGLE } from '@/constants/index.js'
import ModalComponent from '@/components/ui/Modal.vue'
import SpinnerComponent from '@/components/spinner.vue'
import PinComponent from '@/components/getDefaultPin.vue'

export default {
  components: {
    ModalComponent,
    SpinnerComponent,
    PinComponent
  },

  props: {
    otuIds: {
      type: Array,
      required: true,
      default: () => []
    }
  },

  emits: ['onCreate'],

  data() {
    return {
      isLoading: false,
      showModal: false,
      observationMatrices: [],
      matrixObservationRows: [],
      matrix: undefined
    }
  },

  computed: {
    matrixWithRows() {
      return sortArray(
        this.observationMatrices.filter((matrix) =>
          this.isAlreadyInMatrix(matrix.id)
        ),
        'name'
      )
    },

    matrixWithoutRows() {
      return sortArray(
        this.observationMatrices.filter(
          (matrix) => !this.isAlreadyInMatrix(matrix.id)
        ),
        'name'
      )
    }
  },

  watch: {
    showModal: {
      handler(newVal) {
        if (newVal) {
          this.isLoading = true
          ObservationMatrix.all().then((response) => {
            this.observationMatrices = sortArray(response.body, 'name', true)
            this.isLoading = false
          })
        }
      },
      immediate: true
    }
  },

  methods: {
    addRows(matrixId) {
      const promises = []
      const data = this.otuIds.map((id) => ({
        observation_matrix_id: matrixId,
        observation_object_id: id,
        observation_object_type: OTU,
        type: OBSERVATION_MATRIX_ROW_SINGLE
      }))

      data.forEach((row) => {
        if (
          !this.matrixObservationRows.find(
            (item) =>
              row.otu_id === item.otu_id &&
              item.observation_matrix_id === row.observation_matrix_id
          )
        ) {
          promises.push(
            ObservationMatrixRowItem.create({
              observation_matrix_row_item: row
            })
          )
        }
      })

      Promise.allSettled(promises).then(() => {
        if (promises.length) {
          TW.workbench.alert.create(
            'Rows was successfully added to matrix.',
            'notice'
          )
        }
        this.$emit('onCreate', { matrixId, otuIds: this.otuIds })
        this.closeModal()
      })
    },

    closeModal() {
      this.showModal = false
    },

    isAlreadyInMatrix(matrixId) {
      const matrixRows = this.matrixObservationRows.filter(
        (row) => row.observation_matrix_id === matrixId
      )

      return matrixRows.length === this.otuIds.length
    }
  }
}
