<template>
  <div
    v-if="isPublic"
    class="complete-download-control"
  >
    <h2>Complete Download Status and Controls</h2>

    <div class="download-info">
      <div class="status-row">
        <strong>Status:</strong>
        <span :class="statusClass">{{ statusMessage }}</span>
        <VBtn
          circle
          color="primary"
          class="margin-small-left"
          @click="refreshStatus"
          :disabled="isLoading"
          title="Refresh status"
        >
          <VIcon
            name="synchronize"
            small
          />
        </VBtn>
      </div>

      <div
        v-if="completeDownload && completeDownload.expires"
        class="info-row"
      >
        <div v-if="maxAge && completeDownload.created_at">
          Creation of a new download will automatically be triggered if the API link is accessed after {{ formatDate(getMaxAgeDate()) }}.
          If that doesn't occur, the current download will expire on {{ formatDate(completeDownload.expires) }}.
        </div>
        <div v-else>
          <div>
            <strong>Expires:</strong> {{ formatDate(completeDownload.expires) }}
          </div>
          <div class="feedback-warning padding-xsmall margin-small-top">
            Note: Set Max Age below so that api download requests (after max age time) will trigger creation of a new download.
          </div>
        </div>
      </div>

      <div class="controls-row margin-medium-top">
        <VBtn
          v-if="!completeDownload && !pupalDownload"
          color="create"
          @click="createDownload"
          :disabled="isLoading"
        >
          Create Download
        </VBtn>

        <VBtn
          v-if="completeDownload && completeDownload.ready"
          color="primary"
          @click="downloadFile"
          :disabled="isLoading"
        >
          Download File
        </VBtn>

        <VBtn
          v-if="completeDownload || pupalDownload"
          color="destroy"
          @click="deleteDownload"
          :disabled="isLoading"
        >
          Delete Download
        </VBtn>
      </div>

      <div class="api-link-row margin-medium-top">
        <strong>Complete download API link:</strong>
        <a
          :href="apiLinkUrl"
          target="_blank"
          class="margin-small-left"
          @click.prevent="openApiLink"
        >
          {{ apiLinkUrl }}
        </a>

        <ButtonClipboard
          :text="apiLinkUrl"
          title="Copy API link to clipboard"
          class="margin-small-left"
        />

        <p class="help-text margin-small-top">
          This link can be provided to GBIF or other services to automatically fetch your complete download.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { Download } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import ButtonClipboard from '@/components/ui/Button/ButtonClipboard.vue'

const props = defineProps({
  isPublic: {
    type: Boolean,
    required: true
  },
  projectToken: {
    type: String,
    default: ''
  },
  maxAge: {
    type: Number,
    default: null
  }
})

const isLoading = ref(false)
const completeDownload = ref(null)
const pupalDownload = ref(null)

const apiLinkUrl = computed(() => {
  if (!props.projectToken) return ''
  return `${window.location.origin}/api/v1/downloads/dwc_archive_complete?project_token=${props.projectToken}`
})

const statusMessage = computed(() => {
  if (pupalDownload.value) {
    return 'A new download is being created'
  }
  if (completeDownload.value) {
    if (completeDownload.value.ready) {
      return 'Download is ready'
    } else if (completeDownload.value.expired) {
      return 'Download has expired'
    } else {
      return 'Download is being created...'
    }
  }
  return 'No download exists'
})

const statusClass = computed(() => {
  if (pupalDownload.value) {
    return 'status-creating'
  }
  if (completeDownload.value) {
    if (completeDownload.value.ready) {
      return 'status-ready'
    } else if (completeDownload.value.expired) {
      return 'status-expired'
    } else {
      return 'status-not-ready'
    }
  }
  return 'status-none'
})

onMounted(() => {
  if (props.isPublic) {
    refreshStatus()
  }
})

watch(() => props.isPublic, (newVal) => {
  if (newVal) {
    refreshStatus()
  }
})

