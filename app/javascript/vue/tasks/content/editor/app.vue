<template>
  <div id="content_editor">
    <h1>New content</h1>
    <div
      class="flex-separate"
      id="panels-content">
      <div class="item item2 column-big">
        <content-editor/>
        <citation-list class="citation-list panel"/>
        <figures-panel/>
      </div>
    </div>
  </div>
</template>

<script>

import CitationList from './editor/citationList.vue'
import ContentEditor from './editor/content.vue'
import FiguresPanel from './editor/figuresPanel.vue'

export default {
  components: {
    CitationList,
    ContentEditor,
    FiguresPanel
  }
}

</script>
