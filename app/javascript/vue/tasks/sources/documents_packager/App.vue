<template>
  <div class="documents-packager">
    <div class="flex-separate middle margin-medium-top">
      <div>
        <p>
          Individual downloads are capped at {{ formatBytes(maxBytes) }}; you can specify a different maximum download size to the right.
        </p>
      </div>
      <VBtn
        :disabled="!filterParams"
        color="primary"
        @click="goBackToFilter"
      >
        Back to Filter sources
      </VBtn>
    </div>

    <VSpinner
      v-if="isLoading"
      full-screen
      legend="Preparing downloads..."
    />

    <div v-if="errorMessage && !isLoading">
      <p class="feedback feedback-warning">{{ errorMessage }}</p>
    </div>

    <div v-if="!isLoading && !errorMessage">
      <div class="documents-packager__downloads margin-large-bottom">
        <div class="flex-separate middle">
          <h2>Download packages</h2>
          <div class="documents-packager__controls display-flex align-center gap-medium">
            <label class="documents-packager__nickname display-flex align-center gap-small">
              Max MB
              <input
                type="number"
                class="normal-input"
                v-model.number="maxMb"
              min="10"
              max="1000"
              />
            </label>
            <VBtn
              color="primary"
              @click="refreshPreview"
            >
              Update downloads
            </VBtn>
          </div>
        </div>

        <ul v-if="groups.length">
          <li
            v-for="group in groups"
            :key="group.index"
            class="documents-packager__download-item margin-small-bottom"
          >
            <template v-if="group.available_count > 0">
              <VBtn
                color="primary"
                @click="downloadGroup(group.index)"
              >
                {{ downloadFilename(group.index) }}
              </VBtn>
            </template>

            <template v-else>
              <span class="documents-packager__disabled-link">
                {{ downloadFilename(group.index) }}
              </span>
            </template>

            <span class="margin-small-left">
              {{ group.available_count || 0 }} available of
              {{ group.document_ids.length }} docs ·
              {{ formatBytes(group.size) }}
            </span>
          </li>
        </ul>

        <p v-else class="subtle">No documents found in the selected sources.</p>
      </div>

      <div class="documents-packager__table margin-large-top">
        <h2>Sources</h2>
        <table class="table-striped documents-packager__table-table">
          <thead>
            <tr>
              <th>Download</th>
              <th>Source</th>
              <th>Doc</th>
              <th>Doc size</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="row in tableRows"
              :key="row.key"
              :class="rowClass(row)"
            >
              <td class="documents-packager__package">
                {{ row.document ? `Zip ${row.document.group_index}` : '—' }}
              </td>
              <td>
                <a :href="`/sources/${row.source.id}`">
                  Source
                </a>
                <span
                  class="margin-small-left"
                  :class="{ subtle: !row.document }"
                >
                  {{ row.source.cached }}
                </span>
              </td>
              <td>
                <template v-if="row.document">
                  <a :href="row.document.url">
                    Doc
                  </a>
                  <span
                    class="margin-small-left"
                    :class="{ subtle: !row.document }"
                  >
                    {{ row.document.name }}
                  </span>
                </template>

                <span v-else class="subtle">No documents</span>
              </td>
              <td>
                {{ row.document ? formatBytes(row.document.size) : '—' }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeMount, ref, watch } from 'vue'
import qs from 'qs'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import ajaxCall from '@/helpers/ajaxCall'
import { LinkerStorage } from '@/shared/Filter/utils'
import {
  STORAGE_FILTER_QUERY_KEY,
  STORAGE_FILTER_QUERY_STATE_PARAMETER
} from '@/constants'
import { randomUUID } from '@/helpers'
import { createAndSubmitForm } from '@/helpers/forms'

const isLoading = ref(false)
const groups = ref([])
const sources = ref([])
const errorMessage = ref('')
const filterParams = ref(null)
const maxBytes = ref(0)
const absoluteMinMb = 10
const absoluteMaxMb = 1000
const maxMb = ref(absoluteMaxMb)

watch(maxMb, (value) => {
  const clamped = clampMaxMb(value)
  if (clamped !== value) {
    maxMb.value = clamped
  }
})

function clampMaxMb(value) {
  const parsed = Number(value)
  if (Number.isNaN(parsed)) return absoluteMaxMb
  return Math.min(absoluteMaxMb, Math.max(absoluteMinMb, Math.round(parsed)))
}

