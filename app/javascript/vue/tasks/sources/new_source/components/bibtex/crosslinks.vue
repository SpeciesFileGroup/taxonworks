<template>
  <div>
    <h3 v-help.section.BibTeX.crosslinks>BibTeX crosslinks</h3>
    <div class="field">
      <label>Doi</label><br>
      <input
        type="text"
        v-model="source.doi"/>
    </div>
    <div class="field">
      <label>Isbn</label><br>
      <input
        type="text"
        v-model="source.isbn"/>
    </div>
    <div class="field">
      <label>Issn</label><br>
      <input
        type="text"
        v-model="source.issn"/>
    </div>
    <div class="field">
      <label>Note</label><br>
      <textarea
        type="text"
        v-model="source.note">
      </textarea>
    </div>
    <div class="field">
      <label>Annote</label><br>
      <input
        type="text"
        v-model="source.annote"/>
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
