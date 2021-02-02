<template>
  <div class="panel content">
    <h3>Verbatim</h3>
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
    source () {
      return this.$store.getters[GetterNames.GetSource]
    },
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

<style scoped>
  textarea {
    width: 100%;
    height: 100px;
  }
</style>
