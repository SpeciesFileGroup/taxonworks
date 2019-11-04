<template>
  <div>
    <label>Verbatim</label>
    <br>
    <textarea v-model="verbatim">
    </textarea>
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
