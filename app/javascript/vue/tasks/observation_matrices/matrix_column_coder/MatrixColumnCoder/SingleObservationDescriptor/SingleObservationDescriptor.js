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
    index: {
      type: Number,
      required: true
    },

    rowObject: {
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
    const observations = this.$store.getters[GetterNames.GetObservationsFor]({
      rowObjectId: this.rowObject.id,
      rowObjectType: this.rowObject.type
    })

    if (observations.length > 1) {
      throw 'This descriptor cannot have more than one observation!'
    } else if (observations.length === 1) {
      const observation = observations[0]
      this.observation = observation
    }
  },

  methods: {
    removeObservation () {
      this.$store.dispatch(ActionNames.RemoveObservation, {
        rowObjectId: this.rowObject.id,
        rowObjectType: this.rowObject.type
      })
    }
  }
}