const tableRows = computed(() => {
  const rows = []
  const sorted = [...sources.value].sort((a, b) => a.id - b.id)
  const seenGroups = new Set()

  sorted.forEach((source) => {
    if (!source.documents.length) {
      rows.push({
        key: `source-${source.id}`,
        source,
        document: null
      })
    } else {
      source.documents.forEach((doc) => {
        const groupIndex = doc.group_index
        const isGroupStart = !seenGroups.has(groupIndex)
        seenGroups.add(groupIndex)

        rows.push({
          key: `source-${source.id}-doc-${doc.id}`,
          source,
          document: {
            ...doc,
            isGroupStart
          }
        })
      })
    }
  })

  return rows
})

function downloadGroup(index) {
  const data = {
    ...(filterParams.value || {}),
    group: index,
    max_mb: maxMb.value
  }

  createAndSubmitForm({
    action: '/tasks/sources/documents_packager/download',
    data,
    openTab: true,
    openTabStrategy: 'target',
    absoluteAction: true
  })
}

function downloadFilename(index) {
  const date = new Date()
  const formatted = `${date.getMonth() + 1}_${date.getDate()}_${String(
    date.getFullYear()
  ).slice(-2)}`
  return `TaxonWorks-sources_download-${formatted}-${index}_of_${groups.value.length}.zip`
}

function formatBytes(value) {
  const bytes = Number(value) || 0
  if (bytes === 0) return '0 B'
  const units = ['B', 'KB', 'MB', 'GB']
  const exponent = Math.min(
    Math.floor(Math.log(bytes) / Math.log(1000)),
    units.length - 1
  )
  const size = bytes / 1000 ** exponent
  return `${size.toFixed(0)} ${units[exponent]}`
}

function rowClass(row) {
  return {
    'opacity-50': !row.document,
    'documents-packager__row--divider': row.document?.isGroupStart
  }
}

function goBackToFilter() {
  if (!filterParams.value) return

  const uuid = randomUUID()
  localStorage.setItem(
    STORAGE_FILTER_QUERY_KEY,
    JSON.stringify({ [uuid]: filterParams.value })
  )
  window.location.href = `/tasks/sources/filter?${STORAGE_FILTER_QUERY_STATE_PARAMETER}=${uuid}`
}

function loadPreview(params) {
  isLoading.value = true
  errorMessage.value = ''

  ajaxCall('post', '/tasks/sources/documents_packager/preview.json', {
    ...params,
    max_mb: maxMb.value
  })
    .then(({ body }) => {
      sources.value = body.sources || []
      groups.value = body.groups || []
      filterParams.value = body.filter_params || null
      maxBytes.value = body.max_bytes || 0
    })
    .catch(() => {
      errorMessage.value = 'Unable to load sources for packaging.'
    })
    .finally(() => {
      isLoading.value = false
    })
}

onBeforeMount(function () {
  const stored = LinkerStorage.getParameters() || {}
  const params = {
    ...qs.parse(window.location.search, {
      ignoreQueryPrefix: true,
      arrayLimit: 2000
    }),
    ...stored
  }

  LinkerStorage.removeParameters()

  if (!Object.keys(params).length) {
    errorMessage.value =
      'No source filter parameters were found. Launch this task from Filter Sources using the right side linker radial.'
    return
  }

  loadPreview(params)
})

function refreshPreview() {
  if (!filterParams.value) return

  loadPreview(filterParams.value)
}
</script>

<style scoped lang="scss">

.documents-packager__table {
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
}

.documents-packager__table-table {
  table-layout: fixed;
  width: 100%;
}

.documents-packager__table-table th,
.documents-packager__table-table td {
  padding: 0.65rem 0.85rem;
  vertical-align: top;
}

.documents-packager__table-table th:nth-child(2),
.documents-packager__table-table td:nth-child(2) {
  width: 60%;
}

.documents-packager__table-table th:nth-child(3),
.documents-packager__table-table td:nth-child(3) {
  width: 25%;
}

.documents-packager__table-table th:nth-child(1),
.documents-packager__table-table td:nth-child(1) {
  width: 5%;
}

.documents-packager__table-table th:nth-child(4),
.documents-packager__table-table td:nth-child(4) {
  width: 8%;
}

.documents-packager__table-table td:nth-child(3) {
  overflow-wrap: anywhere;
  word-break: break-word;
}

.documents-packager__package {
  white-space: nowrap;
}

.documents-packager__disabled-link {
  color: #666;
  cursor: not-allowed;
  text-decoration: line-through;
}

.documents-packager__row--divider td {
  border-top: 3px solid #2a6db0;
}
</style>
