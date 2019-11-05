<template>
  <div class="panel content">
    <h2>Verbatim</h2>
    <div class="field"> 
      <textarea v-model="verbatim">
      </textarea>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    verbatim: {
      get () {
        return this.$store.getters[GetterNames.GetVerbatim]
      },
      set (value) {
        this.$store.commit(MutationNames.SetVerbatim, value)
      }
    }
  }
}
</script>

<style>

</style>
