<template>
  <div>
    <label class="display-block">Identified to rank</label>
    <select v-model="filters.identified_to_rank">
      <option
        v-for="(rank, index) in ranks"
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
      ranks: [undefined, 'otu', 'subspecies', 'species', 'subgenus', 'genus', 'subtribe', 'tribe', 'subfamily', 'family']
    }
  }
}
</script>
