<template>
  <div class="sample-descriptor">
    <div class="horizontal-left-content margin-small-bottom gap-small">
      <label>
        Min:
        <input
          type="number"
          size="8"
          v-model="sampleMin"
        />
      </label>
      <label>
        Max:
        <input
          type="number"
          size="8"
          v-model="sampleMax"
        />
      </label>

      <unit-selector v-model="sampleUnit" />

      <label>
        n:
        <input
          type="number"
          size="8"
          v-model="sampleN"
        />
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

    <div class="horizontal-left-content gap-small margin-small-bottom">
      <label>
        Mean:
        <input
          type="text"
          size="8"
          v-model="sampleMean"
        />
      </label>
      <label>
        Median:
        <input
          type="text"
          size="8"
          v-model="sampleMedian"
        />
      </label>
      <label>
        Standard deviation:
        <input
          type="text"
          size="8"
          v-model="sampleStandardDeviation"
        />
      </label>
      <label>
        Standard error:
        <input
          type="text"
          size="8"
          v-model="sampleStandardError"
        />
      </label>
    </div>
    <div>
      <TimeFields
        inline
        :descriptor="descriptor"
        :observation="observation"
      />
    </div>
  </div>
</template>

<style src="./SampleDescriptor.scss" lang="scss"></style>

<script>
import { MutationNames } from '../../store/mutations/mutations'
import { ActionNames } from '../../store/actions/actions'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import UnitSelector from '../UnitSelector/UnitSelector.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
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
    descriptor: {
      type: Object,
      required: true
    },

    observation: {
      type: Object,
      required: true
    }
  },

  computed: {
    sampleMin: {
      get() {
        return this.observation.min
      },

      set(value) {
        this.$store.commit(MutationNames.SetSampleMinFor, {
          descriptorId: this.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          min: value
        })
      }
    },

    sampleMax: {
      get() {
        return this.observation.max
      },

      set(value) {
        this.$store.commit(MutationNames.SetSampleMaxFor, {
          descriptorId: this.$props.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          max: value
        })
      }
    },

    sampleN: {
      get() {
        return this.observation.n
      },

      set(value) {
        this.$store.commit(MutationNames.SetSampleNFor, {
          descriptorId: this.$props.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          n: value
        })
      }
    },

    sampleUnit: {
      get() {
        return this.observation.units
      },

      set(unit) {
        this.$store.commit(MutationNames.SetSampleUnitFor, {
          descriptorId: this.$props.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          units: unit
        })
      }
    },

    sampleMean: {
      get() {
        return this.observation.mean
      },

      set(value) {
        this.$store.commit(MutationNames.SetSampleStandardMean, {
          descriptorId: this.$props.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          mean: value
        })
      }
    },

    sampleMedian: {
      get() {
        return this.observation.median
      },

      set(value) {
        this.$store.commit(MutationNames.SetSampleMedian, {
          descriptorId: this.$props.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          median: value
        })
      }
    },

    sampleStandardDeviation: {
      get() {
        return this.observation.standardDeviation
      },

      set(value) {
        this.$store.commit(MutationNames.SetSampleStandardDeviation, {
          descriptorId: this.$props.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          standardDeviation: value
        })
      }
    },

    sampleStandardError: {
      get() {
        return this.observation.standardError
      },

      set(value) {
        this.$store.commit(MutationNames.SetSampleStandardError, {
          descriptorId: this.$props.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          standardError: value
        })
      }
    }
  },

  methods: {
    removeObservation() {
      this.$store.dispatch(ActionNames.RemoveObservation, {
        descriptorId: this.descriptor.id,
        obsId: this.observation.id
      })
    }
  }
}
</script>
