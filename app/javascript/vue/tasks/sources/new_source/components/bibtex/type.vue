<template>
  <div class="field">
    <label>Bibtex type</label>
    <br>
    <select
      class="normal-input"
      v-model="bibtexType">
      <option
        v-for="item in list"
        :key="item"
        :value="item">
        {{ item }}
      </option>
    </select>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    bibtexType: {
      get () {
        return this.$store.getters[GetterNames.GetBibtexType]
      },
      set (value) {
        this.$store.commit(MutationNames.SetBibtexType, value)
      }
    }
  },
  data () {
    return {
      list: [
        'article',
        'book',
        'booklet',
        'conference',
        'inbook',
        'incollection',
        'inproceedings',
        'manual',
        'mastersthesis',
        'misc',
        'phdthesis',
        'proceedings',
        'techreport',
        'unpublished'
      ]
    }
  }
}
</script>

<style>

</style>