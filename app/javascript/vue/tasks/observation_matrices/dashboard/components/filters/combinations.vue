<template>
  <div>
    <h2>Combinations</h2>
    <label>
      <input
        type="checkbox"
        v-model="combination">
      Includes
    </label>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    combination: {
      get () {
        return this.$store.getters[GetterNames.GetCombinations]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCombinations, value)
      }
    }
  }
}
</script>