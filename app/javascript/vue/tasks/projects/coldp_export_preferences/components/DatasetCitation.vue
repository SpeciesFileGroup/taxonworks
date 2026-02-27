<template>
  <div
    v-if="citation"
    class="panel padding-medium citation-panel"
  >
    <div class="citation-header">
      <h3>ChecklistBank Dataset Citation</h3>
      <div class="citation-actions">
        <button
          class="citation-copy-btn"
          title="Copy as text"
          @click="copyAsText"
        >
          Copy text
        </button>
        <button
          v-if="doi"
          class="citation-copy-btn"
          title="Copy as BibTeX"
          @click="copyAsBibtex"
        >
          Copy BibTeX
        </button>
      </div>
    </div>
    <div
      class="citation-text"
      v-html="sanitizedCitation"
    />
    <p class="citation-hint">
      If this citation loads correctly then your export profile is correctly configured. If it does not load, verify the dataset ID in ChecklistBank. If the citation is wrong, update your metadata.
    </p>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { ColdpExportPreference } from '@/routes/endpoints'

const props = defineProps({
  projectId: {
    type: Number,
    required: true
  },
  datasetId: {
    type: Number,
    default: null
  }
})

const citation = ref(null)
const doi = ref(null)

const sanitizedCitation = computed(() => {
  if (!citation.value) return ''
  return citation.value
    .replace(/^<div[^>]*>/, '')
    .replace(/<\/div>$/, '')
    .replace(
      /(https?:\/\/doi\.org\/[^\s<]+)/g,
      '<a href="$1" target="_blank">$1</a>'
    )
})

const plainTextCitation = computed(() => {
  if (!citation.value) return ''
  const tmp = document.createElement('div')
  tmp.innerHTML = citation.value
  return tmp.textContent || tmp.innerText || ''
})

onMounted(loadCitation)
watch(() => props.datasetId, loadCitation)

async function loadCitation() {
  citation.value = null
  doi.value = null

  if (!props.datasetId) return

  try {
    const { body } = await ColdpExportPreference.checklistbankCitation(
      props.projectId,
      { checklistbank_dataset_id: props.datasetId }
    )
    citation.value = body.citation || null
    doi.value = body.doi || null
  } catch {
    citation.value = null
  }
}

function copyAsText() {
  navigator.clipboard.writeText(plainTextCitation.value)
  TW.workbench.alert.create('Citation copied to clipboard.', 'notice')
}

function copyAsBibtex() {
  const now = new Date()
  const year = plainTextCitation.value.match(/\((\d{4})\)/)?.[1] || now.getFullYear()

  // Extract author from the start of citation up to the year in parens
  const authorMatch = plainTextCitation.value.match(/^(.+?)\s*\(\d{4}\)/)
  const author = authorMatch ? authorMatch[1].replace(/,\s*$/, '') : 'Unknown'

  // Extract title: text between "(YYYY). " and the next "("
  const titleMatch = plainTextCitation.value.match(/\(\d{4}\)\.\s*(.+?)(?:\s*\(|$)/)
  const title = titleMatch ? titleMatch[1].replace(/\.\s*$/, '') : ''

  const doiUrl = doi.value ? `https://doi.org/${doi.value}` : ''
  const key = `clb_${props.datasetId}`

  const bibtex = [
    `@misc{${key},`,
    `  author = {${author}},`,
    `  title = {${title}},`,
    `  year = {${year}},`,
    doi.value ? `  doi = {${doi.value}},` : null,
    doiUrl ? `  url = {${doiUrl}}` : null,
    '}'
  ].filter(Boolean).join('\n')

  navigator.clipboard.writeText(bibtex)
  TW.workbench.alert.create('BibTeX copied to clipboard.', 'notice')
}
</script>

<style lang="scss" scoped>
.citation-panel {
  margin-top: 0.75em;
}

.citation-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.4em;

  h3 {
    margin: 0;
    font-size: 1em;
  }
}

.citation-actions {
  display: flex;
  gap: 0.5em;
}

.citation-copy-btn {
  background: none;
  border: 1px solid var(--border-color, #ccc);
  border-radius: 0.25em;
  padding: 0.15em 0.5em;
  font-size: 0.8em;
  cursor: pointer;
  color: var(--text-color, #333);

  &:hover {
    background-color: var(--bg-muted, #f0f0f0);
  }
}

.citation-text {
  margin: 0;
  line-height: 1.4;
}

.citation-hint {
  font-size: 0.85em;
  opacity: 0.7;
  margin: 0.5em 0 0 0;
}
</style>
