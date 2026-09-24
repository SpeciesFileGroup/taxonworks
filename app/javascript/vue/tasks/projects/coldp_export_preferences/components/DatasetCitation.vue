<template>
  <div
    v-if="citation"
    class="panel padding-medium margin-medium-top"
  >
    <div class="flex-separate middle margin-small-bottom">
      <h3 class="no-margin">ChecklistBank Dataset Citation</h3>
      <div class="horizontal-left-content gap-small">
        <VBtn
          color="primary"
          title="Copy as text"
          @click="copyAsText"
        >
          Copy text
        </VBtn>
        <VBtn
          v-if="doi"
          color="primary"
          title="Copy as BibTeX"
          @click="copyAsBibtex"
        >
          Copy BibTeX
        </VBtn>
      </div>
    </div>
    <div v-html="sanitizedCitation" />
    <p class="small_type margin-small-top">
      If this citation loads correctly then your export profile is correctly configured. If it does not load, verify the dataset ID in ChecklistBank. If the citation is wrong, update your metadata.
    </p>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { ColdpExportPreference } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'

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
