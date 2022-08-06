<template>
  <div class="sample-descriptor">
    <summary-view
      :row-object="rowObject"
      :index="index"
    >
      <div>
        <template
          v-for="o in observations"
          :key="o.id || o.internalId"
        >
          <SampleDescriptorObservation
            :observation="o"
            :row-object="rowObject"
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

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import SampleDescriptorObservation from './SampleDescriptorObservation.vue'
import ObservationTypes from '../../helpers/ObservationTypes'
import makeObservation from '../../helpers/makeObservation'
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
        type: ObservationTypes.Sample,
        rowObjectId: this.rowObject.id,
        rowObjectType: this.rowObject.type,
        default_unit: this.descriptor.default_unit
      }

      this.$store.commit(MutationNames.AddObservation, makeObservation(args))
    }
  }
}
</script>
