<template>
  <div class="sample-descriptor">
    <summary-view
      :descriptor="descriptor"
      :index="index"
    >
      <div>
        <template
          v-for="o in observations"
          :key="o.id || o.internalId">
          <SampleDescriptorObservation
            :observation="o"
            :descriptor="descriptor"
          />
          <hr>
        </template>
      </div>
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

<style src="./SampleDescriptor.styl" lang="stylus"></style>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { ActionNames } from '../../store/actions/actions'
import SampleDescriptorObservation from './SampleDescriptorObservation.vue'
import ObservationTypes from '../../store/helpers/ObservationTypes'
import makeObservation from '../../store/helpers/makeObservation'
import VBtn from 'components/ui/VBtn/index.vue'
import SummaryView from '../SummaryView/SummaryView.vue'

export default {
  name: 'SampleDescriptor',

  components: {
    SampleDescriptorObservation,
    SummaryView,
    VBtn
  },

  props: {
    index: {
      type: Number,
      required: true
    },

    descriptor: {
      type: Object,
      required: true
    }
  },

  computed: {
    observations () {
      return this.$store.getters[GetterNames.GetObservations].filter(o => o.descriptorId === this.descriptor.id)
    },

    emptyObservation () {
      return this.observations.find(({ id }) => !id)
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
        type: ObservationTypes.Sample,
        descriptorId: this.descriptor.id,
        default_unit: this.descriptor.default_unit
      }

      this.$store.commit(MutationNames.AddObservation, makeObservation(args))
    }
  }
}
</script>
