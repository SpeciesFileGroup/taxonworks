<template>
  <div id="content_editor">
    <h1>New content</h1>
    <div
      class="flex-separate"
      id="panels-content"
    >
      <div class="item item2 column-big">
        <ContentEditor />
        <FiguresPanel />
      </div>
    </div>
  </div>
</template>

<script setup>
import ContentEditor from './editor/ContentEditor.vue'
import FiguresPanel from './editor/figuresPanel.vue'
</script>
