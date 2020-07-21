<template>
  <div class="horizontal-left-content">
    <div class="field separate-right label-above">
      <label>Volume</label>
      <input
        type="text"
        v-model="source.volume">
    </div>
    <div class="field separate-right label-above">
      <label>Number</label>
      <input
        type="text"
        v-model="source.number">
    </div>
    <div class="field separate-right label-above">
      <label>Pages</label>
      <input
        type="text"
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
