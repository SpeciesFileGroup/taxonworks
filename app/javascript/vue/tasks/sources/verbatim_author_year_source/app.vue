<template>
  <div id="verbatim-author-year-source-task">
    <h2>Task - TaxonName verbatim author/year without citations</h2>

    <div>
      <a :href="RouteNames.FilterNomenclature">Back to Filter TaxonNames</a>
    </div>

    <VSpinner
      v-if="store.isLoading"
      full-screen
      legend="Loading..."
    />

    <div v-else-if="!store.hasData">
      <p><em>No TaxonNames with verbatim author and year found.</em></p>
    </div>

    <div v-else>
      <div class="flex-separate middle margin-medium-bottom">
        <p class="margin-none">
          Found {{ store.authorYearData.length }} unique author/year
          combinations.
        </p>
        <div class="horizontal-left-content gap-small">
          <VBtn
            color="primary"
            medium
            @click="jumpToMost"
          >
            Jump to most
          </VBtn>
          <VBtn
            color="primary"
            medium
            @click="refresh"
          >
            Refresh
          </VBtn>
        </div>
      </div>

      <AuthorYearTable
        @cite="openSourceModal"
        @preview="openPreviewModal"
      />
    </div>

    <SourceSelectionModal
      v-if="showSourceModal"
      @close="closeSourceModal"
      @select="handleSourceSelect"
    />

    <PreviewModal
      v-if="showPreviewModal"
      :author="previewAuthor"
      :year="previewYear"
      @close="closePreviewModal"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouteNames } from '@/routes/routes'
import { URLParamsToJSON } from '@/helpers'
import useStore from './store/store'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import AuthorYearTable from './components/AuthorYearTable.vue'
import SourceSelectionModal from './components/SourceSelectionModal.vue'
import PreviewModal from './components/PreviewModal.vue'

defineOptions({
  name: 'TaxonNameVerbatimWihtoutCitations'
})

const store = useStore()

const showSourceModal = ref(false)
const showPreviewModal = ref(false)
const previewAuthor = ref(null)
const previewYear = ref(null)
const currentAuthor = ref(null)
const currentYear = ref(null)

onMounted(() => {
  const urlParams = URLParamsToJSON(window.location.href)

  store.loadAuthorYearData(urlParams)
})

function jumpToMost() {
  const highestRow = store.highestCountRow
  if (!highestRow) {
    TW.workbench.alert.create('No uncited rows remaining', 'notice')
    return
  }

  // Find the DOM element for this row - need to escape quotes in selector
  const authorEscaped = highestRow.verbatim_author.replace(/["\\]/g, '\\$&')
  const selector = `tr[data-author="${authorEscaped}"][data-year="${highestRow.year_of_publication}"]`
  const rowElement = document.querySelector(selector)

  if (rowElement) {
    rowElement.scrollIntoView({ behavior: 'smooth', block: 'center' })
    rowElement.style.outline = '3px solid #5D9CE8'
    setTimeout(() => {
      rowElement.style.outline = ''
    }, 2000)
  }
}

function refresh() {
  store.loadAuthorYearData(store.filterParams)
}

function openSourceModal(author, year) {
  currentAuthor.value = author
  currentYear.value = year
  showSourceModal.value = true
}

function closeSourceModal() {
  showSourceModal.value = false
  currentAuthor.value = null
  currentYear.value = null
}

function openPreviewModal(author, year) {
  previewAuthor.value = author
  previewYear.value = year
  showPreviewModal.value = true
}

function closePreviewModal() {
  showPreviewModal.value = false
  previewAuthor.value = null
  previewYear.value = null
  store.resetPreview()
}

async function handleSourceSelect(sourceId) {
  const author = currentAuthor.value
  const year = currentYear.value
  closeSourceModal()

  if (author && year) {
    await store.batchCite(author, year, sourceId)
  }
}
</script>
