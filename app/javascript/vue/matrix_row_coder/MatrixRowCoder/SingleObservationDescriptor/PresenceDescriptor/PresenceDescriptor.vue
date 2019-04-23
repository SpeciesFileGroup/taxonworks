<template>
  <div class="presence-descriptor">
    <summary-view
      :descriptor="descriptor"
      :index="index">
      <div class="horizontal-left-content">
        <label>
          Present
          <input type="checkbox" :checked="isPresent" @change="updatePresence" >
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

      <label>
        Present
        <input type="checkbox" :checked="isPresent" @change="updatePresence" >
      </label>

    </single-observation-zoomed-view>
  </div>
</template>

<style src="./PresenceDescriptor.styl" lang="stylus"></style>

<script>
import SingleObservationDescriptor from '../SingleObservationDescriptor'
import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'

export default {
  mixins: [SingleObservationDescriptor],
  name: 'PresenceDescriptor',
  props: ['index'],
  computed: {
    isPresent () {
      return this.$store.getters[GetterNames.GetPresenceFor](this.$props.descriptor.id)
    }
  },
  methods: {
    updatePresence (event) {
      this.$store.commit(MutationNames.SetPresence, {
        descriptorId: this.$props.descriptor.id,
        isChecked: event.target.checked
      })
    }
  }
}
</script>
