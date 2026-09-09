<template>
  <div ref="editorRef" />
</template>

<script setup>
import { onMounted, watch, useTemplateRef } from 'vue'
import CodeMirror from 'codemirror'
import 'codemirror/mode/yaml/yaml.js'
import 'codemirror/lib/codemirror.css'

const content = defineModel({
  type: String,
  default: ''
})

const props = defineProps({
  rows: {
    type: Number,
    default: 20
  }
})

const editorRef = useTemplateRef('editorRef')
let editor = null

onMounted(() => {
  const config = {
    value: content.value || '',
    mode: 'yaml',
    lineNumbers: true,
    lineWrapping: true,
    tabSize: 2,
    indentWithTabs: false,
    viewportMargin: Infinity
  }

  editor = CodeMirror(editorRef.value, config)

  editor.setSize('100%', `${props.rows * 20}px`)

  editor.on('change', (cm) => {
    content.value = cm.getValue()
  })
})

watch(content, (newValue) => {
  if (editor && newValue !== editor.getValue()) {
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

:deep(.cm-atom) {
  color: var(--code-tag-color);
}

:deep(.cm-meta) {
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
</style>
