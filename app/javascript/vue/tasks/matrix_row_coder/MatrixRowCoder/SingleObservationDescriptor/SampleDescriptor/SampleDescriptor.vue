<template>
  <div class="sample-descriptor">
    <summary-view
      :descriptor="descriptor"
      :index="index">
      <div class="horizontal-left-content">
        <label class="separate-right">
          Min:
          <input type="number" size="8" :value="sampleMin" @input="updateSampleMin">
        </label>
        <label
          class="separate-left">
          Max:
          <input type="number" size="8" :value="sampleMax" @input="updateSampleMax">
        </label>
        <unit-selector v-model="sampleUnit"/>

        <label class="separate-left">
          n:
          <input type="number" size="8" :value="sampleN" @input="updateSampleN">
        </label>
        <radial-annotator 
          v-if="observationExist"
          :global-id="observation.global_id"/>
        <span
          v-if="observationExist"
          type="button"
          class="circle-button btn-delete"
          @click="removeObservation">
          Remove
        </span>
      </div>
      <div class="separate-top">
        <label class="separate-right">
          Mean:
          <input type="text" size="8" v-model="sampleMean">
        </label>
        <label class="separate-right">
          Median:
          <input type="text" size="8" v-model="sampleMedian">
        </label>
        <label class="separate-right">
          Standard deviation:
          <input type="text" size="8" v-model="sampleStandardDeviation">
        </label>
        <label class="separate-right">
          Standard error:
          <input type="text" size="8" v-model="sampleStandardError">
        </label>
      </div>
    </summary-view>

    <single-observation-zoomed-view
      :descriptor="descriptor"
      :observation="observation">

      <p>
        <label>
          Min:
          <input type="number" :value="sampleMin" @input="updateSampleMin">
        </label>
      </p>
      <p>
        to
      </p>
      <p>
        <label>
          Max:
          <input type="number" :value="sampleMax" @input="updateSampleMax">
        </label>
      </p>
      <p>
        <unit-selector v-model="sampleUnit"/>
      </p>

      <p>
        <label>
          n:
          <input type="number" :value="sampleN" @input="updateSampleN">
        </label>
      </p>
    </single-observation-zoomed-view>
  </div>
</template>

<style src="./SampleDescriptor.styl" lang="stylus"></style>

<script>
import SingleObservationDescriptor from '../SingleObservationDescriptor'
import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'
import UnitSelector from '../../UnitSelector/UnitSelector.vue'

export default {
  mixins: [SingleObservationDescriptor],
  name: 'SampleDescriptor',
  props: ['index'],
  computed: {
    sampleMin () {
      return this.$store.getters[GetterNames.GetSampleMinFor](this.$props.descriptor.id)
    },
    sampleMax () {
      return this.$store.getters[GetterNames.GetSampleMaxFor](this.$props.descriptor.id)
    },
    sampleN () {
      return this.$store.getters[GetterNames.GetSampleNFor](this.$props.descriptor.id)
    },
    sampleUnit: {
      get () {
        return this.$store.getters[GetterNames.GetSampleUnitFor](this.$props.descriptor.id)
      },
      set (unit) {
        this.$store.commit(MutationNames.SetSampleUnitFor, {
          descriptorId: this.$props.descriptor.id,
          units: unit
        })
      }
    },
    sampleMean: {
      get() {
        return this.$store.getters[GetterNames.GetSampleStandardMean](this.$props.descriptor.id)
      },
      set (value) {
        this.$store.commit(MutationNames.SetSampleStandardMean, {
          descriptorId: this.$props.descriptor.id,
          mean: value
        })
      }

    },
    sampleMedian: {
      get () {
        return this.$store.getters[GetterNames.GetSampleMedian](this.$props.descriptor.id)
      },
      set (value) {
        this.$store.commit(MutationNames.SetSampleMedian, {
          descriptorId: this.$props.descriptor.id,
          median: value
        })
      }
    },
    sampleStandardDeviation: {
      get () {
        return this.$store.getters[GetterNames.GetSampleStandardDeviation](this.$props.descriptor.id)
      },
      set (value) {
        this.$store.commit(MutationNames.SetSampleStandardDeviation, {
          descriptorId: this.$props.descriptor.id,
          standardDeviation: value
        })
      }
    },
    sampleStandardError: {
      get() {
        return this.$store.getters[GetterNames.GetSampleStandardError](this.$props.descriptor.id)
      },
      set (value) {
        this.$store.commit(MutationNames.SetSampleStandardError, {
          descriptorId: this.$props.descriptor.id,
          standardError: value
        })
      }
    }
  },
  methods: {
    updateSampleMin (event) {
      this.$store.commit(MutationNames.SetSampleMinFor, {
        descriptorId: this.$props.descriptor.id,
        min: event.target.value
      })
    },
    updateSampleMax (event) {
      this.$store.commit(MutationNames.SetSampleMaxFor, {
        descriptorId: this.$props.descriptor.id,
        max: event.target.value
      })
    },
    updateSampleN (event) {
      this.$store.commit(MutationNames.SetSampleNFor, {
        descriptorId: this.$props.descriptor.id,
        n: event.target.value
      })
    }
  },
  components: {
    UnitSelector
  }
}
</script>
