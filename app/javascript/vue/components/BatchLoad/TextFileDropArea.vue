<template>
  <div>
    <div
      class="text-file-drop-area"
      :class="{ 'text-file-drop-area--active': isDragging }"
      @dragover.prevent="isDragging = true"
      @dragleave.prevent="isDragging = false"
      @drop.prevent="handleDrop"
    >
      <textarea
        ref="textareaRef"
        v-model="text"
        class="full_width"
        :placeholder="placeholder"
        :rows="rows"
        @paste="handlePaste"
      />
    </div>
    <div
      v-if="fileError"
      class="feedback feedback-danger feedback-thin margin-small-top"
    >
      {{ fileError }}
    </div>
  </div>
</template>

<script setup>
// A textarea that also accepts a dropped or pasted text file, for batch load
// input (TSV, CSV, BibTeX, ...). A file pasted while focus is outside any
// text field is loaded too (see useDropzonePasteManager).
import { onBeforeUnmount, onMounted, ref, useTemplateRef } from 'vue'
import { useDropzonePasteManager } from '@/composables/useDropzonePasteManager'

const isDragging = ref(false)
const fileError = ref(null)
const textareaRef = useTemplateRef('textareaRef')

const props = defineProps({
  placeholder: {
    type: String,
    default: ''
  },

  rows: {
    type: Number,
    default: 12
  },

  // When false, a loaded file is only emitted (as 'file'), e.g. for a
  // parent that parses it, and the textarea is left alone.
  fileToText: {
    type: Boolean,
    default: true
  },

  autofocus: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['file'])

const text = defineModel('text', { type: String, required: true })

// The name of the file the text was loaded from, null when typed or pasted.
const fileName = defineModel('fileName', { type: String, default: null })

const { registerPaster, unregisterPaster } = useDropzonePasteManager()
const pasteZone = { handler: handlePaste, prioritize: false }

// Decoded strictly: a lenient decode would silently replace the bytes of a
// non-UTF-8 file (e.g. a Windows-1252 export) with U+FFFD.
async function loadFile(file) {
  fileError.value = null

  let fileText
  try {
    fileText = new TextDecoder('utf-8', { fatal: true }).decode(
      await file.arrayBuffer()
    )
  } catch {
    fileError.value = `'${file.name}' is not UTF-8 text. Save or export it as UTF-8 and try again.`
    return
  }

  if (props.fileToText) {
    text.value = fileText
    fileName.value = file.name
  }
  emit('file', { name: file.name, text: fileText })
}

function handleDrop(event) {
  isDragging.value = false
  const file = event.dataTransfer?.files?.[0]
  if (file) loadFile(file)
}

function handlePaste(event) {
  const clipboardData = event.clipboardData
  const items = clipboardData?.items
  if (!items?.length) return

  // Spreadsheet copies often also put an image of the selection on the
  // clipboard; prefer the text, which pastes natively into the textarea.
  if (clipboardData.getData('text')?.trim()) {
    if (event.target === textareaRef.value) {
      fileName.value = null
      fileError.value = null
    }
    return
  }

  for (const item of items) {
    if (item.kind !== 'file') continue
    const file = item.getAsFile()
    if (!file?.size) continue // browsers can report empty phantom files
    event.preventDefault()
    loadFile(file)
    return
  }
}

onMounted(() => {
  registerPaster(pasteZone)
  if (props.autofocus) textareaRef.value?.focus()
})

onBeforeUnmount(() => {
  unregisterPaster(pasteZone)
})
</script>

<style scoped>
.text-file-drop-area {
  border: 2px dashed var(--border-color);
  border-radius: 4px;
  transition: border-color 0.2s;
}

.text-file-drop-area--active {
  border-color: var(--color-primary);
  background-color: var(--badge-blue-bg);
}

.text-file-drop-area textarea {
  border: none;
}
</style>
