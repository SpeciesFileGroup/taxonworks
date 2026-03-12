<template>
  <div ref="editorRef" />
</template>

<script setup>
import { onMounted, watch, useTemplateRef } from 'vue'
import CodeMirror from 'codemirror'
import 'codemirror/mode/xml/xml.js'
import 'codemirror/addon/edit/matchtags.js'
import 'codemirror/lib/codemirror.css'

const content = defineModel({
  type: String,
  default: ''
})

const props = defineProps({
  rows: {
    type: Number,
    default: 20
  },
  matchTags: {
    type: Boolean,
    default: false
  }
})

const editorRef = useTemplateRef('editorRef')
let editor = null

onMounted(() => {
  const config = {
    value: content.value || '',
    mode: 'xml',
    lineNumbers: true,
    lineWrapping: true,
    tabSize: 2,
    indentWithTabs: false,
    viewportMargin: Infinity
  }

  if (props.matchTags) {
    config.matchTags = { bothTags: true }
  }

  editor = CodeMirror(editorRef.value, config)

  // Set height based on rows prop (approximate: 20px per row)
  editor.setSize('100%', `${props.rows * 20}px`)

  editor.on('change', (cm) => {
    content.value = cm.getValue()
  })
})

watch(content, (newValue) => {
  if (editor && newValue !== editor.getValue()) {
    // Use replaceRange to update content without moving cursor, to prevent
    // CodeMirror highlighting the opening tag on load.
    const lastLine = editor.lastLine()
    const lastCh = editor.getLine(lastLine)?.length || 0
    editor.replaceRange(
      newValue || '',
      { line: 0, ch: 0 },
      { line: lastLine, ch: lastCh }
    )
  }
})
</script>

<style scoped>
:deep(.CodeMirror) {
  border: 1px solid var(--border-color);
  font-family: monospace;
  height: auto;
  max-width: 800px;
  background-color: var(--input-bg-color);
  color: var(--text-color);
}

:deep(.CodeMirror-gutters) {
  background-color: var(--bg-muted);
  border-right: 1px solid var(--border-color);
}

:deep(.CodeMirror-linenumber) {
  color: var(--text-color);
  opacity: 0.5;
}

:deep(.cm-tag) {
  color: var(--code-tag-color);
}

:deep(.cm-attribute) {
  color: var(--code-attribute-color);
}

:deep(.cm-string) {
  color: var(--code-string-color);
}

:deep(.CodeMirror-selected) {
  background-color: var(--code-selection-color) !important;
}

:deep(.CodeMirror-focused .CodeMirror-selected) {
  background-color: var(--code-selection-color) !important;
}

/* Color for matching tags */
:deep(.CodeMirror-matchingtag) {
  background-color: rgba(255, 150, 0, 0.3);
}

/* Error color when a tag doesn't match */
:deep(.cm-tag.cm-error) {
  color: var(--code-error-color);
  background-color: rgba(255, 0, 0, 0.1);
}
</style>
