<template>
  <div>
    <label>Type</label>
    <ul class="no_bullets">
      <li
        v-for="type in types"
        :key="type.value">
        <label>
          <input
            v-model="sourceType"
            :value="type.value"
            name="source-type"
            type="radio">
          {{ type.label }}
        </label>
        
      </li>
    </ul>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  computed: {
    sourceType: {
      get () {
        return this.$store.getters[GetterNames.GetType]
      },
      set (value) {
        this.$store.commit(MutationNames.SetType, value)
      }
    }
  },
  data () {
    return {
      types: [
        {
          label: 'BibTeX',
          value: 'Source::Bibtex'
        },
        {
          label: 'Verbatim',
          value: 'Source::Verbatim'
        },
        {
          label: 'Person',
          value: 'Source::Human'
        }
      ]
    }
  }
}
</script>

<style>

</style>
