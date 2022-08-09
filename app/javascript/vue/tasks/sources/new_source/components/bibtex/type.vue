<template>
  <div class="field">
    <label v-help.section.BibTeX.type>Type</label>
    <br>
    <div class="horizontal-left-content">
      <select
        id="type"
        class="normal-input capitalize separate-right"
        v-model="bibtexType">
        <option
          v-for="item in list"
          :key="item"
          :value="item">
          {{ item }}
        </option>
      </select>
      <lock-component v-model="settings.lock.bibtex_type"/>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import LockComponent from 'components/ui/VLock/index.vue'

export default {
  components: {
    LockComponent
  },
  computed: {
    bibtexType: {
      get () {
        return this.$store.getters[GetterNames.GetBibtexType]
      },
      set (value) {
        this.$store.commit(MutationNames.SetBibtexType, value)
      }
    },
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
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