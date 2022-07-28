<template>
  <div class="continuous-descriptor">
    <summary-view
      :index="index"
      :descriptor="descriptor"
      :row-object="rowObject"
    >
      <ContinousDescriptorObservation
        v-for="obs in observations"
        :key="obs.id || obs.internalId"
        class="margin-small-bottom"
        :observation="obs"
        :row-object="rowObject"
      />
      <v-btn
        color="primary"
        :disabled="!!emptyObservation"
        @click="addEmptyObservation"
      >
        Add observation
      </v-btn>
    </summary-view>
  </div>
</template>

<style lang="stylus" src="./ContinuousDescriptor.styl"></style>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import VBtn from 'components/ui/VBtn/index.vue'
import SummaryView from '../SummaryView/SummaryView.vue'
import ContinousDescriptorObservation from './ContinuousDescriptorObservation.vue'
import makeObservation from '../../helpers/makeObservation'
import ObservationTypes from '../../helpers/ObservationTypes'

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
    },

    rowObject: {
      type: Object,
      required: true
    }
  },

  computed: {
    observations () {
      return this.$store.getters[GetterNames.GetObservations].filter(o =>
        o.rowObjectId === this.rowObject.id &&
        o.rowObjectType === this.rowObject.type
      )
    },

    emptyObservation () {
      return this.observations.find(({ id }) => !id)
    }
  },

  methods: {
    addEmptyObservation () {
      const args = {
        type: ObservationTypes.Continuous,
        rowObjectType: this.rowObject.type,
        rowObjectId: this.rowObject.id,
        continuous_unit: this.descriptor.default_unit
      }

      this.$store.commit(MutationNames.AddObservation, makeObservation(args))
    }
  }
}
</script>
