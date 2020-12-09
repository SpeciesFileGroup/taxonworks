<template>
  <div>
    <label class="middle">
      <input
        type="checkbox"
        v-model="filters.eliminate_unknown">
      Eliminate unknowns
    </label>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    filters: {
      get () {
        return this.$store.getters[GetterNames.GetParamsFilter]
      },
      set (value) {
        this.$store.commit(MutationNames.SetParamsFilter, value)
      }
    }
  }
}
</script>
