<template>
  <div>
    <h3>Verbatim from BibTeX</h3>
    <div class="field">
      <label>Author(s)</label><br>
      <input
        type="text"
        v-model="source.author"/>
    </div>
    <div class="field">
      <label>Editor(s)</label><br>
      <input
        type="text"
        v-model="source.editor"/>
    </div>
    <div class="field">
      <label>Journal</label><br>
      <input
        type="text"
        v-model="source.journal"/>
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
