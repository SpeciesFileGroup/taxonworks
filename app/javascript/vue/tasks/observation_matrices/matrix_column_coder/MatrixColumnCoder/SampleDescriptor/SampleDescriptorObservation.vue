<template>
  <div class="sample-descriptor">
    <div class="horizontal-left-content margin-small-bottom">
      <label class="separate-right">
        Min:
        <input
          type="number"
          size="8"
          v-model="sampleMin"
        >
      </label>
      <label class="separate-left">
        Max:
        <input
          type="number"
          size="8"
          v-model="sampleMax"
        >
      </label>

      <unit-selector v-model="sampleUnit" />

      <label class="separate-left">
        n:
        <input
          type="number"
          size="8"
          v-model="sampleN"
        >
      </label>
      <template v-if="observation.id">
        <radial-annotator :global-id="observation.global_id" />
        <v-btn
          circle
          color="destroy"
          @click="removeObservation"
        >
          <v-icon
            name="trash"
            x-small
          />
        </v-btn>
      </template>
    </div>

    <div class="margin-small-bottom">
      <label class="separate-right">
        Mean:
        <input
          type="text"
          size="8"
          v-model="sampleMean"
        >
      </label>
      <label class="separate-right">
        Median:
        <input
          type="text"
          size="8"
          v-model="sampleMedian"
        >
      </label>
      <label class="separate-right">
        Standard deviation:
        <input
          type="text"
          size="8"
          v-model="sampleStandardDeviation"
        >
      </label>
      <label class="separate-right">
        Standard error:
        <input
          type="text"
          size="8"
          v-model="sampleStandardError"
        >
      </label>
    </div>
    <div>
      <TimeFields
        inline
        :row-object="rowObject"
        :observation="observation"
      />
    </div>
  </div>
</template>

<script>
import { MutationNames } from '../../store/mutations/mutations'
import { ActionNames } from '../../store/actions/actions'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import UnitSelector from '../UnitSelector/UnitSelector.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import TimeFields from '../Time/TimeFields.vue'

export default {
  name: 'SampleDescriptorObservation',

  components: {
    RadialAnnotator,
    UnitSelector,
    TimeFields,
    VBtn,
    VIcon
  },

  props: {
    observation: {
      type: Object,
      required: true
    },

    rowObject: {
      type: Object,
      required: true
    }
  },

  computed: {
    sampleMin: {
      get () {
        return this.observation.min
      },

      set (value) {
        this.$store.commit(MutationNames.SetSampleMinFor, {
          rowObjectId: this.rowObject.id,
          rowObjectType: this.rowObject.type,
          observationId: this.observation.id || this.observation.internalId,
          min: value
        })
      }
    },

    sampleMax: {
      get () {
        return this.observation.max
      },

      set (value) {
        this.$store.commit(MutationNames.SetSampleMaxFor, {
          rowObjectId: this.rowObject.id,
          rowObjectType: this.rowObject.type,
          observationId: this.observation.id || this.observation.internalId,
          max: value
        })
      }
    },

    sampleN: {
      get () {
        return this.observation.n
      },

      set (value) {
        this.$store.commit(MutationNames.SetSampleNFor, {
          rowObjectId: this.rowObject.id,
          rowObjectType: this.rowObject.type,
          observationId: this.observation.id || this.observation.internalId,
          n: value
        })
      }
    },

    sampleUnit: {
      get () {
        return this.observation.units
      },

      set (unit) {
        this.$store.commit(MutationNames.SetSampleUnitFor, {
          rowObjectId: this.rowObject.id,
          rowObjectType: this.rowObject.type,
          observationId: this.observation.id || this.observation.internalId,
          units: unit
        })
      }
    },

    sampleMean: {
      get () {
        return this.observation.mean
      },

      set (value) {
        this.$store.commit(MutationNames.SetSampleStandardMean, {
          rowObjectId: this.rowObject.id,
          rowObjectType: this.rowObject.type,
          observationId: this.observation.id || this.observation.internalId,
          mean: value
        })
      }

    },

    sampleMedian: {
      get () {
        return this.observation.median
      },

      set (value) {
        this.$store.commit(MutationNames.SetSampleMedian, {
          rowObjectId: this.rowObject.id,
          rowObjectType: this.rowObject.type,
          observationId: this.observation.id || this.observation.internalId,
          median: value
        })
      }
    },

    sampleStandardDeviation: {
      get () {
        return this.observation.standardDeviation
      },

      set (value) {
        this.$store.commit(MutationNames.SetSampleStandardDeviation, {
          rowObjectId: this.rowObject.id,
          rowObjectType: this.rowObject.type,
          observationId: this.observation.id || this.observation.internalId,
          standardDeviation: value
        })
      }
    },

    sampleStandardError: {
      get () {
        return this.observation.standardError
      },

      set (value) {
        this.$store.commit(MutationNames.SetSampleStandardError, {
          rowObjectId: this.rowObject.id,
          rowObjectType: this.rowObject.type,
          observationId: this.observation.id || this.observation.internalId,
          standardError: value
        })
      }
    }
  },

  methods: {
    removeObservation () {
      this.$store.dispatch(ActionNames.RemoveObservation, {
        rowObjectId: this.rowObject.id,
        rowObjectType: this.rowObject.type,
        obsId: this.observation.id
      })
    }
  }
}
</script>
