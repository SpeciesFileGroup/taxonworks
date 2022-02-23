<template>
  <div class="continuous-descriptor">
    <summary-view
      :index="index"
      :descriptor="descriptor">
      <ContinousDescriptorObservation
        v-for="obs in observations"
        :key="obs.id || obs.internalId"
        class="margin-small-bottom"
        :observation="obs"
        :descriptor="descriptor"
      />
      <v-btn
        color="primary"
        @click="addEmptyObservation"
      >
        Add emtpy observation
      </v-btn>
    </summary-view>
  </div>
</template>

<style lang="stylus" src="./ContinuousDescriptor.styl"></style>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { ActionNames } from '../../store/actions/actions'
import VBtn from 'components/ui/VBtn/index.vue'
import SummaryView from '../SummaryView/SummaryView.vue'
import ContinousDescriptorObservation from './ContinuousDescriptorObservation.vue'
import makeObservation from '../../store/helpers/makeObservation'
import ObservationTypes from '../../store/helpers/ObservationTypes'

export default {
  name: 'continuous-descriptor',

  components: {
    SummaryView,
    VBtn,
    ContinousDescriptorObservation
  },

  props: {
    descriptor: {
      type: Object,
      required: true
    },

    index: {
      type: Number,
      required: true
    }
  },

  computed: {
    observations () {
      return this.$store.getters[GetterNames.GetObservations].filter(o => o.descriptorId === this.descriptor.id)
    }
  },

  created () {
    const descriptorId = this.descriptor.id
    const otuId = this.$store.state.taxonId

    this.$store.dispatch(ActionNames.RequestObservations, { descriptorId, otuId })
  },

  methods: {
    addEmptyObservation () {
      const args = {
        type: ObservationTypes.Continuous,
        descriptorId: this.descriptor.id,
        continuous_unit: this.descriptor.default_unit
      }

      this.$store.commit(MutationNames.AddObservation, makeObservation(args))
    }
  }
}
</script>
