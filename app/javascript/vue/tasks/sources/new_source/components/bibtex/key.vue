<template>
  <div class="horizontal-left-content">
    <div class="field separate-right">
      <label>Key</label><br>
      <input
        type="text"
        v-model="source.key">
    </div>

    <div class="field separate-right">
      <label>Crossref</label><br>
      <input
        type="text"
        v-model="source.crossref">
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    source: {
      get () {
        return this.$store.getters[GetterNames.GetSource]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSource, value)
      }
    }
  }
}
</script>

<style scoped>
  input[type="number"] {
    width: 80px;
  }
</style>