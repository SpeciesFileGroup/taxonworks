<template>
  <div class="presence-descriptor">
    <summary-view
      :descriptor="descriptor"
      :index="index"
    >
      <div class="horizontal-left-content middle gap-small">
        <div>
          <ul class="no_bullets">
            <li>
              <label>
                <input
                  :disabled="!observationExist"
                  type="radio"
                  :value="isPresent"
                  :checked="isPresent === undefined"
                  @click="removeObservation"
                />
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
                />
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

<style src="./PresenceDescriptor.scss" lang="scss"></style>

<script>
import SingleObservationDescriptor from '../SingleObservationDescriptor'
import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'

export default {
  mixins: [SingleObservationDescriptor],
  name: 'PresenceDescriptor',
  props: {
    index: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      presenceOptions: {
        Presence: true,
        Absent: false
      }
    }
  },
  computed: {
    isPresent: {
      get() {
        return this.$store.getters[GetterNames.GetPresenceFor](
          this.$props.descriptor.id
        )
      },
      set(value) {
        this.updatePresence(value)
      }
    }
  },
  methods: {
    updatePresence(presenceValue) {
      this.$store.commit(MutationNames.SetPresence, {
        descriptorId: this.$props.descriptor.id,
        isChecked: presenceValue
      })
    }
  }
}
</script>
