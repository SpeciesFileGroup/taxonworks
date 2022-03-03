<template>
  <div class="presence-descriptor">
    <summary-view
      :descriptor="descriptor"
      :index="index">
      <label>Free text</label>
      <br>
      <div class="horizontal-left-content">
        <textarea
          class="full_width"
          rows="5"
          :value="freeTextValue"
          @input="updateFreeTextValue" >
        </textarea>

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
  </div>
</template>

<script>
import SingleObservationDescriptor from '../SingleObservationDescriptor'
import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'

export default {
  name: 'FreeTextDescriptor',

  mixins: [SingleObservationDescriptor],

  props: {
    index: {
      type: Number,
      required: true
    }
  },

  computed: {
    isPresent () {
      return this.$store.getters[GetterNames.GetPresenceFor](this.descriptor.id)
    },
    freeTextValue () {
      return this.$store.getters[GetterNames.GetFreeTextValueFor](this.descriptor.id)
    }
  },

  methods: {
    updateFreeTextValue (event) {
      this.$store.commit(MutationNames.SetFreeTextValue, {
        descriptorId: this.descriptor.id,
        description: event.target.value
      })
    }
  }
}
</script>
