<template>
  <div class="presence-descriptor">
    <summary-view
      :row-object="rowObject"
      :index="index"
    >
      <div class="horizontal-left-content middle">
        <div class="margin-small-right">
          <ul class="no_bullets">
            <li>
              <label>
                <input
                  :disabled="!observationExist"
                  type="radio"
                  :value="isPresent"
                  :checked="isPresent === undefined"
                  @click="removeObservation"
                >
                Not specified
              </label>
            </li>
            <li
              v-for="(value, key) in presenceOptions"
              :key="key"
            >
              <label>
                <input
                  type="radio"
                  v-model="isPresent"
                  :value="value"
                >
                {{ key }}
              </label>
            </li>
          </ul>
        </div>
        <radial-annotator
          v-if="observationExist"
          :global-id="observation.global_id"
        />
      </div>
    </summary-view>
  </div>
</template>

<script>
import SingleObservationDescriptor from '../SingleObservationDescriptor'
import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'

export default {
  name: 'PresenceDescriptor',

  mixins: [SingleObservationDescriptor],

  data () {
    return {
      presenceOptions: {
        Presence: true,
        Absent: false
      }
    }
  },

  computed: {
    isPresent: {
      get () {
        return this.$store.getters[GetterNames.GetPresenceFor]({
          rowObjectId: this.rowObject.id,
          rowObjectType: this.rowObject.type
        })
      },

      set (value) {
        this.updatePresence(value)
      }
    }
  },
  methods: {
    updatePresence (presenceValue) {
      this.$store.commit(MutationNames.SetPresence, {
        rowObjectId: this.rowObject.id,
        rowObjectType: this.rowObject.type,
        isChecked: presenceValue
      })
    }
  }
}
</script>
