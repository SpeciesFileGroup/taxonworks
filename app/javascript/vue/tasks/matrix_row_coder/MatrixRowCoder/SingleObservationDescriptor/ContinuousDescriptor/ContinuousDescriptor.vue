<template>
  <div class="continuous-descriptor">
    <summary-view
    :index="index"
    :descriptor="descriptor">
      <div class="horizontal-left-content">
        <label>
          Amount:
          <input type="number" :value="continuousValue" @input="updateContinuousValue">
        </label>
        <unit-selector v-model="continuousUnit"/>
        <template v-if="observationExist">
          <radial-annotator 
            :global-id="observation.global_id"/>
        </template>
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
          Amount:
          <input type="number" :value="continuousValue" @input="updateContinuousValue">
        </label>
      </p>
      <p>
        <unit-selector v-model="continuousUnit"/>
      </p>
    </single-observation-zoomed-view>
  </div>
</template>

<style lang="stylus" src="./ContinuousDescriptor.styl"></style>

<script>
import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'
import SingleObservationDescriptor from '../SingleObservationDescriptor'
import UnitSelector from '../../UnitSelector/UnitSelector.vue'

export default {
  mixins: [SingleObservationDescriptor],
  name: 'continuous-descriptor',
  props: ['index'],
  computed: {
    continuousValue: function () {
      return this.$store.getters[GetterNames.GetContinuousValueFor](this.$props.descriptor.id)
    },
    continuousUnit: {
      get () {
        return this.$store.getters[GetterNames.GetContinuousUnitFor](this.$props.descriptor.id)
      },
      set (unit) {
        this.$store.commit(MutationNames.SetContinuousUnit, {
          descriptorId: this.$props.descriptor.id,
          continuousUnit: unit
        })
      }
    }
  },
  methods: {
    updateContinuousValue (event) {
      this.$store.commit(MutationNames.SetContinuousValue, {
        descriptorId: this.$props.descriptor.id,
        continuousValue: event.target.value
      })
    },
  },
  components: {
    UnitSelector,
  }
}
</script>
