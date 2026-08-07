<template>
  <div>
    <label class="display-block">Descriptor sorting</label>
    <select v-model="filters.sorting">
      <option
        v-for="(rank, index) in ranks"
        :value="rank"
        :key="index">
        {{ rank }}
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
      ranks: [
        undefined,
        'ordered',
        'weighted',
        'optimized'
      ]
    }
  }
}
</script>
