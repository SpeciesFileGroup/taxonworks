<template>
  <div class="field">
    <label>Language</label>
    <autocomplete
      placeholder="Search a serial"
      url="/languages/autocomplete"
      param="term"
      label="label_html"
      display="label"
      @getItem="source.language_id = $event.id"/>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete
  },
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
