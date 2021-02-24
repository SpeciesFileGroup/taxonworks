<template>
  <div>
    <label class="display-block">Error tolerance</label>
    <select v-model="filters.error_tolerance">
      <option :value="undefined"/>
      <option
        v-for="tolerance in values"
        :key="tolerance">
        {{ tolerance }}
      </option>
    </select>
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
  },
  data () {
    return {
      values: [0, 1, 2]
    }
  }
}
</script>
