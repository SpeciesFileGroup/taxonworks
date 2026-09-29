<template>
  <div class="panel content separate-top">
    <div class="flex-separate middle separate-bottom">
      <h2>{{ localFindMode ? 'Search results' : 'Submission summary' }}</h2>
      <div class="horizontal-right-content gap-small">
        <VBtn
          v-if="foundIds.length"
          color="primary"
          @click="sendToFilter"
        >
          Send to filter
        </VBtn>
        <VBtn
          v-if="localRows.length"
          color="primary"
          :disabled="isRefreshing"
          @click="refresh"
        >
          Refresh
        </VBtn>
        <VBtn
          color="primary"
          @click="() => { emit('clear') }"
        >
          Clear
        </VBtn>
      </div>
    </div>

    <p
      v-if="!localFindMode"
      class="subtle"
    >
      Observations are imported in the background. Use Refresh to check progress.
    </p>

    <table class="full_width table-striped">
      <thead>
        <tr>
          <th>iNat observation</th>
          <th>Taxon</th>
          <th>Observer</th>
          <th>Date</th>
          <th>Place</th>
          <th>CC Images</th>
          <th>CC Sounds</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="row in localRows"
          :key="row.observation_id"
        >
          <td>
            <a
              :href="`https://www.inaturalist.org/observations/${row.observation_id}`"
              target="_blank"
            >
              {{ row.observation_id }}
            </a>
          </td>
          <td
            v-if="row.determination_label"
            v-html="row.determination_label"
          />
          <td v-else>{{ row.taxon_name }}</td>
          <td>{{ row.observer }}</td>
          <td>{{ row.observed_on }}</td>
          <td>{{ row.place_guess }}</td>
          <td>{{ row.image_count ?? 'n/a' }}</td>
          <td>{{ row.sound_count ?? 'n/a' }}</td>
          <td>
            <FieldOccurrenceLink
              v-if="row.status === INAT_STATUS_FOUND || row.status === INAT_STATUS_CREATED"
              :browse-url="row.browse_url"
              :global-id="row.global_id"
              :determination-label="row.determination_label"
              @quick-forms-change="(event) => onQuickFormsChange(row.uuid, event)"
            />
            <span v-else-if="row.status === INAT_STATUS_NOT_IMPORTED">{{ localFindMode ? 'Not imported' : 'Queued' }}</span>
            <div
              v-else-if="row.status === INAT_STATUS_ALREADY_IMPORTED"
              class="flex-row gap-small middle"
            >
              <span>Already imported —</span>
              <FieldOccurrenceLink
                :browse-url="row.browse_url"
                :global-id="row.global_id"
                :determination-label="row.determination_label"
                @quick-forms-change="(event) => onQuickFormsChange(row.uuid, event)"
              />
            </div>
            <span v-else-if="row.status === INAT_STATUS_NOT_FOUND">Not found on iNaturalist</span>
            <span v-else-if="row.status === INAT_STATUS_NO_TAXON">No taxon — skipped</span>
            <span v-else>Queued</span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import FieldOccurrenceLink from './FieldOccurrenceLink.vue'
import { FieldOccurrence } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import {
  INAT_STATUS_FOUND,
  INAT_STATUS_CREATED,
  INAT_STATUS_NOT_IMPORTED,
  INAT_STATUS_ALREADY_IMPORTED,
  INAT_STATUS_NOT_FOUND,
  INAT_STATUS_NO_TAXON
} from '../constants/importStatuses.js'

const props = defineProps({
  rows: {
    type: Array,
    required: true
  },
  findMode: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['clear'])

defineOptions({ name: 'SummaryTable' })

const localRows = ref([...props.rows])
const localFindMode = ref(props.findMode)
const isRefreshing = ref(false)

watch(() => props.rows, rows => { localRows.value = [...rows] })
watch(() => props.findMode, mode => { localFindMode.value = mode })

const foundIds = computed(() =>
  localRows.value
    .filter(r => r.status === INAT_STATUS_FOUND || r.status === INAT_STATUS_CREATED)
    .map(r => r.field_occurrence_id)
    .filter(Boolean)
)

async function refresh() {
  const uuids = localRows.value.filter(r => r.uuid).map(r => r.uuid)
  if (!uuids.length) return

  isRefreshing.value = true
  try {
    const { body } = await FieldOccurrence.iNatCheckForExisting({ uuids })
    const foundByUuid = Object.fromEntries(body.found.map(f => [f.uuid, f]))
    localRows.value = localRows.value.map(row => {
      const match = row.uuid && foundByUuid[row.uuid]
      return match ? { ...row, ...match, status: 'created' } : row
    })
  } catch {
  } finally {
    isRefreshing.value = false
  }
}

function onQuickFormsChange(uuid, { slice }) {
  if (slice === 'taxon_determinations') {
    refreshRow(uuid)
  }
}

// Replace the row in place rather than refreshing every row, and keep its
// status.
async function refreshRow(uuid) {
  try {
    const { body } = await FieldOccurrence.iNatCheckForExisting({ uuids: [uuid] })
    const updated = body.found[0]
    const index = localRows.value.findIndex((row) => row.uuid === uuid)
    if (updated && index !== -1) {
      localRows.value[index] = { ...localRows.value[index], ...updated }
    }
  } catch {}
}

function sendToFilter() {
  const params = foundIds.value.map(id => `field_occurrence_id[]=${id}`).join('&')
  window.open(`${RouteNames.FilterFieldOccurrence}?${params}`, '_blank')
}
</script>
