<template>
  <div>
    <h3>Mode</h3>
    <ul class="no_bullets">
      <li>
        <label>
          <input
            type="radio"
            :value="true"
            name="sqed-mode"
            v-model="newCO"
          />
          New object
        </label>
      </li>
      <li>
        <label>
          <input
            type="radio"
            name="sqed-mode"
            :value="false"
            v-model="newCO"
          />
          Existing object
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
import { GetterNames } from '../../../store/getters/getters.js'
import { MutationNames } from '../../../store/mutations/mutations.js'

export default {
  computed: {
    newCO: {
      get() {
        return this.$store.getters[GetterNames.GetNewCOForSqed]
      },
      set(value) {
        this.$store.commit(MutationNames.SetNewCOForSqed, value)
      }
    }
  }
}
</script>
