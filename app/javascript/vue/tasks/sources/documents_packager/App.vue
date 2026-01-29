<template>
  <div class="documents-packager">
    <div class="flex-separate middle">
      <div>
        <h1>Documents packager</h1>
        <p>
          Packages are capped at {{ formatBytes(maxBytes) }}.
        </p>
      </div>
      <button
        class="button normal-input button-default"
        :disabled="!filterParams"
        @click="goBackToFilter"
      >
        Back to Filter sources
      </button>
    </div>

    <VSpinner
      v-if="isLoading"
      full-screen
      legend="Preparing packages..."
    />

    <div v-if="errorMessage && !isLoading">
      <p class="feedback feedback-warning">{{ errorMessage }}</p>
    </div>

    <div v-if="!isLoading && !errorMessage">
      <div class="documents-packager__downloads">
        <div class="flex-separate middle">
          <h2>Download packages</h2>
          <div class="documents-packager__controls">
            <label class="documents-packager__nickname">
              Nickname
              <input
                type="text"
                class="normal-input"
                v-model="nickname"
                placeholder="e.g. smith_sources"
              />
            </label>
            <label class="documents-packager__nickname">
              Max MB
              <input
                type="number"
                class="normal-input"
                v-model.number="maxMb"
                min="1"
                max="500"
              />
            </label>
            <button
              class="button normal-input button-default"
              @click="refreshPreview"
            >
              Update packages
            </button>
          </div>
        </div>
        <ul v-if="groups.length">
          <li
            v-for="group in groups"
            :key="group.index"
            class="documents-packager__download-item"
          >
            <template v-if="group.available_count > 0">
              <button
                type="button"
                class="button-link"
                @click="downloadGroup(group.index)"
              >
                {{ downloadFilename(group.index) }}
              </button>
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

      <div class="documents-packager__table">
        <h2>Sources</h2>
        <table class="table-striped documents-packager__table-table">
          <thead>
            <tr>
              <th>Package</th>
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
                  Source {{ row.source.id }}
                </a>
                <span
                  class="documents-packager__detail margin-small-left"
                  :class="{ subtle: !row.document }"
                >
                  {{ row.source.cached }}
                </span>
              </td>
              <td>
                <template v-if="row.document">
                  <a :href="row.document.url">
                    Doc {{ row.document.id }}
                  </a>
                  <span
                    class="documents-packager__detail margin-small-left"
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
import { computed, onBeforeMount, ref } from 'vue'
import qs from 'qs'
import VSpinner from '@/components/ui/VSpinner.vue'
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
const nickname = ref('')
const errorMessage = ref('')
const filterParams = ref(null)
const maxBytes = ref(0)
const maxMb = ref(50)

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

const downloadGroup = (index) => {
  const nick = nickname.value.trim()
  const data = {
    ...(filterParams.value || {}),
    group: index,
    max_mb: maxMb.value
  }

  if (nick) {
    data.nickname = nick
  }

  createAndSubmitForm({
    action: '/tasks/sources/documents_packager/download',
    data,
    openTab: true,
    openTabStrategy: 'target',
    absoluteAction: true
  })
}

const downloadFilename = (index) => {
  const nick = nickname.value.trim() || 'download'
  const date = new Date()
  const formatted = `${date.getMonth() + 1}_${date.getDate()}_${String(
    date.getFullYear()
  ).slice(-2)}`
  return `TaxonWorks-${nick}-${formatted}-${index}_of_${groups.value.length}.zip`
}

const formatBytes = (value) => {
  const bytes = Number(value) || 0
  if (bytes === 0) return '0 B'
  const units = ['B', 'KB', 'MB', 'GB']
  const exponent = Math.min(
    Math.floor(Math.log(bytes) / Math.log(1024)),
    units.length - 1
  )
  const size = bytes / 1024 ** exponent
  return `${size.toFixed(size >= 10 || exponent === 0 ? 0 : 1)} ${
    units[exponent]
  }`
}

const rowClass = (row) => ({
  'documents-packager__row--empty': !row.document,
  'documents-packager__row--divider': row.document?.isGroupStart
})

const goBackToFilter = () => {
  if (!filterParams.value) return

  const uuid = randomUUID()
  localStorage.setItem(
    STORAGE_FILTER_QUERY_KEY,
    JSON.stringify({ [uuid]: filterParams.value })
  )
  window.location.href = `/tasks/sources/filter?${STORAGE_FILTER_QUERY_STATE_PARAMETER}=${uuid}`
}

const loadPreview = (params) => {
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

onBeforeMount(() => {
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
      'No source filter parameters were found. Launch this task from Filter Sources.'
    return
  }

  loadPreview(params)
})

const refreshPreview = () => {
  if (!filterParams.value) return
  loadPreview(filterParams.value)
}
</script>
