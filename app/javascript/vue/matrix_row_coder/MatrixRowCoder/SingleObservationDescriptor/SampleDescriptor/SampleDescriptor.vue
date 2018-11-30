<template>
  <div class="sample-descriptor">
    <summary-view :descriptor="descriptor">
      <div class="horizontal-left-content">
        <label>
          Min:
          <input type="number" :value="sampleMin" @input="updateSampleMin">
        </label>
        to
        <label
          class="separate-left">
          Max:
          <input type="number" :value="sampleMax" @input="updateSampleMax">
        </label>
        <unit-selector v-model="sampleUnit"/>

        <label>
          n:
          <input type="number" :value="sampleN" @input="updateSampleN">
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
