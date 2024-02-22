import { GetterNames } from '../store/getters/getters'
import SpinnerComponent from '@/components/ui/VSpinner'

export default {
  components: { SpinnerComponent },

  computed: {
    observationMatrix() {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    },

    isLoading() {
      return this.$store.getters[GetterNames.GetSettings].isRefreshing
    }
  }
}
