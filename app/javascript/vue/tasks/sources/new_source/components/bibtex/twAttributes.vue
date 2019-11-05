<template>
  <div>
    <h3>TW attributes</h3>
    <div class="field">
      <label>Verbatim contents</label><br>
      <textarea
        type="text"
        v-model="source.verbatim_contents">
      </textarea>
    </div>
    <div class="field">
      <label>Verbatim keywords</label><br>
      <textarea
        type="text"
        v-model="source.verbatim_keywords">
      </textarea>
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
