import { GetterNames } from '../store/getters/getters'

export default {
  computed: {
    observationMatrix () {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    }
  }
}
