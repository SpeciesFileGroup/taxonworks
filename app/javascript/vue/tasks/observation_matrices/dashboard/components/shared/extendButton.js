import { ObservationMatrix, ObservationMatrixRowItem } from 'routes/endpoints'
import ModalComponent from 'components/ui/Modal.vue'
import SpinnerComponent from 'components/spinner.vue'
import PinComponent from 'components/getDefaultPin.vue'

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

  data () {
    return {
      isLoading: false,
      showModal: false,
      observationMatrices: [],
      matrixObservationRows: [],
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
    addRows (matrixId) {
      const promises = []
      const data = this.otuIds.map(id => ({
        observation_matrix_id: matrixId,
        otu_id: id,
        type: 'ObservationMatrixRowItem::Single::Otu'
      }))

      data.forEach(row => {
        if (!this.matrixObservationRows.find(item =>
          row.otu_id === item.otu_id &&
          item.observation_matrix_id === row.observation_matrix_id)
        ) {
          promises.push(ObservationMatrixRowItem.create({ observation_matrix_row_item: row }))
        }
      })

      Promise.allSettled(promises).then(() => {
        if (promises.length) {
          TW.workbench.alert.create('Rows was successfully added to matrix.', 'notice')
        }
        this.$emit('onCreate', { matrixId, otuIds: this.otuIds })
        this.closeModal()
      })
    },

    closeModal () {
      this.showModal = false
    },

    isAlreadyInMatrix (matrixId) {
      const matrixRows = this.matrixObservationRows.filter(row => row.observation_matrix_id === matrixId)

      return matrixRows.length === this.otuIds.length
    }
  }
}