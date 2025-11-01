<template>
  <div class="eml-file-loader">
    <h3>Load existing EML file (optional)</h3>
    <p>Upload an existing eml.xml file to populate the dataset and additional metadata sections below.</p>

    <div>
      <input
        ref="fileInputRef"
        type="file"
        accept=".xml,text/xml,application/xml"
        @change="handleFileSelected"
        class="d-none"
      />
      <VBtn
        color="primary"
        @click="triggerFileInput"
      >
        Choose EML XML file
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { useTemplateRef } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const emit = defineEmits(['emlLoaded'])

const fileInputRef = useTemplateRef('fileInputRef')

function triggerFileInput() {
  fileInputRef.value?.click()
}

function resetFileInput() {
  if (fileInputRef.value) {
    fileInputRef.value.value = ''
  }
}

function handleFileSelected(event) {
  const file = event.target.files[0]
  if (!file) {
    return
  }

  const reader = new FileReader()

  reader.onload = (e) => {
    try {
      const xmlText = e.target.result
      const parser = new DOMParser()
      const xmlDoc = parser.parseFromString(xmlText, 'text/xml')

      const parserError = xmlDoc.querySelector('parsererror')
      if (parserError) {
        throw new Error('Invalid XML file')
      }

      const datasetElement = xmlDoc.querySelector('dataset')
      if (!datasetElement) {
        throw new Error('EML file must contain a <dataset> element')
      }

      const datasetContent = normalizeXmlSpacing(datasetElement.innerHTML)

      const additionalMetadataElement = xmlDoc.querySelector('additionalMetadata')
      const additionalMetadataContent = additionalMetadataElement
        ? normalizeXmlSpacing(additionalMetadataElement.innerHTML)
        : ''

      // Emit the parsed content
      emit('emlLoaded', {
        dataset: datasetContent,
        additionalMetadata: additionalMetadataContent
      })

      TW.workbench.alert.create('EML file loaded successfully', 'notice')

      resetFileInput()
    } catch (err) {
      TW.workbench.alert.create(err.message || 'Failed to parse EML file', 'error')
      resetFileInput()
    }
  }

  reader.onerror = () => {
    TW.workbench.alert.create('Failed to read file', 'error')
    resetFileInput()
  }

  reader.readAsText(file)
}

function normalizeXmlSpacing(xmlString) {
  const lines = xmlString.split('\n')

  // Find the minimum leading whitespace among non-empty lines
  let minWhitespace = Infinity
  lines.forEach(line => {
    if (line.trim().length > 0) {
      const leadingWhitespace = line.match(/^\s*/)[0].length
      minWhitespace = Math.min(minWhitespace, leadingWhitespace)
    }
  })

  if (minWhitespace === Infinity) {
    throw new Error('EML dataset element is empty')
  }

  const normalized = lines.map(line => {
    if (line.trim().length === 0) {
      return ''
    }
    return line.substring(minWhitespace)
  }).join('\n')

  return normalized.trim()
}
</script>

<style lang="scss" scoped>
.eml-file-loader {
  margin-bottom: 2em;
  padding: 1em;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  background-color: var(--bg-muted);
}
</style>
