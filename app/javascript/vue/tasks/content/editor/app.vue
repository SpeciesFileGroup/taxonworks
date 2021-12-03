<template>
  <div id="content_editor">
    <h1>New content</h1>
    <div
      class="flex-separate"
      id="panels-content">
      <div class="item item2 column-big">
        <content-editor ref="contentEditor"/>
        <figures-panel @selected="setDepictionLink"/>
      </div>
    </div>
  </div>
</template>

<script>

import ContentEditor from './editor/content.vue'
import FiguresPanel from './editor/figuresPanel.vue'

export default {
  components: {
    ContentEditor,
    FiguresPanel
  },

  methods: {
    setDepictionLink (depiction) {
      const link = `[${depiction.figure_label}](/depictions/${depiction.id})`

      this.$refs.contentEditor.addText(link)
    }
  },
}

</script>