async function refreshStatus() {
  isLoading.value = true
  try {
    const { body } = await Download.where({
      download_type: ['Download::DwcArchive::Complete', 'Download::DwcArchive::PupalComplete']
    })

    completeDownload.value = body.find(d => d.type === 'Download::DwcArchive::Complete') || null
    pupalDownload.value = body.find(d => d.type === 'Download::DwcArchive::PupalComplete') || null

    if (completeDownload.value) {
      const now = new Date()
      const expiresDate = new Date(completeDownload.value.expires)
      completeDownload.value.expired = expiresDate < now
    }
  } catch (error) {
    TW.workbench.alert.create('Failed to fetch download status', 'error')
    console.error(error)
  } finally {
    isLoading.value = false
  }
}

async function createDownload() {
  if (!confirm('Create a new complete download? This may take some time.')) {
    return
  }

  isLoading.value = true
  try {
    const url = `/api/v1/downloads/dwc_archive_complete?project_token=${props.projectToken}`
    const response = await fetch(url)

    if (response.ok) {
      // If it's a file download, it means a download already existed and was ready
      TW.workbench.alert.create('Download already exists and is ready', 'notice')
    } else {
      const data = await response.json()
      if (data.status) {
        TW.workbench.alert.create(data.status, 'notice')
      }
    }

    // Wait a bit for the database to commit the transaction
    await new Promise(resolve => setTimeout(resolve, 500))

    await refreshStatus()
  } catch (error) {
    TW.workbench.alert.create('Failed to create download', 'error')
    console.error(error)
  } finally {
    isLoading.value = false
  }
}

async function deleteDownload() {
  const downloadToDelete = pupalDownload.value || completeDownload.value
  if (!downloadToDelete) {
    return
  }

  if (!confirm('Delete the complete download? This action cannot be undone.')) {
    return
  }

  isLoading.value = true
  try {
    await Download.destroy(downloadToDelete.id)
    TW.workbench.alert.create('Download deleted successfully', 'notice')

    // If we deleted the pupal one and there's still a complete one, try deleting that too
    if (pupalDownload.value && completeDownload.value) {
      await Download.destroy(completeDownload.value.id)
    }

    completeDownload.value = null
    pupalDownload.value = null
    await refreshStatus()
  } catch (error) {
    TW.workbench.alert.create('Failed to delete download', 'error')
    console.error(error)
  } finally {
    isLoading.value = false
  }
}

function downloadFile() {
  if (completeDownload.value && completeDownload.value.file_url) {
    window.open(completeDownload.value.file_url, '_blank')
  }
}

function openApiLink(event) {
  window.open(event.currentTarget.href, '_blank')
}

function formatDate(dateString) {
  const date = new Date(dateString)
  return date.toLocaleString()
}

function getMaxAgeDate() {
  if (!completeDownload.value || !completeDownload.value.created_at || !props.maxAge) {
    return null
  }
  const createdDate = new Date(completeDownload.value.created_at)
  const maxAgeDate = new Date(createdDate.getTime() + (props.maxAge * 24 * 60 * 60 * 1000))
  return maxAgeDate.toISOString()
}
</script>

<style lang="scss" scoped>
.complete-download-control {
  background-color: var(--bg-muted);
  border: 1px solid var(--border-color);
  border-radius: 4px;
  padding: 1.5em;
  margin-bottom: 2em;
  box-sizing: border-box;
}

.download-info {
  .status-row,
  .info-row,
  .controls-row,
  .api-link-row {
    margin-bottom: 1em;

    &:last-child {
      margin-bottom: 0;
    }
  }

  .status-row {
    display: flex;
    align-items: center;
    gap: 0.5em;
  }

  .controls-row {
    display: flex;
    gap: 1em;
  }
}

.status-ready {
  font-weight: 600;
}

.status-creating {
  color: var(--color-warning);
  font-weight: 600;
}

.status-not-ready {
  color: var(--color-warning);
  font-weight: 600;
}

.status-expired {
  color: var(--color-error);
  font-weight: 600;
}

.status-none {
  font-weight: 600;
  opacity: 0.5;
}

.help-text {
  font-size: 0.9em;
  margin-left: 0.5em;
  opacity: 0.7;
}

.api-link-row {
  p.help-text {
    margin-left: 0;
  }
}
</style>
