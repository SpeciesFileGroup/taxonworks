<template>
  <div>
    <div class="field label-above">
      <label>Verbatim author</label>
      <input
        type="text"
        v-model="verbatim_author">
    </div>
    <div class="fields label-above">
      <label>Verbatim year</label>
      <input
        type="text"
        v-model="verbatim_year"
        v-number-only
      >
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { numberOnly } from 'directives/index.js'

export default {
  directives: { numberOnly },

  computed: {
    verbatim_author: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonAuthor]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonAuthor, value)
        this.$store.commit(MutationNames.UpdateLastChange)
      }
    },

    verbatim_year: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonYearPublication]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonYearPublication, value)
        this.$store.commit(MutationNames.UpdateLastChange)
      }
    }
  }
}
</script>
