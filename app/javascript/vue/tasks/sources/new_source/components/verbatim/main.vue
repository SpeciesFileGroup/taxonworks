<template>
  <div class="panel content">
    <h2>Verbatim</h2>
    <div class="field"> 
      <textarea v-model="verbatim">
      </textarea>
      <button
        class="button normal-input button-submit"
        type="button"
        @click="convert">
        Convert to BibTex source
      </button>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { ActionNames } from '../../store/actions/actions'

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
  },
  methods: {
    convert () {
      this.$store.dispatch(ActionNames.ConvertToBibtex)
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
