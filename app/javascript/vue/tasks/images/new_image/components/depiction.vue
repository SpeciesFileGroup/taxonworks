<template>
  <div class="panel content panel-section">
    <h2>Depiction</h2>
    <div>
      <label>Caption</label>
      <br>
      <textarea
        v-model="depiction"
        rows="5"
        class="full_width"/>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters.js'
import { MutationNames } from '../store/mutations/mutations.js'

export default {
  computed: {
    depiction: {
      get () {
        return this.$store.getters[GetterNames.GetDepiction].caption
      },
      set (value) {
        this.$store.commit(MutationNames.SetDepictionCaption, value)
      }
    }
  }
}
</script>
