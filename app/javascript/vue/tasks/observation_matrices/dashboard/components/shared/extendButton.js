import { ObservationMatrix } from 'routes/endpoints'
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
}