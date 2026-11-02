<template>
  <div class="flex-col gap-small">
    <div class="flex-separate middle gap-small">
      <VSwitch
        v-model="tabIndex"
        name="filename-depiction-status"
        use-index
        :options="tabLabels"
      />
      <div class="horizontal-right-content middle gap-small">
        <VBtn
          medium
          color="create"
          :disabled="!store.uploadableRows.length || store.isMatching"
          @click="emit('upload')"
        >
          Upload {{ store.uploadableRows.length }} matched files
        </VBtn>
        <VBtn
          v-if="store.failedRows.length"
          medium
          color="primary"
          :disabled="store.isUploading"
          @click="emit('retry')"
        >
          Retry {{ store.failedRows.length }} failed
        </VBtn>
        <CsvButton
          :list="csvRows"
          :options="{ delimiter: '\t' }"
          filename="filename_depictions.tsv"
          title="Download results as TSV"
        />
        <VBtn
          circle
          color="primary"
          title="Reset"
          :disabled="store.isUploading"
          @click="emit('reset')"
        >
          <VIcon
            name="reset"
            x-small
          />
        </VBtn>
      </div>
    </div>
    <div v-if="uploadTotal">
      Uploaded {{ uploadDone }} of {{ uploadTotal }}
      <progress
        class="full_width"
        :max="uploadTotal"
        :value="uploadDone"
      />
    </div>
  </div>
</template>

<script setup>
import { computed, watch } from 'vue'
import { useStore } from '../../store/store'
import { STATUS, STATUS_META } from '../../constants'
import CsvButton from '@/components/csvButton.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const STATUS_ORDER = [
  STATUS.Matching,
  STATUS.Matched,
  STATUS.NotFound,
  STATUS.Ambiguous,
  STATUS.PatternMismatch,
  STATUS.Queued,
  STATUS.Uploading,
  STATUS.Created,
  STATUS.AlreadyDepicted,
  STATUS.Error
]

const PENDING_UPLOAD = [STATUS.Queued, STATUS.Uploading]

const ALL = 'all'

const filter = defineModel('filter', {
  type: String,
  default: ALL
})

const emit = defineEmits(['upload', 'retry', 'reset'])

const store = useStore()

const visibleStatuses = computed(() =>
  STATUS_ORDER.filter((status) => store.statusCounts[status])
)

const uploadRows = computed(() => store.rows.filter((row) => row.upload))

const uploadTotal = computed(() =>
  uploadRows.value.some((row) => PENDING_UPLOAD.includes(row.upload.status))
    ? uploadRows.value.length
    : 0
)

const uploadDone = computed(
  () =>
    uploadRows.value.filter(
      (row) => !PENDING_UPLOAD.includes(row.upload.status)
    ).length
)

const csvRows = computed(() =>
  store.rows.map((row) => {
    const match = store.rowMatch(row)

    return {
      filename: row.filename,
      status: store.rowStatus(row),
      identifier: match?.identifier || '',
      collection_object_id: match?.collection_object_id || '',
      image_id: row.upload?.response?.image_id || '',
      depiction_id: row.upload?.response?.id || '',
      figure_label: match?.figure_label || '',
      caption: match?.caption || '',
      message: row.upload?.message || ''
    }
  })
)

const tabs = computed(() => [ALL, ...visibleStatuses.value])

const tabLabels = computed(() =>
  tabs.value.map((tab) =>
    tab === ALL
      ? `All (${store.rows.length})`
      : `${STATUS_META[tab].label} (${store.statusCounts[tab]})`
  )
)

const tabIndex = computed({
  get: () => Math.max(tabs.value.indexOf(filter.value), 0),
  set: (index) => {
    filter.value = tabs.value[index]
  }
})

watch(tabs, (value) => {
  if (!value.includes(filter.value)) {
    filter.value = ALL
  }
})
</script>
