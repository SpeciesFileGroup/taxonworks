import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'

import SummaryView from '../SummaryView/SummaryView.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'

export default {
  components: {
    SummaryView,
    RadialAnnotator
  },

  props: {
    descriptor: {
      type: Object,
      required: true
    }
  },

  data () {
    return {
      observation: null
    }
  },

  computed: {
    observationExist () {
      return (this.observation && this.observation.global_id)
    }
  },

  created () {
    const descriptorId = this.$props.descriptor.id
    const otuId = this.$store.state.taxonId

    this.$store.dispatch(ActionNames.RequestObservations, { descriptorId, otuId })
      .then(_ => {
        const observations = this.$store.getters[GetterNames.GetObservationsFor](descriptorId)
        if (observations.length > 1) {
          console.log(observations)
          throw 'This descriptor cannot have more than one observation!'
        } else if (observations.length === 1) {
          const observation = observations[0]
          this.observation = observation
        }
      })
  },

  methods: {
    removeObservation () {
      this.$store.dispatch(ActionNames.RemoveObservation, { descriptorId: this.descriptor.id })
    }
  }
}
