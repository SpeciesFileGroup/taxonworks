<template>
  <div class="presence-descriptor">
    <summary-view
      :row-object="rowObject"
      :index="index"
    >
      <label>Free text</label>
      <br>
      <div class="horizontal-left-content">
        <textarea
          class="full_width"
          rows="5"
          :value="freeTextValue"
          @input="updateFreeTextValue">
        </textarea>

        <radial-annotator
          v-if="observationExist"
          :global-id="observation.global_id"
        />
        <span
          v-if="observationExist"
          type="button"
          class="circle-button btn-delete"
          @click="removeObservation"
        >
          Remove
        </span>
      </div>
      <TimeFields
        v-if="observation"
        :row-object="rowObject"
        :observation="observation"
      />
    </summary-view>
  </div>
</template>

<script>
import SingleObservationDescriptor from '../SingleObservationDescriptor'
import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'
import TimeFields from '../../Time/TimeFields.vue'

export default {
  name: 'FreeTextDescriptor',

  components: { TimeFields },

  mixins: [SingleObservationDescriptor],

  computed: {
    freeTextValue () {
      return this.$store.getters[GetterNames.GetFreeTextValueFor]({
        rowObjectId: this.rowObject.id,
        rowObjectType: this.rowObject.type
      })
    }
  },

  methods: {
    updateFreeTextValue (event) {
      this.$store.commit(MutationNames.SetFreeTextValue, {
        rowObjectId: this.rowObject.id,
        rowObjectType: this.rowObject.type,
        description: event.target.value
      })
    }
  }
}
</script>
