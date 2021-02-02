<template>
  <block-layout
    anchor="etymology"
    :spinner="!taxon.id"
    v-help.section.etymology.container>
    <h3 slot="header">Etymology</h3>
    <div
      slot="body">
      <markdown-editor
        @blur="updateLastChange"
        class="edit-content"
        v-model="etymology"
        :configs="config"
        ref="etymologyText"/>
    </div>
  </block-layout>
</template>
<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import MarkdownEditor from 'components/markdown-editor.vue'
import BlockLayout from 'components/blockLayout'

export default {
  components: {
    BlockLayout,
    MarkdownEditor
  },
  computed: {
    etymology: {
      get () {
        return this.$store.getters[GetterNames.GetEtymology]
      },
      set (text) {
        this.$store.commit(MutationNames.SetEtymology, text)
      }
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },
  data () {
    return {
      config: {
        status: false,
        spellChecker: false
      }
    }
  },
  methods: {
    updateLastChange () {
      this.$store.commit(MutationNames.UpdateLastChange)
    }
  }
}
</script>
