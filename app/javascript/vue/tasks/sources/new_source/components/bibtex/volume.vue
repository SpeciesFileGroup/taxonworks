<template>
  <div class="horizontal-left-content">
    <div class="field separate-right">
      <label>Volume</label><br>
      <input
        type="number"
        v-model="source.volume">
    </div>

    <div class="field separate-right">
      <label>Number</label><br>
      <input
        type="number"
        v-model="source.number">
    </div>
    <div class="field separate-right">
      <label>Pages</label><br>
      <input
        type="number"
        v-model="source.pages">
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

<style>
  input[type="number"] {
    width: 80px;
  }
</style>