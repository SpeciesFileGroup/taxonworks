<template>
  <div class="basic-information panel">
    <a
      name="etymology"
      class="anchor"/>
    <div class="header flex-separate middle">
    <h3
    v-help.section.etymology.container
    >Etymology</h3>
      <expand
        @changed="expanded = !expanded"
        :expanded="expanded"/>
    </div>
    <div
      class="body"
      v-show="expanded">
      <markdown-editor
        class="edit-content"
        v-model="etymology"
        :configs="config"
        ref="etymologyText"/>
    </div>
  </div>
</template>
<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import MarkdownEditor from 'components/markdown-editor.vue'
import Expand from './expand.vue'

export default {
  components: {
    MarkdownEditor,
    Expand
  },
  computed: {
    etymology: {
      get () {
        return this.$store.getters[GetterNames.GetEtymology]
      },
      set (text) {
        this.$store.commit(MutationNames.SetEtymology, text)
        this.$store.commit(MutationNames.UpdateLastChange)
      }
    }
  },
  data: function () {
    return {
      expanded: true,
      config: {
        status: false,
        toolbar: ['bold', 'italic', 'code', 'heading', '|', 'quote', 'unordered-list', 'ordered-list', '|', 'link', 'table', 'preview'],
        spellChecker: false
      }
    }
  }
}
</script>
